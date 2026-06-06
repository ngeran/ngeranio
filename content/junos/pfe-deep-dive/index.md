+++
title = 'Juniper PFE Deep Dive: Diagnosing Silent Packet Drops When BGP Is Up'
date = 2026-06-05T10:00:00-04:00
draft = false
tags = ["Juniper", "Junos", "PFE", "Troubleshooting", "BGP", "MX-Series"]
summary = 'Move beyond show route — hardware-level diagnostics, FIB sync issues, ASIC discards, JSIM simulation, and packet-via-dmem captures on Juniper MX-Series.'
+++

### The Ghost Drop Problem

In the world of high-end routing, the most frustrating ticket is the **"Ghost Drop."** The control plane looks perfect: BGP sessions are `Established`, the RIB is populated, and `show route` points to the correct interface. Yet, traffic enters the router and simply vanishes.

When the Control Plane (RE) says **"Yes"** but the Data Plane (PFE) says **"No,"** you have either a **FIB/PFE Desynchronization** or a **Hardware Exception**. This guide moves beyond standard CLI commands and dives directly into the **Packet Forwarding Engine (PFE)** to find where packets go to die.

---

### The Architecture of a Drop: Control vs. Transit

On a Juniper MX, protocol traffic (like BGP) is *punted* to the Routing Engine (RE) for software processing. Transit traffic stays entirely in the **Fast Path** (the PFE hardware pipeline). These two planes are functionally independent — which is exactly why BGP can be `Established` while traffic is silently blackholed.

```text
+---------------------------------------------+
|              Routing Engine (RE)             |
|  BGP / OSPF / IS-IS   <--->   RIB (kernel)  |
|                                 |            |
|                           KRT (push)         |
|                                 v            |
+---------------------------------------------+
|         Packet Forwarding Engine (PFE)       |
|  FIB (J-Tree) -> NH Resolution -> Egress Q   |
|                                              |
|   Trio Chipset:  LU -> JNH -> MQ -> XM/XQ    |
+---------------------------------------------+
```

If BGP is up but transit traffic is down, the PFE likely has one of these conditions:

| Root Cause | Symptom | First Check |
| :--- | :--- | :--- |
| **FIB Missing Entry** | RE has route, PFE does not | `show route` vs PFE shell `show route target` |
| **Next-Hop Resolution Failure** | NH exists but resolves to `Hold` | `show nhdb id <id> detail` |
| **TCAM Exhaustion** | Random or new-prefix drops | `show jnh 0 pool summary` |
| **Firewall / ACL Discard** | Traffic silently dropped, counters zero | `show pfe filter hw filter-name` |
| **Fabric / MTU Error** | Drops on specific interfaces or sizes | `show pfe statistics error` |

---

### Junos Core Architecture: The Three Tiers of a Route

The Junos platform strictly separates the control plane logic from the forwarding data plane. To understand how a packet actually moves through the router to a destination, we must trace it through three distinct layers:

| Tier | Layer | Role |
| :--- | :--- | :--- |
| **1** | **The Control Plane RIB** *(The Intent)* | Managed by the Routing Protocol Daemon (`rpd`). It learns all available network paths and determines the mathematically best route based on administrative metrics. |
| **2** | **The Kernel Forwarding Table** *(The Bridge)* | The OS kernel inherits the active routes from `rpd` and compiles them into a system-wide master forwarding table, assigning high-performance numeric indexing tracking tokens (Next-Hop IDs). |
| **3** | **The PFE Radix Tree & NHDB** *(The Reality)* | The Packet Forwarding Engine stores this information in high-speed lookup memory structures. On a vMX, this manifests as an optimized virtualized radix tree and a Next-Hop Database (`nhdb`) running inside the FPC microkernel. |

---

### Complete Step-by-Step Validation Flow

To demonstrate how all three tiers align, we trace a specific destination — `10.100.249.3` — from the control plane down to the physical wire.

#### Tier 1: The Control Plane RIB (The Intent)

First, we query the main routing table (`inet.0`) to verify that a routing protocol has successfully learned the prefix and selected it as active.

```text
admin@vMX-PE1> show route 10.100.249.3

inet.0: 29 destinations, 30 routes (29 active, 0 holddown, 0 hidden)
+ = Active Route, - = Last Active, * = Both

10.100.249.3/32    *[OSPF/10] 01:33:16, metric 3
                    >  to 10.0.61.0 via ge-0/0/1.0
```

> **Validation Insight:** The `*` symbol confirms this is the active route in the RIB. It was calculated by OSPF (Preference 10) with a metric of 3, pointing toward gateway `10.0.61.0` via interface `ge-0/0/1.0`.

#### Tier 2: The Kernel Forwarding Table (The Bridge)

Next, we verify that the kernel has successfully converted the RIB's abstract routing path into a forwarding action step.

```text
admin@vMX-PE1> show route forwarding-table destination 10.100.249.3

Routing table: default.inet
Internet:
Destination        Type RtRef Next hop           Type Index    NhRef Netif
10.100.249.3/32    user     0 10.0.61.0          ucst      588    25 ge-0/0/1.0
```

> **Validation Insight:** The kernel has built a hardware bridge entry for this destination. Most importantly, it has associated this path with an internal token: **Index 588**. This is the unique key used to program the data plane.

#### Tier 3: The PFE Lookup & Next-Hop Runtime (The Reality)

To verify the actual lookup state inside the data plane execution environment, we dive into the line card's virtual vty shell.

```text
admin@vMX-PE1> start shell pfe network fpc0
VMX-0(vMX-PE1 vty)#
```

**Step A: Verify the PFE Radix Entry**

We query the virtual PFE's active hardware table (`default.0`, structure code `0x80008`) to ensure the route was programmed downstream successfully.

```text
VMX-0(vMX-PE1 vty)# show route ip prefix 10.100.249.3/32

IPv4 Route Table 0, default.0, 0x80008:
Destination                       NH IP Addr      Type     NH ID Interface
--------------------------------- --------------- -------- ----- ---------
10.100.249.3                      10.0.61.0        Unicast   588 RT-ifl 0 ge-0/0/1.0 ifl 334
```

> **Validation Insight:** The PFE hardware matches our lookup exactly. It maps `10.100.249.3` to **NH ID 588**, bound to logical interface index **334** (`ifl 334`).

**Step B: Inspect the Next-Hop Descriptor**

Finally, we read the exact instruction block assigned to **NH ID 588** inside the Next-Hop Database (`nhdb`). This dictates exactly how the packet will be packaged and sent over the physical wire.

```text
VMX-0(vMX-PE1 vty)# show nhdb id 588

   ID      Type      Interface    Next Hop Addr    Protocol       Encap     MTU               Flags  PFE internal Flags
-----  --------  -------------  ---------------  ----------  ------------  ----  ------------------  ------------------
  588   Unicast  ge-0/0/1.0     10.0.61.0              IPv4      Ethernet  1500  0x0000000000000000  0x0000000000000000
```

> **Validation Insight:** When a payload transit packet matches our destination, the PFE pulls this descriptor out of hardware cache. It encapsulates the packet using Ethernet formatting, enforces an MTU of 1500, structures it for an IPv4 payload network layer, and pushes it out interface `ge-0/0/1.0` toward the physical gateway `10.0.61.0`.

#### Architectural Mapping Summary

Every single piece of data across all three terminal outputs aligns perfectly to construct a clear picture of the system's operational integrity:

$$\text{OSPF Route } (10.100.249.3/32) \longrightarrow \text{Kernel FIB Index } (588) \longrightarrow \text{PFE NH ID } (588) \longrightarrow \text{Egress Wire } (\text{ge-0/0/1.0})$$

> **Architect's Note:** If the route is in the RIB but absent from the PFE shell, check `show log messages | match KRT`. This almost always indicates a **KRT queue stuck** or **PFE memory exhaustion**. The KRT (Kernel Routing Table) is the async pipe between the RE and PFE — it can stall under high-churn BGP reconvergence events.

---

### The Investigative Workflow

#### Step 1: Verify the Three Sources of Truth

A route must exist at all three independent layers described above before traffic can flow. Never assume consistency between them — always validate end-to-end as demonstrated in the validation flow.

```text
# 1. Control plane RIB — The Intent
# What the routing protocol installed
user@MX> show route <prefix>

# 2. Kernel forwarding table — The Bridge
# What the OS has pushed toward the hardware
user@MX> show route forwarding-table destination <prefix>

# 3. PFE J-Tree — The Reality
# What the ASIC will actually use when forwarding
user@MX> start shell pfe network fpc0
root@router-fpc0:pfe> show route target <prefix>
```

#### Step 2: Locate Silent Hardware Discards

If the route exists in the PFE, the ASIC may still be discarding the packet due to integrity or policy errors. These will not show up in `show interfaces` counters.

```text
root@router-fpc0:pfe> show pfe statistics traffic
root@router-fpc0:pfe> show pfe statistics error
```

**What to look for:**

- **Fabric Drops** — Suggests congestion on the midplane or a faulty fabric card.
- **MTU Errors** — Packet is too large for the egress path (common with VXLAN encapsulation or IPsec overhead miscalculation).
- **Lookup Drops** — Packet arrived and was looked up, but the PFE returned `discard`. Usually a missing default route, Null0 black-hole, or failed uRPF check.
- **Error Discard** — L3 checksum failure or TTL-expired punt that was then dropped.

---

### PFE Shell Access Levels & Safety

PFE shells are extremely powerful and carry real risk in production. Running unsupported commands can crash an FPC or corrupt hardware state.

| Security Level | Command | Capability | Risk |
| :--- | :--- | :--- | :--- |
| **0** (default) | `set parser security 0` | Safe diagnostics — optics, basic stats, route tables | None |
| **10** | `set parser security 10` | Intermediate — `packet-via-dmem`, NHDB dumps, table exports | Low–Medium |
| **15** | `set parser security 15` | Raw ASIC register access, trap configuration | **High — JTAC only** |

Always start at level 0 and escalate only when lower-level commands cannot answer the question.

---

### Deep-Diving the Trio Chipset

#### Next-Hop Verification

A route entry pointing to a corrupted or unresolved Next-Hop is the most common cause of ghost drops that pass the "Three Sources of Truth" check.

```text
# First: find the NH ID from 'show route target' output
# Then: inspect the hardware NH entry
root@router-fpc0:pfe> show nhdb id <next-hop-id> detail
```

**Interpreting the output:**

- `Type: Unicast` — Normal forwarding entry. Verify `Interface` and `MAC` fields are correct.
- `Type: Hold` — The PFE is waiting on an ARP/ND response. Traffic will be dropped until resolution completes. Check `show arp no-resolve` on the RE.
- `Type: Discard` — An explicit discard NH. Verify if this is intentional (null route) or a bug.
- `Type: Reject` — Sends an ICMP unreachable. Useful for confirming whether RE-side or PFE-side is generating the reject.

#### TCAM & Firewall Filter Allocation

Large full-table BGP feeds combined with complex ACL policies can exhaust the TCAM. When this happens, the PFE silently stops accepting new entries.

```text
root@router-fpc0:pfe> show jnh 0 pool summary
```

**Key pools to monitor:**

| Pool | Contents | Alert Threshold |
| :--- | :--- | :--- |
| **Pool 0** | Next-Hop entries | >85% |
| **Pool 1** | Firewall filter terms | >85% |
| **Pool 2** | MPLS labels | >80% |

If any pool exceeds ~95%, the PFE stops allocating new entries and drops traffic for any prefix or policy that would require a new entry. This is a silent failure — no log message is generated by default.

**Mitigation:** Reduce filter complexity, implement route aggregation, or redistribute load across additional FPCs.

---

### The Smoking Gun: JSIM Packet Simulation

JSIM (Juniper Simulator) is the fastest diagnostic tool available for ghost drops. It provides a **hardware dry-run**: you describe a packet in software and ask the ASIC what it would do with it — without any traffic ever hitting the wire.

#### Basic JSIM Flow

```text
# Enter VTY context for the Lookup Unit (LU) chip
user@MX> request pfe execute target fpc0 command "start shell"
NPC0(router vty)# set jsim input-port ge-0/0/0
NPC0(router vty)# set jsim ipsrc 192.0.2.10
NPC0(router vty)# set jsim ipdst 203.0.113.5
NPC0(router vty)# set jsim ip-protocol 1
NPC0(router vty)# set jsim ip-ttl 64
NPC0(router vty)# jsim run 1
```

#### Interpreting JSIM Output

JSIM produces a trace of every processing stage the packet would traverse:

```text
JSIM: Packet ingress on ge-0/0/0
  -> LU lookup:    prefix 203.0.113.0/24  NH-id: 0x1a4
  -> NH resolution: Type=Unicast  Egress=ge-0/1/0  MAC=00:1a:2b:3c:4d:5e
  -> Firewall eval: filter EDGE-IN, term PERMIT-BGP -> Accept
  -> Egress enqueue: CoS queue 3 (AF41)
  -> Result: FORWARD
```

If a drop occurs, JSIM returns a specific reason code:

| JSIM Result | Meaning | Remediation |
| :--- | :--- | :--- |
| `FORWARD` | Normal — packet would be forwarded | — |
| `Drop: NH-DISCARD` | NH resolved to explicit discard | Check routing policy for null routes |
| `Drop: Firewall Term: REJECT-ALL` | Filter default deny hit | Inspect filter terms and term ordering |
| `Drop: uRPF-STRICT` | Reverse-path check failed | Verify symmetric routing or switch to loose mode |
| `Drop: TTL-EXPIRED` | TTL reached zero in PFE | Check for forwarding loops |
| `Drop: MTU-EXCEEDED` | Egress MTU smaller than packet | Verify MTU end-to-end, check DF bit |

> **Why JSIM is preferred over live capture:** JSIM runs in microseconds, produces no load on production interfaces, and gives you the exact ASIC decision path with reason codes. Use live capture (`packet-via-dmem`) only when you need to validate what is *actually arriving* at the ingress port.

#### Advanced JSIM: MPLS and VLAN Scenarios

JSIM can simulate more complex encapsulations:

```text
# Simulate an MPLS-encapsulated packet
NPC0(router vty)# set jsim input-port et-0/0/0
NPC0(router vty)# set jsim mpls-label 16001
NPC0(router vty)# set jsim ipsrc 10.255.0.1
NPC0(router vty)# set jsim ipdst 10.255.0.9
NPC0(router vty)# jsim run 1

# Simulate a tagged (802.1Q) frame
NPC0(router vty)# set jsim input-port xe-0/0/4
NPC0(router vty)# set jsim vlan-id 100
NPC0(router vty)# set jsim ipsrc 192.168.10.1
NPC0(router vty)# set jsim ipdst 192.168.10.254
NPC0(router vty)# jsim run 1
```

---

### Low-Level Capture: packet-via-dmem

When JSIM confirms the ASIC *would* forward a packet but drops are still occurring, the problem is upstream. This is when you need a hardware-level packet capture.

> **Production Warning:** On a high-traffic router, `packet-via-dmem` can saturate the FPC CPU and cause forwarding latency or instability. Always follow the quiesce procedure. Limit captures to specific filter criteria and short durations.

#### Pre-Capture: Quiesce the PFE

```text
# Escalate to security level 10
root@router-fpc0:pfe> set parser security 10

# Disable periodic host-loopback health checks
root@router-fpc0:pfe> set host_loopback disable-periodic

# Disable fabric self-ping on FPC slot 0
root@router-fpc0:pfe> test fabric self_ping disable 0
```

#### Configure the Capture Buffer

```text
# Enable a 16KB capture buffer on JNH 0
root@router-fpc0:pfe> test jnh 0 packet-via-dmem enable

# Set the capture mask
# 0x01 = ingress only
# 0x02 = egress only
# 0x03 = both ingress and egress
root@router-fpc0:pfe> test jnh 0 packet-via-dmem capture 0x03
```

#### Capture Mask Reference

| Mask Value | Captures | Use Case |
| :--- | :--- | :--- |
| `0x01` | Ingress only | Verify packet is arriving on expected interface |
| `0x02` | Egress only | Confirm packet is being queued for transmission |
| `0x03` | Ingress + Egress | Full path trace — highest CPU impact |
| `0x04` | Exception packets (punted to RE) | Diagnose control-plane punt storms |
| `0x07` | All classes | Maximum visibility — maintenance windows only |

#### Execute the Capture

```text
# Let capture run for 2-5 seconds, then stop
root@router-fpc0:pfe> test jnh 0 packet-via-dmem capture 0

# Dump the captured packets from the dmem buffer
root@router-fpc0:pfe> test jnh 0 packet-via-dmem dump
```

#### Reading the Dump

The dump output is raw hex with a Juniper-specific header:

```text
--- Packet 0 ---
Timestamp : 0x1a4f8b20
Ingress   : ge-0/0/0 (IFD index 143)
Length    : 98 bytes
Data      :
  0000  00 1a 2b 3c  4d 5e 00 0a  b1 c2 d3 e4  08 00 45 00
  0010  00 54 12 34  40 00 40 01  a3 bc c0 00  02 0a cb 00
  0020  71 05 08 00  1f 4a 00 01  00 01 ...
```

**Parsing the key fields:**

- Bytes 0–5: Destination MAC → `00:1a:2b:3c:4d:5e`
- Bytes 6–11: Source MAC → `00:0a:b1:c2:d3:e4`
- Bytes 12–13: EtherType → `0x0800` (IPv4)
- Byte 14: IP Version/IHL → `0x45` (IPv4, 20-byte header)
- Byte 23: IP Protocol → `0x01` (ICMP)
- Bytes 26–29: Source IP → `192.0.2.10`
- Bytes 30–33: Destination IP → `203.0.113.5`

For faster analysis, copy the hex to Wireshark's "Import from Hex Dump" feature with encapsulation type **Ethernet**.

#### Filtering Before Capture (Recommended)

```text
# Filter by source address
root@router-fpc0:pfe> test jnh 0 packet-via-dmem filter src-addr 192.0.2.10/32

# Filter by destination prefix
root@router-fpc0:pfe> test jnh 0 packet-via-dmem filter dst-addr 203.0.113.0/24

# Filter by protocol (1=ICMP, 6=TCP, 17=UDP)
root@router-fpc0:pfe> test jnh 0 packet-via-dmem filter ip-proto 6
```

#### Post-Capture Cleanup

```text
# Disable the capture buffer
root@router-fpc0:pfe> test jnh 0 packet-via-dmem disable

# Re-enable fabric self-ping
root@router-fpc0:pfe> test fabric self_ping enable 0

# Re-enable host loopback checks
root@router-fpc0:pfe> set host_loopback enable-periodic

# Return to default security level
root@router-fpc0:pfe> set parser security 0
```

> **Failure to restore these settings** may cause the router to miss fabric errors, generate false loopback wedge alarms, or suppress real hardware fault detection.

---

### Chip-Level Error Diagnostics

When you suspect ASIC hardware faults (ECC errors, parity failures), the Trio chipset provides internal error registers accessible via the LU chip diagnostic interface.

```text
# Check the Lookup Unit error message register
root@router-fpc0:pfe> show luchip 0 errmsg

# Check MQ (Memory Queuing) chip for buffer errors
root@router-fpc0:pfe> show mqchip 0 statistics

# Check XM chip (ingress packet manipulation) errors
root@router-fpc0:pfe> show xmchip 0 statistics
```

**What these errors mean:**

| Error Type | Meaning | Action |
| :--- | :--- | :--- |
| **Single-bit ECC** | Corrected memory error — monitoring required | Open JTAC case, monitor frequency |
| **Multi-bit ECC** | Uncorrectable — FPC may panic or forward corrupted data | Emergency FPC restart, open P1 JTAC |
| **Parity Error** | Data corruption in the ASIC pipeline | FPC OIR (Online Insertion/Removal) may be required |
| **CRC Error** | Fabric link or midplane integrity failure | Check fabric cards and cables |

---

### Platform Stability: The Trinity Wedge

On MX Series, a `HOST LOOPBACK WEDGE DETECTED` alarm in `/var/log/messages` indicates that the PFE has detected its own host-loopback path has gone unresponsive. This is commonly triggered by `ttrace` holding a PPE thread longer than the loopback timeout threshold.

**Characteristic log pattern:**

```text
fpc3 : HOST LOOPBACK WEDGE DETECTED on PFE 0
fpc3 : WEDGE recovery action: restart
```

**The fix — disable tracing while preserving crash saves:**

```text
root@router-fpc3:pfe> set parser security 15
root@router-fpc3:pfe> test jnh 0 trap-info-read trace disable
```

This disables the `ttrace` tracing component while keeping the crash-save mechanism active. Always engage JTAC before running commands at security level 15 in production.

---

### Correlating PFE Drops with Traffic Telemetry

For environments with streaming telemetry (gNMI/gRPC), correlate PFE-level drops against your time-series database to establish *when* the problem started.

**Useful gNMI paths for MX PFE monitoring:**

```text
# Interface-level input/output errors
/interfaces/interface[name=<ifname>]/state/counters/in-errors
/interfaces/interface[name=<ifname>]/state/counters/out-errors

# Firewall filter counters (when filter has 'count' action)
/firewall/filter[name=<filter>]/term[name=<term>]/state/packet-count

# FPC memory utilization
/components/component[name=<fpc>]/state/memory/utilized
```

If your stack uses **gNMIc + Prometheus + Grafana**, a spike in `in-errors` or `out-errors` that precedes a BGP route withdrawal is a strong indicator of a hardware event rather than a protocol event.

---

### Summary Troubleshooting Checklist

When BGP is up but traffic is blackholing, work through this sequence:

- **1.** `show log messages | match "KRT|PFE"` — Are RE and PFE out of sync?
- **2.** PFE shell → `show route target <prefix>` — Does the ASIC have the route?
- **3.** `show nhdb id <nh-id> detail` — Is the NH resolved? `Type=Hold` means ARP pending.
- **4.** `show pfe statistics error` — Any fabric drops, MTU errors, or lookup drops?
- **5.** Run JSIM simulation — What does the ASIC say it would do with the packet?
- **6.** `show jnh 0 pool summary` — Is TCAM exhausted (>85%)?
- **7.** `show luchip 0 errmsg` — Any ECC or parity errors on the LU chip?
- **8.** `packet-via-dmem` (after quiescing) — Is the packet actually arriving on the expected interface?

---

### Glossary of Juniper ASIC Components

| Term | Full Name | Role |
| :--- | :--- | :--- |
| **LU Chip** | Lookup Unit | Route and filter table lookups |
| **MQ Chip** | Memory Queuing | Packet buffering and scheduling |
| **XM Chip** | Ingress eXpansion Module | Ingress packet header processing |
| **XQ Chip** | Egress eXpansion Queue | Egress packet shaping and replication |
| **JNH** | Juniper Next Hop | Hardware database mapping routes to egress actions |
| **JSIM** | Juniper Simulator | Software-driven hardware packet simulation |
| **KRT** | Kernel Routing Table | Async pipe pushing RE routes to PFE |
| **PPE** | Packet Processing Engine | Thread-based microprocessor within the PFE |
| **TCAM** | Ternary CAM | High-speed memory for filter and route lookups |
| **dmem** | Descriptor Memory | PFE internal buffer used for packet capture |

> **Disclaimer:** All commands in this guide have been validated on Junos 21.x and 22.x on MX204/MX480/MX960 platforms. Always reproduce in a lab environment before executing in production. PFE shell commands at security levels 10 and above should only be run with JTAC awareness during a maintenance window.
