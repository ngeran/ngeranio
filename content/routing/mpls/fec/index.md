+++
title = 'Forwarding Equivalence Class'
date = 2025-05-28T17:43:38-04:00
draft = true
tags = ["MPLS","FEC","ldp","Routing","Juniper"]
featured_image = 'featured.png'
summary = 'An FEC is a group of packets that are forwarded the same way through an MPLS network'

+++

### Forwarding Equivalence Class

**Forwarding Equivalence Class (FEC)** is a fundamental concept in MPLS  is
essentially a classification of packets that are treated identically by the
MPLS network. The packets share the same forwarding treatment in terms of
path, priority, or other network policies.

#### Key Characteristics of FEC:
- **Definition**: An FEC is a group of packets that are forwarded in the same way (e.g., same destination, QoS, or path).
- **Label Mapping**: Each FEC is associated with a unique MPLS label at each router, stored in the Label Forwarding Information Base (LFIB).
- **Examples of FEC**:
  - Packets destined for the same IP subnet (e.g., 192.168.1.0/24).
  - Packets belonging to a specific VPN.
  - Packets requiring the same traffic engineering constraints (e.g., low-latency path).
- **Role in MPLS**: FECs allow routers to group packets for consistent treatment, enabling scalable and efficient forwarding.

#### MPLS Components Related to FEC:
- **Label Edge Router (LER)**: Ingress and egress routers that assign or remove MPLS labels.
- **Label Switch Router (LSR)**: Core routers that forward packets based on labels.
- **Label Switched Path (LSP)**: The path a packet takes through the MPLS network, determined by the FEC and labels.
- **Label Distribution Protocol (LDP)**: A protocol used to distribute labels and map them to FECs among routers.
- **LFIB**: The table used by LSRs to map incoming labels to outgoing labels and interfaces.

#### Packet Flow in MPLS with FEC:
1. **Ingress LER (Label Push)**:
   - The ingress LER receives an IP packet and classifies it into an FEC based on attributes like destination IP, QoS, or VPN.
   - It assigns an MPLS label to the packet based on the FEC and forwards it to the next hop along the LSP.
2. **Core LSR (Label Swap)**:
   - Core LSRs receive the labeled packet, look up the label in their LFIB, and swap it with a new label for the next hop.
   - The packet is forwarded without inspecting the IP header, improving efficiency.
3. **Egress LER (Label Pop)**:
   - The egress LER removes the MPLS label (label popping) and forwards the packet as a regular IP packet to its destination.

#### Benefits of FEC in MPLS:
- **Efficiency**: Reduces IP header lookups, speeding up packet forwarding.
- **Scalability**: Groups packets into FECs, simplifying routing decisions.
- **Flexibility**: Supports advanced features like traffic engineering, QoS, and VPNs.
- **Fast Rerouting**: Enables quick path recovery by precomputing alternate LSPs for an FEC.

### Packet Flow Diagram and Explanation

```
# MPLS Packet Flow Diagram

## Network Topology
[IP Packet] --> [Ingress LER] --> [LSR 1] --> [LSR 2] --> [Egress LER] --> [Destination]

## Packet Flow Steps
1. Ingress LER (R1):
   - Input: IP Packet (Dest: 10.0.0.1)
   - Classifies into FEC (e.g., Dest IP 10.0.0.0/24)
   - Action: Push Label (Label 100)
   - Output: Labeled Packet (Label 100)

2. LSR 1 (R2):
   - Input: Labeled Packet (Label 100)
   - Looks up LFIB: Label 100 -> Swap to Label 200, Forward to R3
   - Action: Swap Label
   - Output: Labeled Packet (Label 200)

3. LSR 2 (R3):
   - Input: Labeled Packet (Label 200)
   - Looks up LFIB: Label 200 -> Swap to Label 300, Forward to R4
   - Action: Swap Label
   - Output: Labeled Packet (Label 300)

4. Egress LER (R4):
   - Input: Labeled Packet (Label 300)
   - Looks up LFIB: Label 300 -> Pop Label
   - Action: Remove Label
   - Output: IP Packet (Dest: 10.0.0.1)

## LFIB Tables (Simplified)
R1 (Ingress LER):
| FEC            | Label | Action | Next Hop |
|----------------|-------|--------|----------|
| 10.0.0.0/24    | 100   | Push   | R2       |

R2 (LSR 1):
| In Label | Out Label | Action | Next Hop |
|----------|-----------|--------|----------|
| 100      | 200       | Swap   | R3       |

R3 (LSR 2):
| In Label | Out Label | Action | Next Hop |
|----------|-----------|--------|----------|
| 200      | 300       | Swap   | R4       |

R4 (Egress LER):
| In Label | Action | Next Hop     |
|----------|--------|--------------|
| 300      | Pop    | 10.0.0.1     |
```


### Explanation of Packet Flow

1. **Ingress LER (R1)**:
   - An IP packet arrives with a destination IP (e.g., 10.0.0.1).
   - R1 classifies the packet into an FEC based on its destination (e.g., FEC for 10.0.0.0/24).
   - R1 consults its LFIB, assigns Label 100 to the packet (label push), and forwards it to LSR 1 (R2).

2. **LSR 1 (R2)**:
   - R2 receives the packet with Label 100.
   - It looks up Label 100 in its LFIB, swaps it with Label 200, and forwards the packet to LSR 2 (R3).
   - No IP header inspection is needed, making the process fast.

3. **LSR 2 (R3)**:
   - R3 receives the packet with Label 200.
   - It swaps Label 200 with Label 300 based on its LFIB and forwards the packet to the egress LER (R4).

4. **Egress LER (R4)**:
   - R4 receives the packet with Label 300.
   - Its LFIB indicates that Label 300 should be popped, revealing the original IP packet.
   - The IP packet is forwarded to its final destination (10.0.0.1) using standard IP routing.
