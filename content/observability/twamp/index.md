+++
title = 'Beyond the Ping: Mastering TWAMP on Juniper MX'
date = 2026-05-30T12:00:00-04:00
draft = false
tags = ["TWAMP", "Observability", "Measurement", "Juniper"]
summary = 'A production TWAMP-Light deployment on Juniper MX — three QoS classes (Voice, Video, Best Effort), bidirectional measurement, line-by-line config explanation, and verification commands.'
+++

### Why Ping Isn't Enough

In modern service provider networks, "Down" is easy to detect. The real challenge is **"Sick but Not Dead."** These are the gray failures — micro-bursts, jitter spikes, and intermittent slowness — that frustrate users but leave traditional monitoring tools green.

**Two-Way Active Measurement Protocol (TWAMP)** is the industry-standard answer. This guide walks through a **real production deployment** on Juniper MX routers: bidirectional measurement across three QoS classes (Voice, Video, Best Effort), with every config line explained.

---

### TWAMP vs. TWAMP-Light vs. STAMP

| Feature | Standard TWAMP | TWAMP-Light / STAMP |
| :--- | :--- | :--- |
| **Control Plane** | Uses TCP Port 862 for handshaking. | **No Control Plane.** Only UDP probes. |
| **Statefulness** | High overhead; sessions can flap if TCP lags. | Low overhead; stateless and resilient. |
| **Evolution** | Defined in RFC 5357. | STAMP (RFC 8762) is the modern version of Light. |
| **"Sick" Network** | May fail if packet loss kills the TCP session. | **Keeps probing** even during 50% packet loss. |

**The Verdict:** For high-precision slowness detection on Juniper, **TWAMP-Light** is superior because it remains active even when the network is degraded. This entire guide uses `control-type light`.

---

### The Four TWAMP Roles (Simplified)

TWAMP defines four logical roles, but in practice you only need **two devices**:

- **Controller** (Control-Client + Session-Sender) — initiates probes and collects metrics.
- **Responder** (Server + Session-Reflector) — receives probes and reflects them back with timestamps.

Both devices run a **client** (to send probes) and a **server** (to reflect probes from the other side). This gives you bidirectional visibility.

---

### Our Lab Topology

```text
    PE1 (10.100.249.1)  <---------->  PE2 (10.100.249.3)
    AS 65001                              AS 65001

    PE1 sends probes to PE2 (Voice, Video, BE)
    PE2 sends probes to PE1 (Voice, Video, BE)
    Both act as client AND server simultaneously
```

We create **three test sessions per direction**, each matching a real traffic class:

| Session | DSCP | Destination Port | Purpose |
| :--- | :--- | :--- | :--- |
| `voice-ef` | EF (46) | 862 | Detect jitter and latency in voice traffic |
| `video-af41` | AF41 (34) | 862 | Detect slowness in video streaming |
| `best-effort` | BE (0) | 862 | Baseline for all other traffic |

> **Important note on destination ports:** In TWAMP Light, the server listens on a single UDP port (configured with `set services rpm twamp server port 862`). The client **must** send all test sessions to that same port. The protocol distinguishes sessions using source port, DSCP, data size, and sequence numbers — **not** the destination port. Using separate destination ports (e.g., 863, 864) will cause the server to ignore those probes, resulting in 100% loss. This is a common misconfiguration, as seen in the failure analysis below.

Using separate DSCP values means the probes experience the same queuing and scheduling as the real traffic they represent.

---

### Global Client Settings Explained

Before defining test sessions, you configure the **control connection** — the container that holds all sessions for a given peer. Both PE1 and PE2 get the same global settings.

```text
set services rpm twamp client control-connection pe1-to-pe2 control-type light
set services rpm twamp client control-connection pe1-to-pe2 history-size 255
set services rpm twamp client control-connection pe1-to-pe2 moving-average-size 32
```

| Statement | What it does | Why it matters |
| :--- | :--- | :--- |
| `control-type light` | Uses TWAMP-Light (no TCP control plane). | Stateless and resilient — keeps probing even during degradation. |
| `history-size 255` | Stores the last 255 probe results per session. | Enough data for trend analysis without consuming excessive memory. Increase to 512 or 1000 for long-term dashboards. |
| `moving-average-size 32` | Calculates a moving average over the last 32 probes. | Smooths out individual spikes to reveal the real trend. 32 is a good balance between responsiveness and stability. |

> **Pro tip:** Add `persistent-results` to keep results visible between test iterations. Without it, the `show probe-results` output can appear empty during gaps.

```text
set services rpm twamp client control-connection pe1-to-pe2 persistent-results
```

---

### Voice Session (EF) — Line by Line

This session simulates voice traffic. It uses Expedited Forwarding (EF) DSCP and tight thresholds because voice is the most sensitive to delay and jitter.

```text
set services rpm twamp client control-connection pe1-to-pe2 test-session voice-ef source-address 10.100.249.1
set services rpm twamp client control-connection pe1-to-pe2 test-session voice-ef target-address 10.100.249.3
set services rpm twamp client control-connection pe1-to-pe2 test-session voice-ef destination-port 862
set services rpm twamp client control-connection pe1-to-pe2 test-session voice-ef dscp-code-points ef
set services rpm twamp client control-connection pe1-to-pe2 test-session voice-ef probe-count 1000
set services rpm twamp client control-connection pe1-to-pe2 test-session voice-ef probe-interval 1
set services rpm twamp client control-connection pe1-to-pe2 test-session voice-ef iteration-interval 60
set services rpm twamp client control-connection pe1-to-pe2 test-session voice-ef thresholds rtt 50000
set services rpm twamp client control-connection pe1-to-pe2 test-session voice-ef thresholds jitter-egress 10000
```

| Statement | What it does | Why it matters |
| :--- | :--- | :--- |
| `source-address 10.100.249.1` | Sets the source IP of the probes. | Must match a locally configured address (typically a loopback). |
| `target-address 10.100.249.3` | Sets the destination IP (the reflector). | This is the remote PE's address (PE2). |
| `destination-port 862` | UDP port the probes are sent to. | Must match the server's listening port. In TWAMP Light, **all** sessions use the same port. |
| `dscp-code-points ef` | Marks probes with EF (DSCP 46). | Probes experience the same QoS treatment as real voice packets in your policy. |
| `probe-count 1000` | Sends 1000 packets per test iteration. | More probes = more accurate averages. 1000 at 1-second interval = ~16 minutes per iteration. |
| `probe-interval 1` | Waits 1 second between each probe. | 1 second is standard. Lower values (0.1) give finer granularity but consume more resources. |
| `iteration-interval 60` | Waits 60 seconds between iterations. | After 1000 probes complete, pause 60 seconds, then start the next iteration. Prevents CPU saturation. |
| `thresholds rtt 50000` | Traps if RTT exceeds 50,000 microseconds (50ms). | Voice becomes unusable above ~150ms RTT. 50ms gives early warning. |
| `thresholds jitter-egress 10000` | Traps if egress jitter exceeds 10,000 microseconds (10ms). | Voice degrades noticeably above 30ms jitter. 10ms is a tight but realistic early-warning threshold. |

---

### Video Session (AF41) — Line by Line

This session simulates video traffic. It uses AF41 DSCP and includes a `data-size` parameter to match typical video packet sizes.

```text
set services rpm twamp client control-connection pe1-to-pe2 test-session video-af41 source-address 10.100.249.1
set services rpm twamp client control-connection pe1-to-pe2 test-session video-af41 target-address 10.100.249.3
set services rpm twamp client control-connection pe1-to-pe2 test-session video-af41 destination-port 862
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
| `target-address 10.100.249.3` | Sets the destination IP (PE2). | Same reflector as the voice session — PE2. |
| `destination-port 862` | Same port as all other sessions. | In TWAMP Light, the server is statically bound to a single port. All sessions must target it. |
| `data-size 1200` | Sets probe payload to 1200 bytes. | Video packets are larger than voice. Matching the size means probes traverse the same queue behavior as real video traffic. Without this, the default small probes may skip fragmentation or queue effects. |
| `dscp-code-points af41` | Marks probes with AF41 (DSCP 34). | Matches the QoS class for real-time video. |
| `thresholds rtt 80000` | Traps at 80ms RTT. | Video is more tolerant than voice, so the threshold is higher. |
| `thresholds jitter-egress 20000` | Traps at 20ms jitter. | Video buffering absorbs some jitter, but 20ms+ is a warning sign. |

---

### Best Effort Session (BE) — Line by Line

This session measures the baseline — how the network treats traffic with no special QoS marking.

```text
set services rpm twamp client control-connection pe1-to-pe2 test-session best-effort source-address 10.100.249.1
set services rpm twamp client control-connection pe1-to-pe2 test-session best-effort target-address 10.100.249.3
set services rpm twamp client control-connection pe1-to-pe2 test-session best-effort destination-port 862
set services rpm twamp client control-connection pe1-to-pe2 test-session best-effort dscp-code-points be
set services rpm twamp client control-connection pe1-to-pe2 test-session best-effort probe-count 1000
set services rpm twamp client control-connection pe1-to-pe2 test-session best-effort probe-interval 1
set services rpm twamp client control-connection pe1-to-pe2 test-session best-effort iteration-interval 60
set services rpm twamp client control-connection pe1-to-pe2 test-session best-effort thresholds rtt 150000
```

| Statement | What it does | Why it matters |
| :--- | :--- | :--- |
| `target-address 10.100.249.3` | Sets the destination IP (PE2). | Same reflector as the other sessions. |
| `destination-port 862` | Same port as all other sessions. | The server only listens on one port. Using a different port (e.g., 864) causes the server to silently drop the probes. |
| `dscp-code-points be` | No QoS marking (DSCP 0). | Probes experience the default queue — best indication of congestion for bulk traffic. |
| `thresholds rtt 150000` | Traps at 150ms RTT. | BE traffic is more tolerant. 150ms catches severe congestion without alert fatigue. |
| No jitter threshold | BE traffic doesn't need jitter monitoring. | Jitter matters for real-time apps. BE is best-effort — if RTT is healthy, jitter is less relevant. |

---

### Server (Reflector) Configuration — Line by Line

Both PE1 and PE2 run a TWAMP server to reflect probes from the other side. Each server must allow the remote peer's source address.

**PE1's server** (reflecting probes from PE2):

```text
set services rpm twamp server authentication-mode none
set services rpm twamp server port 862
set services rpm twamp server client-list pe2-client address 10.100.249.0/24
set services rpm twamp server light
```

**PE2's server** (reflecting probes from PE1):

```text
set services rpm twamp server authentication-mode none
set services rpm twamp server port 862
set services rpm twamp server client-list pe1-client address 10.100.249.0/24
set services rpm twamp server light
```

| Statement | What it does | Why it matters |
| :--- | :--- | :--- |
| `authentication-mode none` | No authentication required for incoming TWAMP sessions. | Standard for internal monitoring. Enable authentication if probes cross untrusted networks. |
| `port 862` | Server listens on UDP 862. | Default TWAMP port. The client's `destination-port` must match this. |
| `client-list ... address 10.100.249.0/24` | Only accepts probes from this subnet. | **Security boundary.** Only trusted sources can trigger the reflector. Use /32 for a single host, or a subnet if you have multiple PEs. |
| `light` | Runs in TWAMP-Light mode (no TCP control plane). | Must match the client's `control-type light`. |

> **Important:** The `client-list` is **mandatory** — without it, the server will not accept any probes. If you see sessions defined but zero probe-results, check that the client-list covers the sender's source address.

---

### Chassis Preparation (If Using Inline Timestamping)

On MX routers, you can offload timestamping to the hardware for maximum accuracy. This is optional — many deployments use Microkernel-based timestamping without an `si-` interface.

```text
# Reserve bandwidth on the FPC for inline services
set chassis fpc 0 pic 0 inline-services bandwidth 1g

# Create the services interface (use unit 10+, never unit 0)
set interfaces si-0/0/0 unit 10 rpm twamp-client family inet address 10.30.30.1/24
```

For additional accuracy, delegate probes and enable hardware timestamps on each control connection:

```text
set services rpm twamp client control-connection pe1-to-pe2 delegate-probes
set services rpm twamp client control-connection pe1-to-pe2 hardware-timestamping
```

| Statement | What it does |
| :--- | :--- |
| `delegate-probes` | Moves probe processing from the RE (CPU) to the PFE (hardware). Lower CPU impact, higher accuracy. |
| `hardware-timestamping` | Uses ASIC-level timestamps instead of software timestamps. Eliminates RE scheduling jitter from measurements. |

---

### Complete Configuration: PE1

```text
# ============================================
# PE1 - TWAMP Client (Controller)
# Probes PE2 at 10.100.249.3
# ============================================

# --- Global Client Settings ---
set services rpm twamp client control-connection pe1-to-pe2 control-type light
set services rpm twamp client control-connection pe1-to-pe2 history-size 255
set services rpm twamp client control-connection pe1-to-pe2 moving-average-size 32
set services rpm twamp client control-connection pe1-to-pe2 persistent-results

# --- Voice Session (EF) ---
set services rpm twamp client control-connection pe1-to-pe2 test-session voice-ef source-address 10.100.249.1
set services rpm twamp client control-connection pe1-to-pe2 test-session voice-ef target-address 10.100.249.3
set services rpm twamp client control-connection pe1-to-pe2 test-session voice-ef destination-port 862
set services rpm twamp client control-connection pe1-to-pe2 test-session voice-ef dscp-code-points ef
set services rpm twamp client control-connection pe1-to-pe2 test-session voice-ef probe-count 1000
set services rpm twamp client control-connection pe1-to-pe2 test-session voice-ef probe-interval 1
set services rpm twamp client control-connection pe1-to-pe2 test-session voice-ef iteration-interval 60
set services rpm twamp client control-connection pe1-to-pe2 test-session voice-ef thresholds rtt 50000
set services rpm twamp client control-connection pe1-to-pe2 test-session voice-ef thresholds jitter-egress 10000

# --- Video Session (AF41) ---
set services rpm twamp client control-connection pe1-to-pe2 test-session video-af41 source-address 10.100.249.1
set services rpm twamp client control-connection pe1-to-pe2 test-session video-af41 target-address 10.100.249.3
set services rpm twamp client control-connection pe1-to-pe2 test-session video-af41 destination-port 862
set services rpm twamp client control-connection pe1-to-pe2 test-session video-af41 data-size 1200
set services rpm twamp client control-connection pe1-to-pe2 test-session video-af41 dscp-code-points af41
set services rpm twamp client control-connection pe1-to-pe2 test-session video-af41 probe-count 1000
set services rpm twamp client control-connection pe1-to-pe2 test-session video-af41 probe-interval 1
set services rpm twamp client control-connection pe1-to-pe2 test-session video-af41 iteration-interval 60
set services rpm twamp client control-connection pe1-to-pe2 test-session video-af41 thresholds rtt 80000
set services rpm twamp client control-connection pe1-to-pe2 test-session video-af41 thresholds jitter-egress 20000

# --- Best Effort Session (BE) ---
set services rpm twamp client control-connection pe1-to-pe2 test-session best-effort source-address 10.100.249.1
set services rpm twamp client control-connection pe1-to-pe2 test-session best-effort target-address 10.100.249.3
set services rpm twamp client control-connection pe1-to-pe2 test-session best-effort destination-port 862
set services rpm twamp client control-connection pe1-to-pe2 test-session best-effort dscp-code-points be
set services rpm twamp client control-connection pe1-to-pe2 test-session best-effort probe-count 1000
set services rpm twamp client control-connection pe1-to-pe2 test-session best-effort probe-interval 1
set services rpm twamp client control-connection pe1-to-pe2 test-session best-effort iteration-interval 60
set services rpm twamp client control-connection pe1-to-pe2 test-session best-effort thresholds rtt 150000

# ============================================
# PE1 - TWAMP Server (Reflector)
# Reflects probes from PE2 (10.100.249.0/24)
# ============================================
set services rpm twamp server authentication-mode none
set services rpm twamp server port 862
set services rpm twamp server client-list pe2-client address 10.100.249.0/24
set services rpm twamp server light
```

---

### Complete Configuration: PE2

```text
# ============================================
# PE2 - TWAMP Client (Controller)
# Probes PE1 at 10.100.249.1
# ============================================

# --- Global Client Settings ---
set services rpm twamp client control-connection pe2-to-pe1 control-type light
set services rpm twamp client control-connection pe2-to-pe1 history-size 255
set services rpm twamp client control-connection pe2-to-pe1 moving-average-size 32
set services rpm twamp client control-connection pe2-to-pe1 persistent-results

# --- Voice Session (EF) ---
set services rpm twamp client control-connection pe2-to-pe1 test-session voice-ef source-address 10.100.249.3
set services rpm twamp client control-connection pe2-to-pe1 test-session voice-ef target-address 10.100.249.1
set services rpm twamp client control-connection pe2-to-pe1 test-session voice-ef destination-port 862
set services rpm twamp client control-connection pe2-to-pe1 test-session voice-ef dscp-code-points ef
set services rpm twamp client control-connection pe2-to-pe1 test-session voice-ef probe-count 1000
set services rpm twamp client control-connection pe2-to-pe1 test-session voice-ef probe-interval 1
set services rpm twamp client control-connection pe2-to-pe1 test-session voice-ef iteration-interval 60
set services rpm twamp client control-connection pe2-to-pe1 test-session voice-ef thresholds rtt 50000
set services rpm twamp client control-connection pe2-to-pe1 test-session voice-ef thresholds jitter-egress 10000

# --- Video Session (AF41) ---
set services rpm twamp client control-connection pe2-to-pe1 test-session video-af41 source-address 10.100.249.3
set services rpm twamp client control-connection pe2-to-pe1 test-session video-af41 target-address 10.100.249.1
set services rpm twamp client control-connection pe2-to-pe1 test-session video-af41 destination-port 862
set services rpm twamp client control-connection pe2-to-pe1 test-session video-af41 data-size 1200
set services rpm twamp client control-connection pe2-to-pe1 test-session video-af41 dscp-code-points af41
set services rpm twamp client control-connection pe2-to-pe1 test-session video-af41 probe-count 1000
set services rpm twamp client control-connection pe2-to-pe1 test-session video-af41 probe-interval 1
set services rpm twamp client control-connection pe2-to-pe1 test-session video-af41 iteration-interval 60
set services rpm twamp client control-connection pe2-to-pe1 test-session video-af41 thresholds rtt 80000
set services rpm twamp client control-connection pe2-to-pe1 test-session video-af41 thresholds jitter-egress 20000

# --- Best Effort Session (BE) ---
set services rpm twamp client control-connection pe2-to-pe1 test-session best-effort source-address 10.100.249.3
set services rpm twamp client control-connection pe2-to-pe1 test-session best-effort target-address 10.100.249.1
set services rpm twamp client control-connection pe2-to-pe1 test-session best-effort destination-port 862
set services rpm twamp client control-connection pe2-to-pe1 test-session best-effort dscp-code-points be
set services rpm twamp client control-connection pe2-to-pe1 test-session best-effort probe-count 1000
set services rpm twamp client control-connection pe2-to-pe1 test-session best-effort probe-interval 1
set services rpm twamp client control-connection pe2-to-pe1 test-session best-effort iteration-interval 60
set services rpm twamp client control-connection pe2-to-pe1 test-session best-effort thresholds rtt 150000

# ============================================
# PE2 - TWAMP Server (Reflector)
# Reflects probes from PE1 (10.100.249.0/24)
# ============================================
set services rpm twamp server authentication-mode none
set services rpm twamp server port 862
set services rpm twamp server client-list pe1-client address 10.100.249.0/24
set services rpm twamp server light
```

---

### Verification Commands

#### Check client sessions

```text
# Show all active client sessions
show services rpm twamp client session

# Show results for a specific session
show services rpm twamp client probe-results test-session voice-ef
```

Expected output for a healthy session:

```text
Session name: voice-ef
  Control connection: pe1-to-pe2
  State: Active
  Probe count: 1000
  Probe interval: 1
  Source address: 10.100.249.1
  Target address: 10.100.249.3
  Destination port: 862
```

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
| Session flaps up and down | TCP control plane instability (standard TWAMP) | Switch to `control-type light`. |
| High RTT but no congestion | RE timestamping includes CPU scheduling delays | Enable `delegate-probes` and `hardware-timestamping`. |
| Probes work one direction only | One side's server missing or misconfigured | Verify server config on the non-working side. Check `client-list`. |
| Some test sessions from PE1 show 100% loss while reverse direction works | Client uses different destination ports (e.g., 863, 864) but server listens only on 862 | Set all test sessions on the client to use the server's listening port (e.g., `862`). In TWAMP Light there is no control connection — the server is statically bound to a single port. |

---

### Next Steps

- **Export metrics** to Prometheus or Grafana via Junos Telemetry Interface (gNMI/gRPC).
- **Configure trap groups** to get SNMP alerts when thresholds are crossed.
- **Add `twampy`** (open-source Python tool by Nokia) to validate interoperability with non-Juniper devices.
