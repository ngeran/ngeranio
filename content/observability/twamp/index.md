+++
title = 'Beyond the Ping: Mastering TWAMP on Juniper MX'
date = 2026-05-30T12:00:00-04:00
draft = false
tags = ["TWAMP", "Observability", "Measurement", "Juniper"]
summary = 'A production hardware-accelerated TWAMP deployment on Juniper MX with inline services — three QoS classes (Voice, Video, Best Effort), bidirectional measurement, and line-by-line config explanation.'
+++

### Why Ping Isn't Enough

In modern service provider networks, "Down" is easy to detect. The real challenge is **"Sick but Not Dead."** These are the gray failures — micro-bursts, jitter spikes, and intermittent slowness — that frustrate users but leave traditional monitoring tools green.

**Two-Way Active Measurement Protocol (TWAMP)** is the industry-standard answer. This guide walks through a **real production deployment** on Juniper MX routers using hardware-accelerated inline services: bidirectional measurement across three QoS classes (Voice, Video, Best Effort), with every config line explained.

---

### TWAMP vs. TWAMP-Light

| Feature | Standard TWAMP (Managed) | TWAMP-Light / STAMP |
| :--- | :--- | :--- |
| **Control Plane** | Uses TCP Port 862 for session setup. | **No Control Plane.** Only UDP probes. |
| **Test Session Ports** | Dynamically negotiated via TCP (e.g., 10000–10002). | Statically defined per session. |
| **MX `si-` Interface** | **Supported.** Required for hardware timestamping. | **Rejected.** MX microcode does not support Light on inline services. |
| **"Sick" Network** | TCP session may fail under severe packet loss. | Stateless — keeps probing even during 50% loss. |

#### Why This Guide Uses Managed Mode

This guide uses **`control-type managed`** because we anchor our TWAMP sessions to an inline services interface (`si-0/0/0`) for hardware-accelerated timestamping. On Juniper MX, the `si-` interface data plane microcode **only supports managed mode**. Attempting `control-type light` results in a commit check error:

```text
'control-connection pe1-to-pe2'
   Only managed control-type is allowed under si-0/0/0.10 interface
```

If you are running TWAMP without an `si-` interface (RE-based software timestamping only), Light mode is a valid choice. But for production-grade accuracy on MX hardware, Managed Mode with `si-` is the gold standard.

---

### The Four TWAMP Roles (Simplified)

TWAMP defines four logical roles, but in practice you only need **two devices**:

- **Controller** (Control-Client + Session-Sender) — initiates probes and collects metrics.
- **Responder** (Server + Session-Reflector) — receives probes and reflects them back with timestamps.

Both devices run a **client** (to send probes) and a **server** (to reflect probes from the other side). This gives you bidirectional visibility.

---

### Our Lab Topology

```text
    PE1 (10.100.249.1)  <---------->  PE2 (10.100.249.2)
    AS 65001                              AS 65001

    PE1 sends probes to PE2 (Voice, Video, BE)
    PE2 sends probes to PE1 (Voice, Video, BE)
    Both act as client AND server simultaneously
```

We create **three test sessions per direction**, each matching a real traffic class:

| Session | DSCP | Purpose |
| :--- | :--- | :--- |
| `voice-ef` | EF (46) | Detect jitter and latency in voice traffic |
| `video-af41` | AF41 (34) | Detect slowness in video streaming |
| `best-effort` | BE (0) | Baseline for all other traffic |

> **How ports work in Managed Mode:** Port 862 is used **only** for the initial TCP control handshake between client and server. Once the control session is established, the server dynamically assigns distinct UDP ports for each test session (e.g., 10000, 10001, 10002). You do **not** configure `destination-port` on individual sessions — the TCP negotiation handles it automatically.

```text
show services rpm twamp client session

pe2-to-pe1      best-effort     10.100.249.2      10000 10.100.249.1      10000
pe2-to-pe1      video-af41      10.100.249.2      10001 10.100.249.1      10001
pe2-to-pe1      voice-ef        10.100.249.2      10002 10.100.249.1      10002
```

Using separate DSCP values means the probes experience the same queuing and scheduling as the real traffic they represent.

---

### Chassis & Interface Preparation

On MX routers, hardware-accelerated timestamping requires an inline services (`si-`) interface. This is **not optional** for production accuracy — it eliminates RE scheduling jitter from measurements.

```text
# Reserve bandwidth on the FPC for inline services
set chassis fpc 0 pic 0 inline-services bandwidth 1g

# Create the services interface with BOTH client and server tags
# Use unit 10+, never unit 0
set interfaces si-0/0/0 unit 10 rpm twamp-client family inet address 10.30.30.1/24
set interfaces si-0/0/0 unit 10 rpm twamp-server family inet address 10.30.30.1/24
```

> **Important:** The `rpm twamp-client` and `rpm twamp-server` statements are **mandatory** under the `si-` interface. Without them, the control plane has no service tags bound to the IFL and TWAMP sessions will not establish.

---

### Server (Reflector) Configuration — Line by Line

Both PE1 and PE2 run a TWAMP server to reflect probes from the other side. In managed mode, the server listens on TCP port 862 for control session establishment.

**PE1's server** (reflecting probes from PE2):

```text
set services rpm twamp server authentication-mode none
set services rpm twamp server port 862
set services rpm twamp server client-list pe2-client address 10.100.249.0/24
```

**PE2's server** (reflecting probes from PE1):

```text
set services rpm twamp server authentication-mode none
set services rpm twamp server port 862
set services rpm twamp server client-list pe1-client address 10.100.249.0/24
```

| Statement | What it does | Why it matters |
| :--- | :--- | :--- |
| `authentication-mode none` | No authentication required for incoming TWAMP sessions. | Standard for internal monitoring. Enable authentication if probes cross untrusted networks. |
| `port 862` | Server listens on TCP 862 for control session setup. | Standard TWAMP control port. Test session ports are negotiated dynamically. |
| `client-list ... address 10.100.249.0/24` | Only accepts connections from this subnet. | **Security boundary.** Only trusted sources can trigger the reflector. Use /32 for a single host, or a subnet if you have multiple PEs. |

> **Important:** The `client-list` is **mandatory** — without it, the server will not accept any connections. If you see sessions defined but zero probe-results, check that the client-list covers the sender's source address.

Note: We do **not** configure `light` on the server — managed mode is the default.

---

### Global Client Settings Explained

Before defining test sessions, you configure the **control connection** — the container that holds all sessions for a given peer. Both PE1 and PE2 get the same global settings.

**PE1's client** (probing PE2):

```text
set services rpm twamp client control-connection pe1-to-pe2 control-type managed
set services rpm twamp client control-connection pe1-to-pe2 target-address 10.100.249.2
set services rpm twamp client control-connection pe1-to-pe2 history-size 255
set services rpm twamp client control-connection pe1-to-pe2 moving-average-size 32
set services rpm twamp client control-connection pe1-to-pe2 persistent-results
set services rpm twamp client control-connection pe1-to-pe2 delegate-probes
set services rpm twamp client control-connection pe1-to-pe2 hardware-timestamping
```

| Statement | What it does | Why it matters |
| :--- | :--- | :--- |
| `control-type managed` | Uses standard TWAMP with TCP control plane. | Required when using `si-` interfaces on MX. |
| `target-address 10.100.249.2` | Sets the reflector IP at the control-connection level. | In managed mode, the target is configured globally — not per session. |
| `history-size 255` | Stores the last 255 probe results per session. | Enough data for trend analysis without consuming excessive memory. |
| `moving-average-size 32` | Calculates a moving average over the last 32 probes. | Smooths out individual spikes to reveal the real trend. |
| `persistent-results` | Keeps results visible between test iterations. | Without it, `show probe-results` can appear empty during gaps. |
| `delegate-probes` | Moves probe processing from RE to PFE (hardware). | Lower CPU impact, higher accuracy. |
| `hardware-timestamping` | Uses ASIC-level timestamps instead of software. | Eliminates RE scheduling jitter from measurements. |

---

### Voice Session (EF) — Line by Line

This session simulates voice traffic. It uses Expedited Forwarding (EF) DSCP and tight thresholds because voice is the most sensitive to delay and jitter.

```text
set services rpm twamp client control-connection pe1-to-pe2 test-session voice-ef source-address 10.100.249.1
set services rpm twamp client control-connection pe1-to-pe2 test-session voice-ef dscp-code-points ef
set services rpm twamp client control-connection pe1-to-pe2 test-session voice-ef probe-count 1000
set services rpm twamp client control-connection pe1-to-pe2 test-session voice-ef probe-interval 1
set services rpm twamp client control-connection pe1-to-pe2 test-session voice-ef iteration-interval 60
set services rpm twamp client control-connection pe1-to-pe2 test-session voice-ef thresholds rtt 50000
set services rpm twamp client control-connection pe1-to-pe2 test-session voice-ef thresholds jitter-egress 10000
```

| Statement | What it does | Why it matters |
| :--- | :--- | :--- |
| `source-address 10.100.249.1` | Sets the source IP of the probes. | Must match a locally configured address. |
| `dscp-code-points ef` | Marks probes with EF (DSCP 46). | Probes experience the same QoS treatment as real voice packets. |
| `probe-count 1000` | Sends 1000 packets per test iteration. | 1000 at 1-second interval = ~16 minutes per iteration. |
| `probe-interval 1` | Waits 1 second between each probe. | 1 second is standard. Lower values give finer granularity but consume more resources. |
| `iteration-interval 60` | Waits 60 seconds between iterations. | Prevents CPU saturation between iteration cycles. |
| `thresholds rtt 50000` | Traps if RTT exceeds 50,000 microseconds (50ms). | Voice becomes unusable above ~150ms RTT. 50ms gives early warning. |
| `thresholds jitter-egress 10000` | Traps if egress jitter exceeds 10ms. | Voice degrades noticeably above 30ms jitter. 10ms is a tight but realistic early-warning threshold. |

> **Note:** There is no `destination-port` or `target-address` in this session block. In managed mode, the target is inherited from the global control-connection and the port is dynamically negotiated via TCP.

---

### Video Session (AF41) — Line by Line

This session simulates video traffic. It uses AF41 DSCP and includes a `data-size` parameter to match typical video packet sizes.

```text
set services rpm twamp client control-connection pe1-to-pe2 test-session video-af41 source-address 10.100.249.1
set services rpm twamp client control-connection pe1-to-pe2 test-session video-af41 data-size 1200
set services rpm twamp client control-connection pe1-to-pe2 test-session video-af41 dscp-code-points af41
set services rpm twamp client control-connection pe1-to-pe2 test-session video-af41 probe-count 1000
set services rpm twamp client control-connection pe1-to-pe2 test-session video-af41 probe-interval 1
set services rpm twamp client control-connection pe1-to-pe2 test-session video-af41 iteration-interval 60
set services rpm twamp client control-connection pe1-to-pe2 test-session video-af41 thresholds rtt 80000
set services rpm twamp client control-connection pe1-to-pe2 test-session video-af41 thresholds jitter-egress 20000
```

| Statement | What it does | Why it matters |
| :--- | :--- | :--- |
| `data-size 1200` | Sets probe payload to 1200 bytes. | Video packets are larger than voice. Matching the size means probes traverse the same queue behavior as real video traffic. |
| `dscp-code-points af41` | Marks probes with AF41 (DSCP 34). | Matches the QoS class for real-time video. |
| `thresholds rtt 80000` | Traps at 80ms RTT. | Video is more tolerant than voice, so the threshold is higher. |
| `thresholds jitter-egress 20000` | Traps at 20ms jitter. | Video buffering absorbs some jitter, but 20ms+ is a warning sign. |

---

### Best Effort Session (BE) — Line by Line

This session measures the baseline — how the network treats traffic with no special QoS marking.

```text
set services rpm twamp client control-connection pe1-to-pe2 test-session best-effort source-address 10.100.249.1
set services rpm twamp client control-connection pe1-to-pe2 test-session best-effort dscp-code-points be
set services rpm twamp client control-connection pe1-to-pe2 test-session best-effort probe-count 1000
set services rpm twamp client control-connection pe1-to-pe2 test-session best-effort probe-interval 1
set services rpm twamp client control-connection pe1-to-pe2 test-session best-effort iteration-interval 60
set services rpm twamp client control-connection pe1-to-pe2 test-session best-effort thresholds rtt 150000
```

| Statement | What it does | Why it matters |
| :--- | :--- | :--- |
| `dscp-code-points be` | No QoS marking (DSCP 0). | Probes experience the default queue — best indication of congestion for bulk traffic. |
| `thresholds rtt 150000` | Traps at 150ms RTT. | BE traffic is more tolerant. 150ms catches severe congestion without alert fatigue. |
| No jitter threshold | BE traffic doesn't need jitter monitoring. | Jitter matters for real-time apps. BE is best-effort — if RTT is healthy, jitter is less relevant. |

---

### Complete Configuration: PE1

```text
# ============================================
# PE1 - Chassis & Inline Services Interface
# ============================================
set chassis fpc 0 pic 0 inline-services bandwidth 1g
set interfaces si-0/0/0 unit 10 rpm twamp-client family inet address 10.30.30.1/24
set interfaces si-0/0/0 unit 10 rpm twamp-server family inet address 10.30.30.1/24

# ============================================
# PE1 - TWAMP Server (Reflector)
# Reflects probes from PE2 (10.100.249.0/24)
# ============================================
set services rpm twamp server authentication-mode none
set services rpm twamp server port 862
set services rpm twamp server client-list pe2-client address 10.100.249.0/24

# ============================================
# PE1 - TWAMP Client (Controller)
# Probes PE2 at 10.100.249.2
# ============================================

# --- Global Client Settings ---
set services rpm twamp client control-connection pe1-to-pe2 control-type managed
set services rpm twamp client control-connection pe1-to-pe2 target-address 10.100.249.2
set services rpm twamp client control-connection pe1-to-pe2 history-size 255
set services rpm twamp client control-connection pe1-to-pe2 moving-average-size 32
set services rpm twamp client control-connection pe1-to-pe2 persistent-results
set services rpm twamp client control-connection pe1-to-pe2 delegate-probes
set services rpm twamp client control-connection pe1-to-pe2 hardware-timestamping

# --- Voice Session (EF) ---
set services rpm twamp client control-connection pe1-to-pe2 test-session voice-ef source-address 10.100.249.1
set services rpm twamp client control-connection pe1-to-pe2 test-session voice-ef dscp-code-points ef
set services rpm twamp client control-connection pe1-to-pe2 test-session voice-ef probe-count 1000
set services rpm twamp client control-connection pe1-to-pe2 test-session voice-ef probe-interval 1
set services rpm twamp client control-connection pe1-to-pe2 test-session voice-ef iteration-interval 60
set services rpm twamp client control-connection pe1-to-pe2 test-session voice-ef thresholds rtt 50000
set services rpm twamp client control-connection pe1-to-pe2 test-session voice-ef thresholds jitter-egress 10000

# --- Video Session (AF41) ---
set services rpm twamp client control-connection pe1-to-pe2 test-session video-af41 source-address 10.100.249.1
set services rpm twamp client control-connection pe1-to-pe2 test-session video-af41 data-size 1200
set services rpm twamp client control-connection pe1-to-pe2 test-session video-af41 dscp-code-points af41
set services rpm twamp client control-connection pe1-to-pe2 test-session video-af41 probe-count 1000
set services rpm twamp client control-connection pe1-to-pe2 test-session video-af41 probe-interval 1
set services rpm twamp client control-connection pe1-to-pe2 test-session video-af41 iteration-interval 60
set services rpm twamp client control-connection pe1-to-pe2 test-session video-af41 thresholds rtt 80000
set services rpm twamp client control-connection pe1-to-pe2 test-session video-af41 thresholds jitter-egress 20000

# --- Best Effort Session (BE) ---
set services rpm twamp client control-connection pe1-to-pe2 test-session best-effort source-address 10.100.249.1
set services rpm twamp client control-connection pe1-to-pe2 test-session best-effort dscp-code-points be
set services rpm twamp client control-connection pe1-to-pe2 test-session best-effort probe-count 1000
set services rpm twamp client control-connection pe1-to-pe2 test-session best-effort probe-interval 1
set services rpm twamp client control-connection pe1-to-pe2 test-session best-effort iteration-interval 60
set services rpm twamp client control-connection pe1-to-pe2 test-session best-effort thresholds rtt 150000
```

---

### Complete Configuration: PE2

```text
# ============================================
# PE2 - Chassis & Inline Services Interface
# ============================================
set chassis fpc 0 pic 0 inline-services bandwidth 1g
set interfaces si-0/0/0 unit 10 rpm twamp-client family inet address 10.30.30.2/24
set interfaces si-0/0/0 unit 10 rpm twamp-server family inet address 10.30.30.2/24

# ============================================
# PE2 - TWAMP Server (Reflector)
# Reflects probes from PE1 (10.100.249.0/24)
# ============================================
set services rpm twamp server authentication-mode none
set services rpm twamp server port 862
set services rpm twamp server client-list pe1-client address 10.100.249.0/24

# ============================================
# PE2 - TWAMP Client (Controller)
# Probes PE1 at 10.100.249.1
# ============================================

# --- Global Client Settings ---
set services rpm twamp client control-connection pe2-to-pe1 control-type managed
set services rpm twamp client control-connection pe2-to-pe1 target-address 10.100.249.1
set services rpm twamp client control-connection pe2-to-pe1 history-size 255
set services rpm twamp client control-connection pe2-to-pe1 moving-average-size 32
set services rpm twamp client control-connection pe2-to-pe1 persistent-results
set services rpm twamp client control-connection pe2-to-pe1 delegate-probes
set services rpm twamp client control-connection pe2-to-pe1 hardware-timestamping

# --- Voice Session (EF) ---
set services rpm twamp client control-connection pe2-to-pe1 test-session voice-ef source-address 10.100.249.2
set services rpm twamp client control-connection pe2-to-pe1 test-session voice-ef dscp-code-points ef
set services rpm twamp client control-connection pe2-to-pe1 test-session voice-ef probe-count 1000
set services rpm twamp client control-connection pe2-to-pe1 test-session voice-ef probe-interval 1
set services rpm twamp client control-connection pe2-to-pe1 test-session voice-ef iteration-interval 60
set services rpm twamp client control-connection pe2-to-pe1 test-session voice-ef thresholds rtt 50000
set services rpm twamp client control-connection pe2-to-pe1 test-session voice-ef thresholds jitter-egress 10000

# --- Video Session (AF41) ---
set services rpm twamp client control-connection pe2-to-pe1 test-session video-af41 source-address 10.100.249.2
set services rpm twamp client control-connection pe2-to-pe1 test-session video-af41 data-size 1200
set services rpm twamp client control-connection pe2-to-pe1 test-session video-af41 dscp-code-points af41
set services rpm twamp client control-connection pe2-to-pe1 test-session video-af41 probe-count 1000
set services rpm twamp client control-connection pe2-to-pe1 test-session video-af41 probe-interval 1
set services rpm twamp client control-connection pe2-to-pe1 test-session video-af41 iteration-interval 60
set services rpm twamp client control-connection pe2-to-pe1 test-session video-af41 thresholds rtt 80000
set services rpm twamp client control-connection pe2-to-pe1 test-session video-af41 thresholds jitter-egress 20000

# --- Best Effort Session (BE) ---
set services rpm twamp client control-connection pe2-to-pe1 test-session best-effort source-address 10.100.249.2
set services rpm twamp client control-connection pe2-to-pe1 test-session best-effort dscp-code-points be
set services rpm twamp client control-connection pe2-to-pe1 test-session best-effort probe-count 1000
set services rpm twamp client control-connection pe2-to-pe1 test-session best-effort probe-interval 1
set services rpm twamp client control-connection pe2-to-pe1 test-session best-effort iteration-interval 60
set services rpm twamp client control-connection pe2-to-pe1 test-session best-effort thresholds rtt 150000
```

---

### Verification Commands

#### Check client sessions

```text
# Show all active client sessions and their negotiated ports
show services rpm twamp client session

# Show results for a specific session
show services rpm twamp client probe-results test-session voice-ef
```

Expected output for healthy sessions:

```text
pe1-to-pe2      best-effort     10.100.249.1      10000 10.100.249.2      10000
pe1-to-pe2      video-af41      10.100.249.1      10001 10.100.249.2      10001
pe1-to-pe2      voice-ef        10.100.249.1      10002 10.100.249.2      10002
```

Notice the dynamically negotiated reflector ports (10000, 10001, 10002) — these are assigned by the server during TCP control session setup, **not** hardcoded.

#### Check server sessions

```text
# Show all reflected sessions
show services rpm twamp server session
```

This tells you the reflector is receiving and bouncing back probes. If this is empty but the client shows sessions, check the server `client-list`.

#### The most important command for slowness

```text
show services rpm twamp client probe-results
```

This is where you find the real data. Look for:

- **RTT (Round-Trip Time):** Total time for a packet to travel to the reflector and back, in microseconds.
- **Egress Jitter:** Variation in delay on the outbound path. High values indicate congestion toward the reflector.
- **Ingress Jitter:** Variation on the return path. High values indicate congestion coming back.
- **Stddev (Standard Deviation):** If this is high (>15ms), the network is jittery regardless of the average RTT.

#### Quick filters

```text
# Show only active (non-gap) results
show services rpm twamp client probe-results | match "Session|State|RTT|Jitter"

# Check if thresholds have been crossed
show services rpm twamp client probe-results | match "threshold"

# Verify a specific control connection
show services rpm twamp client session control-connection pe1-to-pe2
```

---

### How to Read the Metrics: The "Sick Network" Checklist

| Metric | Green | Yellow (Sick) | Red (Down) |
| :--- | :--- | :--- | :--- |
| **RTT** | < 50ms | 50–150ms | > 150ms or 100% loss |
| **Jitter** | < 5ms | 5–30ms | > 30ms |
| **Stddev** | < 5ms | 5–20ms | > 20ms |
| **Packet Loss** | 0% | 0% (but high jitter) | > 0% |

**Key insight:** A network can be **Yellow without any packet loss**. High jitter alone is enough to make voice choppy and video buffer. This is why ping (which only measures loss and RTT) misses the real problem — TWAMP catches the jitter that ping ignores.

**Pro-Tip:** If the `show session` command is empty but `probe-results` still shows data, the device is still "Connected." Do not remove it from your inventory unless both commands return empty for more than 5 minutes.

---

### Troubleshooting Common Issues

| Symptom | Likely Cause | Fix |
| :--- | :--- | :--- |
| `show session` returns empty | Router is in a gap between iterations | Check `probe-results` instead. Add `persistent-results` to config. |
| Session defined but 0% probes returned | Server `client-list` doesn't cover source IP | Update `client-list` to include the sender's subnet or /32. |
| `Only managed control-type is allowed under si-` | MX microcode restriction on inline services interfaces. | Change client connection to `control-type managed`. Remove `light` from server config. |
| `destination-port requires light control-type` | Hardcoded destination ports conflict with managed dynamic port negotiation. | Delete `destination-port` from individual sessions. Let TCP negotiate ports dynamically. |
| `twamp-client is not configured under si-...` | Control plane requires explicit service tags bound to the IFL. | Add `rpm twamp-client` and `rpm twamp-server` under your `interfaces si-0/0/0 unit 10` block. |
| High RTT but no congestion | RE timestamping includes CPU scheduling delays | Enable `delegate-probes` and `hardware-timestamping`. |
| Probes work one direction only | One side's server missing or misconfigured | Verify server config on the non-working side. Check `client-list`. |

---

### Next Steps

- **Export metrics** to Prometheus or Grafana via Junos Telemetry Interface (gNMI/gRPC).
- **Configure trap groups** to get SNMP alerts when thresholds are crossed.
- **Add `twampy`** (open-source Python tool by Nokia) to validate interoperability with non-Juniper devices.
