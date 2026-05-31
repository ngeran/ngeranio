+++
title = 'Beyond the Ping: Mastering TWAMP on Juniper MX'
date = 2026-05-30T12:00:00-04:00
draft = false
tags = ["TWAMP", "Observability", "Measurement", "Juniper"]
summary = 'TWAMP and TWAMP-Light on Juniper MX — detecting gray failures, jitter, and slowness before your customers report it.'
+++

### Why Ping Isn't Enough

In modern service provider networks, "Down" is easy to detect. The real challenge is **"Sick but Not Dead."** These are the gray failures — micro-bursts, jitter spikes, and intermittent slowness — that frustrate users but leave traditional monitoring tools green.

The **Two-Way Active Measurement Protocol (TWAMP)** is the industry-standard answer to this problem. In this guide, we will explore how to deploy TWAMP on Juniper MX routers to catch slowness before your customers report it.

---

### TWAMP vs. TWAMP-Light vs. STAMP

Choosing the right flavor of the protocol is the difference between a stable monitoring platform and a "flickering" inventory.

| Feature | Standard TWAMP | TWAMP-Light / STAMP |
| :--- | :--- | :--- |
| **Control Plane** | Uses TCP Port 862 for handshaking. | **No Control Plane.** Only UDP Probes. |
| **Statefulness** | High overhead; sessions can flap if TCP lags. | Low overhead; stateless and resilient. |
| **Evolution** | Defined in RFC 5357. | STAMP (RFC 8762) is the modern version of Light. |
| **"Sick" Network** | May fail if packet loss kills the TCP session. | **Keeps probing** even during 50% packet loss. |

**The Verdict:** For high-precision "Slowness" detection on Juniper, **TWAMP-Light** is superior because it remains active even when the network is degraded.

---

### Phase 1: Preparing the Chassis (The Hardware Secret)

On Juniper MX routers, high-precision timestamping requires either **Microkernel-based** timestamping or **Inline** (Services Interface) timestamping. If you choose the Inline route (`si-` interfaces), you **must** reserve bandwidth on the chassis, or the service will not start.

#### Step 1: Reserve Inline Services Bandwidth

This command tells the Packet Forwarding Engine (PFE) to set aside capacity for the TWAMP service.

```text
# Replace slot and pic with your hardware values
set chassis fpc 0 pic 0 inline-services bandwidth 1g
```

#### Step 2: Configure the Services Interface (Optional)

If you require Inline timestamping (highest accuracy), define the si interface:

```text
set interfaces si-0/0/0 unit 10 rpm twamp-client family inet address 10.30.30.1/24
# Note: Do not use Unit 0 for TWAMP; it will result in a configuration error.
```

**Note:** For many modern vMX and MX deployments, Microkernel-based timestamping is sufficient and does not require an si interface; it establishes sessions based on the target route.

---

### Phase 2: The "Golden Config" for Juniper MX

We will use three sessions: **Voice (EF)**, **Video (AF41)**, and **Best Effort (BE)** to identify which specific traffic class is "slow."

#### PE1: The Controller (Client)

*Targeting PE2 (10.100.249.4) from Source (10.100.249.1)*

```text
# 1. Global Client Settings
set services rpm twamp client control-connection pe1-to-pe2 control-type light
set services rpm twamp client control-connection pe1-to-pe2 history-size 512
set services rpm twamp client control-connection pe1-to-pe2 moving-average-size 32
# IMPORTANT: Keeps results visible even between test iterations
set services rpm twamp client control-connection pe1-to-pe2 persistent-results

# 2. Voice Test (Catching Jitter/Slowness)
set services rpm twamp client control-connection pe1-to-pe2 test-session voice-ef source-address 10.100.249.1
set services rpm twamp client control-connection pe1-to-pe2 test-session voice-ef target-address 10.100.249.4
set services rpm twamp client control-connection pe1-to-pe2 test-session voice-ef destination-port 862
set services rpm twamp client control-connection pe1-to-pe2 test-session voice-ef dscp-code-points ef
set services rpm twamp client control-connection pe1-to-pe2 test-session voice-ef probe-count 1000
set services rpm twamp client control-connection pe1-to-pe2 test-session voice-ef probe-interval 0.1
set services rpm twamp client control-connection pe1-to-pe2 test-session voice-ef iteration-interval 1

# 3. Slowness Thresholds (Triggers SNMP Traps)
set services rpm twamp client control-connection pe1-to-pe2 test-session voice-ef thresholds rtt 50000
set services rpm twamp client control-connection pe1-to-pe2 test-session voice-ef thresholds jitter-egress 10000
```

#### PE2: The Responder (Server)

*Listening for PE1 (10.100.249.1)*

```text
set services rpm twamp server authentication-mode none
set services rpm twamp server light
set services rpm twamp server port 862
set services rpm twamp server client-list pe1-client address 10.100.249.1/32
```

---

### Phase 3: Optimizing for Accuracy

The MX480 can offload probes to the hardware to ensure the "slowness" you see is real network delay and not just a busy router CPU.

#### Delegate Probes

Move processing from the Routing Engine (RE) to the Packet Forwarding Engine (PFE).

```text
set services rpm twamp client control-connection pe1-to-pe2 delegate-probes
```

#### Hardware Timestamps

```text
set services rpm twamp client control-connection pe1-to-pe2 hardware-timestamping
```

---

### Phase 4: Verifying and Analyzing "Slowness"

#### The Disappearing Session Problem

If you run `show services rpm twamp client session` and it returns empty, it is usually because the router is in a "Gap" between test iterations.

**Solution:** Use `persistent-results` in your config and check `probe-results`.

#### Key Analysis Commands

```text
# 1. See if the sessions are defined
run show services rpm twamp client session

# 2. The most important command for slowness:
run show services rpm twamp client probe-results
```

#### How to Read the Output

Look at these three metrics in the probe-results to diagnose a "sick" network:

- **Standard Deviation (Stddev):** If high (>15ms), the network is jittery. This is the primary cause of "slowness" in real-time apps.
- **Peak-to-Peak Jitter:** Shows the worst-case variance. Large gaps indicate micro-bursts saturating a link.
- **Positive vs. Negative Jitter:** Distinguishes if the congestion is on the transmit (Egress) or return (Ingress) path.

#### Inventory Management Logic

If you are building a monitoring dashboard, use this logic to manage your device inventory:

- **Status: Green** — 0% Loss, Stddev < 5ms.
- **Status: Yellow (Sick)** — 0% Loss, Stddev > 20ms. **Action:** Proactive check for interface congestion.
- **Status: Red (Dead)** — 100% Loss. **Action:** Immediate circuit troubleshooting.

**Pro-Tip:** If the `show session` command is empty but `probe-results` still shows data, the device is still "Connected." Do not remove it from your inventory unless both commands return empty for more than 5 minutes.

---

### Conclusion

By moving from simple Pings to TWAMP-Light with Delegated Probes and properly configured Chassis Bandwidth, you gain a microscopic view of your network health. You no longer have to wait for the "Down" alert; you can see the "Slowness" in the jitter trends and act before the customer calls.
