+++
title = 'Beyond BGP Path Selection: eBGP vs iBGP on Juniper Junos'
date = 2026-06-05T10:00:00-04:00
draft = false
tags = ["BGP", "Routing", "Juniper", "Path-Selection"]
summary = 'A deep comparison of the BGP path selection process between eBGP and iBGP on Juniper platforms — tie-breakers, CLI output analysis, and production configs.'
+++

### Introduction

The BGP path selection algorithm is the engine that decides which route, among potentially hundreds of candidates for the same prefix, gets installed into the routing table (RIB) and promoted to the forwarding table (FIB). Understanding this decision process is fundamental to designing, operating, and troubleshooting any service provider or enterprise network running BGP.

On Juniper platforms, both eBGP and iBGP sessions carry a **default protocol preference of 170**. This means Junos does not inherently prefer one over the other at the protocol-preference level. Instead, the distinction happens **inside** the BGP decision algorithm itself — specifically at the tie-breaker steps. This document dissects every step of that process, compares eBGP and iBGP behavior side by side, and provides production-ready configurations and CLI analysis.

---

### Junos BGP Decision Process (The Core Algorithm)

Junos evaluates BGP paths in the following strict order. The first step that eliminates all but one path determines the winner.

| Step | Criterion | Action |
| :--- | :--- | :--- |
| 1 | **Next-hop reachability** | Discard any path whose next-hop is not resolvable in the routing table. |
| 2 | **Highest Local Preference** | Prefer the path with the highest LOCAL_PREF. Default is 100. |
| 3 | **Shortest AS Path** | Prefer the path with the fewest AS numbers in the AS_PATH attribute. |
| 4 | **Lowest Origin Code** | Prefer IGP (0) over EGP (1) over INCOMPLETE (2). |
| 5 | **Lowest MED** | Prefer the lowest Multi-Exit Discriminator, **only** when comparing paths from the same neighboring AS (default behavior in Junos). |
| 6 | **eBGP over iBGP** | Prefer paths learned via eBGP over those learned via iBGP. |
| 7 | **Lowest IGP metric to next-hop** | Prefer the path with the lowest IGP cost to reach the BGP next-hop. |
| 8 | **Lowest router ID / peer address** | Prefer the path from the peer with the lowest router ID. If router IDs are equal (iBGP from different RR clusters), prefer the lowest peer address. |
| 9 | **Longest cluster list** | Prefer the path with the shortest cluster list length (Route Reflection only). |
| 10 | **Lowest neighbor address** | Prefer the path from the neighbor with the lowest IP address. |
| 11 | **Oldest route** | Prefer the path that has been known the longest (stability tie-breaker). |
| 12 | **Lowest policy origin** | Tie-breaker for routes originated locally via different policies. |

**Important:** Junos does **not** use Cisco's proprietary "Weight" attribute. If you are migrating from Cisco, discard any mental model involving Weight.

---

### Key Architectural Differences: eBGP vs. iBGP

| Attribute | eBGP | iBGP |
| :--- | :--- | :--- |
| **AS Relationship** | Peers in different autonomous systems. | Peers within the same autonomous system. |
| **Default Next-Hop** | Set to the eBGP peer's source IP (unchanged). | Unchanged by default — original next-hop is preserved. Requires `next-hop-self` or IGP carry-over. |
| **Loop Prevention** | AS_PATH loop detection — rejects routes containing own AS. | Full-mesh requirement, Route Reflectors, or Confederations. Originator-ID and Cluster-List prevent loops. |
| **Advertisement Rules** | Routes learned from one eBGP peer can be advertised to other eBGP and iBGP peers. | Routes learned from one iBGP peer are **not** advertised to other iBGP peers (unless via RR or Confederation). |
| **TTL** | TTL set to 1 by default (requires `multihop` for non-direct peers). | TTL not restricted — uses IGP reachability. |
| **Tie-Breaker (Step 6)** | **Preferred.** eBGP wins over iBGP when all prior attributes are equal. | Loses to eBGP at Step 6 unless overridden by higher LOCAL_PREF. |
| **Default Preference** | 170 | 170 |

---

### Configuration Examples & Topologies

#### A. eBGP Configuration Example

**Topology:**

```text
  AS 65001                AS 65002
+--------+              +--------+
|   R1   |--------------|   R2   |
| 10.0.12.1              10.0.12.2
+--------+              +--------+
    |                       |
   Lo0: 1.1.1.1           Lo0: 2.2.2.2
```

**R1 Configuration (Junos 20+):**

```text
interfaces {
    ge-0/0/0 {
        unit 0 {
            family inet {
                address 10.0.12.1/30;
            }
        }
    }
    lo0 {
        unit 0 {
            family inet {
                address 1.1.1.1/32;
            }
        }
    }
}

protocols {
    bgp {
        group eBGP-TO-R2 {
            type external;
            peer-as 65002;
            neighbor 10.0.12.2;
        }
    }
}

routing-options {
    autonomous-system 65001;
}
```

**Why eBGP wins over iBGP for the same prefix:** When R1 receives the prefix `192.168.100.0/24` from both an eBGP peer (R2) and an iBGP peer (inside AS 65001), and all attributes up to Step 5 are identical, Junos applies **Step 6: prefer eBGP over iBGP**. The eBGP path is declared active.

#### B. iBGP Configuration Example

**Topology:**

```text
          AS 65001
+--------+          +--------+
|   R3   |----------|   R4   |
| Lo0: 3.3.3.3      Lo0: 4.4.4.4
+--------+          +--------+
     \                /
      \   IGP (OSPF) /
       \            /
        +--------+
        |   R5   |  (Route Reflector - optional)
        | Lo0: 5.5.5.5
        +--------+
```

**R3 Configuration:**

```text
interfaces {
    ge-0/0/0 {
        unit 0 {
            family inet {
                address 10.0.34.1/30;
            }
        }
    }
    lo0 {
        unit 0 {
            family inet {
                address 3.3.3.3/32;
            }
        }
    }
}

protocols {
    bgp {
        group iBGP-TO-R4 {
            type internal;
            local-address 3.3.3.3;
            neighbor 4.4.4.4;
        }
    }
    ospf {
        area 0.0.0.0 {
            interface lo0.0 {
                passive;
            }
            interface ge-0/0/0.0;
        }
    }
}

routing-options {
    autonomous-system 65001;
}
```

**Next-hop resolution:** iBGP preserves the original next-hop by default. If R3 advertises `172.16.0.0/16` to R4, the next-hop remains set to whatever R3's eBGP peer sent — typically not reachable from R4. Two solutions:

1. **`next-hop-self` via policy** — change the next-hop to R3's loopback on export to iBGP peers.
2. **IGP passive route injection** — advertise the eBGP link network into OSPF/IS-IS so the next-hop is resolvable.

**Next-hop-self policy example:**

```text
policy-options {
    policy-statement NH-SELF {
        term 1 {
            from protocol bgp;
            then {
                next-hop self;
            }
        }
    }
}

protocols {
    bgp {
        group iBGP-TO-R4 {
            type internal;
            local-address 3.3.3.3;
            export NH-SELF;
            neighbor 4.4.4.4;
        }
    }
}
```

---

### CLI Output Analysis: eBGP vs iBGP Path Resolution

Below is a simulated `show route` output for a router that receives `192.168.100.0/24` from **both** an eBGP peer (10.0.12.2, AS 65002) and an iBGP peer (3.3.3.3, same AS).

```text
user@R1> show route 192.168.100.0/24 extensive

inet.0: 45 destinations, 52 routes (45 active, 0 holddown, 0 hidden)
192.168.100.0/24 (2 entries, 1 announced)
        *BGP    Preference: 170/-101
                Next hop type: Router, Next hop index: 1042
                Next-hop: 10.0.12.2 via ge-0/0/0.0
                Session: 0x0
                State: <Active Ext>
                Local AS: 65001 Peer AS: 65002
                Age: 12:34:56
                Validation State: unverified
                Task: BGP_65002.10.0.12.2
                AS path: 65002 65003 I (2 entries)
                Communities: 65002:100
                Accepted
                Localpref: 100
                Router ID: 2.2.2.2

         BGP    Preference: 170/-101
                Next hop type: Indirect
                Next-hop: 3.3.3.3 via ae0.0
                Session: 0x0
                State: <NotBest Int Ext>
                Inactive reason: IGP metric higher
                Local AS: 65001 Peer AS: 65001
                Age: 8:23:11
                Validation State: unverified
                Task: BGP_65001.3.3.3.3
                AS path: 65002 65003 I (2 entries)
                Communities: 65002:100
                Accepted
                Localpref: 100
                Router ID: 3.3.3.3
```

**Line-by-line breakdown:**

- **`*BGP`** — The asterisk marks this path as **active** (installed in RIB/FIB).
- **`Preference: 170/-101`** — Protocol preference is 170 (BGP). The secondary value (-101) is the BGP internal preference.
- **`Local AS: 65001 Peer AS: 65002`** — This is an **eBGP** session (different AS numbers).
- **`AS path: 65002 65003 I`** — The route traversed two ASes with IGP origin.
- **`State: <Active Ext>`** — `Active` = this is the winning path. `Ext` = external (eBGP).
- **`Inactive reason: IGP metric higher`** — The iBGP path lost at **Step 7** (lowest IGP metric to next-hop) after tying through Steps 1–5 and being compared at Step 6. In some cases, the inactive reason may show `eBGP > iBGP` if the decision was made at Step 6 directly.

The iBGP entry shows **`State: <NotBest Int Ext>`** — `NotBest` means it lost the tie-breaker. `Int` = internal (iBGP). The `Inactive reason` field tells you exactly which step eliminated it.

---

### Special Tiebreaker: The "Oldest Route" (Route Age)

The **oldest route** tiebreaker sits late in the decision process (Step 11). Its purpose is to prefer the path that has been known the longest, which adds stability and prevents unnecessary route flapping.

#### How it works

When two paths are **identical** through Steps 1 through 10 (same LOCAL_PREF, same AS_PATH length, same origin, same MED, same eBGP/iBGP type, same IGP metric, same router ID, same cluster list, same peer address), Junos selects the one it learned first.

#### Why this heavily favors eBGP paths

In practice, eBGP routes are typically learned before iBGP routes for the same prefix:

- eBGP sessions are often established directly with edge routers, which receive external routes first.
- iBGP routes must propagate through the internal mesh or Route Reflectors, introducing a delay.
- By the time the iBGP copy arrives, the eBGP copy has already been installed and "aged."

So even if an iBGP path ties through all 10 prior steps, it loses at Step 11 because the eBGP path is older.

#### When it is bypassed for iBGP

This tiebreaker is frequently **not reached** for iBGP because:

- **Cluster IDs and Originator IDs** from Route Reflection cause differences at Step 9 (cluster list length).
- **IGP metrics** to different next-hops are rarely identical, breaking the tie at Step 7.
- **LOCAL_PREF** is commonly manipulated via policy, resolving the decision at Step 2.

Only in rare, perfectly symmetrical topologies (identical attributes, identical IGP costs, same router IDs via different loopbacks) does the oldest-route rule become the deciding factor.

---

### Complete Tiebreaker Summary Table

| Step | Description | Behavioral Difference (eBGP vs iBGP) |
| :--- | :--- | :--- |
| 1 | Next-hop reachability | Both must have a resolvable next-hop. iBGP often needs `next-hop-self` or IGP carry-over. |
| 2 | Highest LOCAL_PREF | Applies equally. Default is 100 for both. Policy can override. |
| 3 | Shortest AS Path | eBGP routes typically have longer AS paths (crossing AS boundaries). iBGP routes carry the same AS path as learned externally. |
| 4 | Lowest Origin Code | IGP (0) preferred. Applies equally to both. |
| 5 | Lowest MED | Only compared between paths from the **same** neighboring AS. Often irrelevant for eBGP vs iBGP comparison. |
| 6 | **eBGP over iBGP** | **eBGP wins.** This is the primary differentiator. |
| 7 | Lowest IGP metric to next-hop | iBGP next-hops are loopbacks — IGP cost varies. eBGP next-hops are typically directly connected (metric 0 or 1). |
| 8 | Lowest router ID | Tie-breaker when everything else is equal. |
| 9 | Shortest cluster list | Only relevant in RR topologies (iBGP). eBGP routes have no cluster list. |
| 10 | Lowest neighbor address | Final numeric tie-breaker. |
| 11 | Oldest route (route age) | Favors eBGP (typically learned first). Prevents flapping. |
| 12 | Lowest policy origin | Rare. Differentiates locally originated routes. |

---

### Advanced Troubleshooting & Overrides

#### Verification Commands

```text
# Show all BGP routes for a prefix with full detail
show route 192.168.100.0/24 extensive

# Show only the active path
show route 192.168.100.0/24 extensive | match "State|Active|Inactive|Preference"

# Show what was received from a specific peer (before policy)
show route receive-protocol bgp 10.0.12.2 table inet.0

# Show what was advertised to a specific peer (after policy)
show route advertising-protocol bgp 10.0.12.2 table inet.0

# Check BGP session summary
show bgp summary

# Compare eBGP vs iBGP path counts
show route protocol bgp table inet.0 | match "LocPrf|Med|AS path"
```

#### Forcing iBGP Over eBGP with LOCAL_PREF

By default, eBGP wins at Step 6. To override this and force an iBGP path to be preferred, manipulate LOCAL_PREF at **Step 2** (which is evaluated before the eBGP/iBGP tie-breaker at Step 6):

```text
policy-options {
    prefix-list INTERNAL-PREFIXES {
        192.168.100.0/24;
        172.16.0.0/16;
    }
    policy-statement PREF-iBGP-PATHS {
        term 1 {
            from {
                protocol bgp;
                prefix-list INTERNAL-PREFIXES;
                neighbor 3.3.3.3;
            }
            then {
                local-preference 200;
            }
        }
        term 2 {
            then accept;
        }
    }
}

protocols {
    bgp {
        group iBGP-TO-R4 {
            type internal;
            local-address 1.1.1.1;
            import PREF-iBGP-PATHS;
            neighbor 3.3.3.3;
        }
    }
}
```

With LOCAL_PREF set to 200 on the iBGP path (vs the default 100 on the eBGP path), the iBGP route wins at **Step 2** — the eBGP/iBGP tie-breaker at Step 6 is never reached. This is the standard, clean way to influence path selection in Junos without resorting to AS_PATH prepending or MED manipulation.
