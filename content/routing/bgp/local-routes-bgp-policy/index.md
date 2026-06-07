+++
title = 'The Architectural Deep Dive: Demystifying Junos Local Routes and BGP Policy Chains'
date = 2026-06-07T12:50:00-04:00
draft = false
tags = ["Juniper", "Junos", "BGP", "Routing-Policy", "Service-Provider"]
summary = 'A deep dive into why an operational inline services /32 interface prefix failed to advertise across an iBGP full mesh, exposing the inner workings of the Junos routing engine.'
+++

Every network engineer working with Junos eventually learns that the platform's routing policy engine is incredibly powerful — but strict. Recently, while setting up an inline services (`si-0/0/0`) interface on a vMX cluster running Junos **25.2R2.11**, we encountered a deceptively simple problem: an operational interface IP address absolutely refused to be advertised to our iBGP peers.

This post walks through the complete troubleshooting methodology — every wrong turn, every dead end, and every architectural revelation — until we arrived at the two production-proven solutions.

---

### The Symptom & Initial Topology

Our core objective was straightforward: advertise the interface IP of our virtual inline services unit (`si-0/0/0.0`) to our full-mesh iBGP neighbors (`10.100.100.2` and `10.100.100.3`).

The interface was configured with a strict `/32` host address:

```text
set interfaces si-0/0/0 unit 0 family inet address 10.100.249.1/32
```

The interface was fully functional, and the route existed cleanly in the primary routing table (`inet.0`):

```text
admin@vMX1# run show route 10.100.249.1

inet.0: 13 destinations, 13 routes (13 active, 0 holddown, 0 hidden)
+ = Active Route, - = Last Active, * = Both

10.100.249.1/32    *[Local/0] 00:30:52
                       Local via si-0/0/0.0
```

However, checking our advertised paths to our neighbors yielded total silence:

```text
admin@vMX1# run show route advertising-protocol bgp 10.100.100.2

# Output was completely empty!
```

---

### Phase 1: The Multi-Policy Chain — Our First Suspect

Our initial configuration leveraged multiple export policies separated across sequential commands:

```text
set protocols bgp group IBGP export ADVERTISE-SI
set protocols bgp group IBGP export BGP-Next-Hop
```

Our first hypothesis was that the multi-policy chain was silently dropping the route. This is a **real Junos pitfall** worth understanding, even though — as we'll discover in Phase 3 — it turned out not to be our actual problem.

#### How Multi-Policy Chains Work (And Fail)

When multiple export policies are listed under a BGP group, Junos treats them as a **sequential pipeline chain**.

An action of `then accept` in an intermediate policy does **not** terminate the entire pipeline. It merely accepts the route into that block, then passes the route directly to the next policy in the chain.

```text
              [ Candidate Route ]
                       |
                       v
              +---------------------------+
              |   Policy 1:               |
              |   ADVERTISE-SI            |
              +-------------+-------------+
                            | Matches term 'SI-NET'
                            | Executes 'then accept'
                            v
              +---------------------------+
              |   Policy 2:               |
              |   BGP-Next-Hop            |
              +-------------+-------------+
                            | Fails term 'eBGP' (Not BGP protocol)
                            | Fails term 'iBGP' (Not BGP protocol)
                            v
            [ Falls off user-defined chain ]
                           |
                           v
              +---------------------------+
              | Default BGP Export Policy  |
              +-------------+-------------+
                            |
                            v
                    X [ ROUTE REJECTED ] X
```

If `ADVERTISE-SI` accepts the route, it passes to `BGP-Next-Hop`. If `BGP-Next-Hop` evaluates `from protocol bgp` and the route isn't BGP, it fails to match any terms. The route falls off the end of the user-defined chain, where the **Default BGP Export Policy** takes over — and silently discards it.

> **Lesson:** Multi-policy chain shadowing is a real production risk. Consolidate your routing logic into a single master policy to avoid it.

**But here's the catch:** As we'll discover in Phase 3, our route never even reached the first policy in this chain. The real problem was deeper. We just didn't know it yet.

---

### Phase 2: Consolidated Policy — Eliminating the Chain Suspect

To rule out multi-policy shadowing, we refactored into a single consolidated policy block (`IBGP-EXPORT-MASTER`). This eliminated the chain trap — an explicit `then accept` would immediately terminate the policy evaluation.

```text
set policy-options policy-statement IBGP-EXPORT-MASTER term SI-NET from protocol local
set policy-options policy-statement IBGP-EXPORT-MASTER term SI-NET from route-filter 10.100.249.1/32 exact
set policy-options policy-statement IBGP-EXPORT-MASTER term SI-NET then accept
```

Yet, even with a single policy applied, the route **still** failed to advertise.

---

### Phase 3: The Core Revelation — The rpd Intake Filter

This is where the real Junos architecture lesson begins.

The natural assumption is: if a route is `Active (*)` in `inet.0`, and a policy explicitly matches it with `from protocol local`, BGP should be able to export it. **This assumption is wrong.**

#### The Hidden BGP Intake Gate

The Junos Routing Protocol Daemon (`rpd`) is mathematically separate from the Kernel Routing Table (`inet.0`). When an export policy is applied to BGP, `rpd` scans `inet.0` to build a list of **candidate routes** to run through your policy.

Here is the hard architectural limitation: **routes with a protocol type of `Local` are completely invisible to the BGP intake process.** BGP explicitly filters out `Local` routes **before** they can even be fed into your policy engine.

```text
  [ inet.0 Routing Table ]
         |
         +-- 10.100.249.1/32 *[Local/0]  Active
         |
         v
  [ rpd BGP Intake Filter ]
         |
         +-- Local routes? -> BLOCKED at the gate
         +-- Direct routes? -> Passed through
         +-- Static routes? -> Passed through (if Active)
         +-- BGP routes?    -> Passed through
         |
         v
  [ IBGP-EXPORT-MASTER Policy ]
         |
         Result: Policy engine is sitting ready,
         but rpd never passed the route in.
         |
         v
    X [ NO ROUTE EXPORTED ] X
```

It does not matter how permissive your policy is. It does not matter if you remove `from protocol local` entirely. The policy engine is ready and willing — but `rpd` **never delivers the route to it**.

#### Why This Happens: Protocol Local vs. Direct

When an IP address is configured on an interface, the Junos kernel populates the routing table based on the subnet mask context:

| Protocol | Created For | Example |
| :--- | :--- | :--- |
| **Direct** | The reachable subnet segment | `10.100.249.0/24` |
| **Local** | The specific `/32` host address of the router interface | `10.100.249.1/32` |

Because we configured our `si-0/0/0.0` interface strictly as `10.100.249.1/32`, no `Direct` route was generated in `inet.0` — only a `Local` route. And `Local` routes never make it past the BGP intake gate.

This single architectural fact explains **every** success and failure we encountered.

---

### Phase 4: Proof — The /24 Workaround

To validate this theory, we altered the topology by widening the mask to a `/24`. This forced Junos to generate a valid `[Direct/0]` network route entry alongside the host route. Because `rpd` **does** natively ingest `Direct` routes, the advertisement immediately worked.

#### Step 1: Adjust the Interface Context

```text
delete interfaces si-0/0/0 unit 0 family inet address 10.100.249.1/32
set interfaces si-0/0/0 unit 0 family inet address 10.100.249.1/24
```

#### Step 2: Refactor the Policy for Direct Protocols

```text
delete policy-options policy-statement IBGP-EXPORT-MASTER term SI-NET from protocol local
delete policy-options policy-statement IBGP-EXPORT-MASTER term SI-NET from route-filter 10.100.249.1/32 exact

set policy-options policy-statement IBGP-EXPORT-MASTER term SI-NET from protocol direct
set policy-options policy-statement IBGP-EXPORT-MASTER term SI-NET from route-filter 10.100.249.1/24 exact
set policy-options policy-statement IBGP-EXPORT-MASTER term SI-NET then accept
```

#### Step 3: Verify the Result

The moment the configuration was committed, the prefix flooded into our iBGP neighbors' tables:

```text
admin@vMX1# run show route advertising-protocol bgp 10.100.100.2

inet.0: 14 destinations, 14 routes (14 active, 0 holddown, 0 hidden)
  Prefix         Nexthop            MED     Lclpref    AS path
* 10.100.249.0/24 Self                         100        I
```

**This confirms the theory:** the only thing that changed was the protocol type in the routing table. `Direct` passes the intake gate. `Local` does not.

---

### Phase 5: The Static Discard Trap

Widening to a `/24` proves the concept, but production environments often demand `/32` host addresses on service interfaces. The next logical attempt: inject a static discard route for the same prefix and match `from protocol static`.

```text
# Interface still configured as /32
set interfaces si-0/0/0 unit 0 family inet address 10.100.249.1/32

# Static discard anchor
set routing-options static route 10.100.249.1/32 discard

# Policy matches static protocol
set policy-options policy-statement IBGP-EXPORT-MASTER term SI-NET from protocol static
set policy-options policy-statement IBGP-EXPORT-MASTER term SI-NET from route-filter 10.100.249.1/32 exact
set policy-options policy-statement IBGP-EXPORT-MASTER term SI-NET then accept
```

This configuration looks clean — but `show route advertising-protocol bgp` still returns nothing. Two architectural laws collide here.

#### The "Active Route" Law

Both configurations are trying to claim the exact same prefix: `10.100.249.1/32`. When the Junos kernel receives two identical prefixes from different internal subsystems, it uses **Route Preference** (Administrative Distance) to decide which one becomes the single Active (`*`) route.

| Protocol Source | Junos Default Preference |
| :--- | :--- |
| **Local** (Interface Host IP) | **0** |
| **Static** | **5** |

A lower preference number wins. `Local` (0) beats `Static` (5). The static discard route is marked as **inactive**.

BGP export policies can only evaluate routes that are marked as **ACTIVE** in the routing table. The static route exists, but it is inactive — so BGP refuses to ingest it.

```text
  [ Interface Subsystem ]               [ Static Route Configuration ]
  si-0/0/0.0 = 10.100.249.1/32         static route 10.100.249.1/32 discard
             |                                        |
             v                                        v
     Injected as Local Route                  Injected as Static Route
       (Preference: 0)                          (Preference: 5)
             |                                        |
             +-------------------+--------------------+
                                 |
                                 v
                     [ inet.0 Routing Table ]
                     Route Selection Election:
                     > 10.100.249.1/32 *[Local/0]  <-- WINNER (Active)
                     > 10.100.249.1/32  [Static/5] <-- LOSER  (Inactive)
                                 |
                                 v
                        [ rpd BGP Intake ]
                         Local route -> BLOCKED
                         Static route -> INACTIVE
                                 |
                                 v
                        X [ NO ROUTE EXPORTED ] X
```

---

### The Two True Fixes for /32 Advertisement

After every dead end, we arrived at exactly two production-proven solutions.

#### Fix A: Static Route with Preference 0

To make the static discard anchor work, you must force it to **win** the election against the `Local` route. Setting the static route's preference to `0` makes it compete at the same level, allowing it to become Active and pass the BGP intake gate.

```text
# 1. Keep the /32 interface
set interfaces si-0/0/0 unit 0 family inet address 10.100.249.1/32

# 2. Inject a static discard route with preference 0
set routing-options static route 10.100.249.1/32 discard preference 0

# 3. Match the static protocol in your export policy
set policy-options policy-statement IBGP-EXPORT-MASTER term SI-NET from protocol static
set policy-options policy-statement IBGP-EXPORT-MASTER term SI-NET from route-filter 10.100.249.1/32 exact
set policy-options policy-statement IBGP-EXPORT-MASTER term SI-NET then accept
```

> **Why this works:** With preference 0, the static route becomes active in `inet.0`. `rpd` ingests it (static routes pass the intake gate), the policy matches on the prefix, and BGP advertises it. Verify the static route shows as Active (`*`) in `show route` after committing — Junos tie-breaking between equal-preference Local and Static routes may vary by platform version.

#### Fix B: The Passive IGP Pattern (The Architect's Choice)

The production gold standard is to **decouple infrastructure reachability from BGP entirely** and let your IGP (OSPF or IS-IS) carry the `/32` natively.

```text
# Add the interface to your backbone area as passive
set protocols ospf area 0.0.0.0 interface si-0/0/0.0 passive

# Clean up any leftover BGP export policies trying to pull local routes —
# BGP can now return to its default clean state or just handle next-hop-self
```

**What happens under the hood:** OSPF immediately generates a Type 1 Router LSA containing `10.100.249.1/32`. Because it is marked as `passive`, OSPF advertises the network prefix to all neighbors instantly, but will **never** send hello packets or try to form a neighbor relationship out of that interface.

**Why this is the ultimate fix:**

| Benefit | Explanation |
| :--- | :--- |
| **BGP Stays Clean** | BGP no longer has to evaluate or carry local host system routes. It focuses entirely on customer or internet transit paths. |
| **Instant Next-Hop Resolution** | Any BGP updates using `10.100.249.1` as a next-hop are instantly resolved via the underlying OSPF Link-State Database (LSDB). |
| **No Policy Overhead** | We completely eliminate the risk of multi-policy chain shadowing because the IGP bypasses the BGP `rpd` export restrictions entirely. |
| **Native Host Route Handling** | IGPs are designed from the ground up to advertise local interface states. A passive interface bypasses all policy engine blocks. |

---

### iBGP vs. eBGP: The Default Export Stance Shift

For `/32` interfaces, the `rpd` intake filter applies identically to both iBGP and eBGP — the bottleneck is how `rpd` interacts with `protocol local` routes, not the peering type. However, once you move to eBGP, there is a massive shift in **default protocol behaviors** that you must account for.

```text
                       +-----------------------------+
                       |     Is the Neighbor...      |
                       +--------------+--------------+
                                      |
                  +-------------------+-------------------+
                  v iBGP                                  v eBGP
     +---------------------------+       +---------------------------+
     |  Default Export Policy:   |       |  Default Export Policy:   |
     |       REJECT ALL          |       |    ADVERTISE ACTIVE BGP   |
     | (Except active BGP paths) |       |          ROUTES           |
     +---------------------------+       +---------------------------+
```

| Behavior | iBGP | eBGP |
| :--- | :--- | :--- |
| **Default Export Stance** | Reject all (except active BGP paths) | Permit — advertises all active BGP routes |
| **Non-BGP route export** | Requires explicit export policy | Also requires explicit export policy |
| **Next-Hop for local prefixes** | Must configure `next-hop self` | Automatic — Junos sets next-hop to its egress IP |

**Key takeaway:** Even though eBGP automatically advertises BGP routes, you still cannot export a `protocol local` `/32` without one of the two fixes above. The `rpd` intake limitation is identical for both peering types.

#### eBGP Policy Best Practices

##### 1. The Explicit Ingress/Egress Principle (Sanity Sandboxing)

Never deploy an eBGP peer without an explicit export policy acting as a guardrail. Relying on default behavior in production is a recipe for an accidental leak or outage.

> **Note:** This policy presumes the prefix has already been made ingestible by `rpd` — either via the static preference 0 approach (Fix A) or because the route is `protocol direct`. A raw `Local` `/32` will still be blocked at the intake gate, even for eBGP.

```text
# Explicitly permit only the prefix you intend to advertise
set policy-options policy-statement EBGP-PEER-OUT term ALLOW-LOCAL-SI from route-filter 10.100.249.1/32 exact
set policy-options policy-statement EBGP-PEER-OUT term ALLOW-LOCAL-SI then accept

# Explicitly reject everything else to prevent transit leaks
set policy-options policy-statement EBGP-PEER-OUT term CATCH-ALL-REJECT then reject
```

##### 2. The Next-Hop Behavior Shift

With iBGP, you had to explicitly configure `next-hop self`:

```text
set policy-options policy-statement BGP-Next-Hop term iBGP then next-hop self
```

With eBGP, you do **not** need this for your local prefixes. When Junos advertises a route out of an eBGP interface, it automatically modifies the next-hop to match its own egress IP address on that shared external link.

---

### Definitive Troubleshooting Matrix

This matrix summarizes every architectural challenge we encountered, whether it applies to iBGP, eBGP, or both, and the engineering solution:

| Architectural Challenge | iBGP? | eBGP? | The Engineering Solution |
| :--- | :--- | :--- | :--- |
| **rpd Local Route Intake Block** | Yes | Yes | BGP cannot see `Local` routes. Use static with `preference 0` or move the prefix to the IGP. |
| **Static Route Loses Election** | Yes | Yes | Local (preference 0) beats Static (preference 5). Set `preference 0` on the static route. |
| **Multi-Policy Shadowing** | Yes | Yes | Consolidate into a single master policy block. Sequential policy arrays drop routes on fallback rules. |
| **Next-Hop Rewrites** | Required | Automatic | Use `next-hop self` for internal peers; let external peers use default link egress settings. |
| **Default Export Stance** | Reject All | Permit BGP | Always build a restrictive catch-all policy for eBGP to prevent routing leaks. |

---

### BGP Policy Best Practices

This architectural deep dive highlights several key guidelines for managing enterprise and service-provider Junos platforms:

#### 1. Avoid Multi-Policy Array Formats

Using sequential lines like `export [ PolicyA PolicyB ]` introduces structural complexity. If any internal term hits an unhandled default action or an unexpected explicit `reject`, subsequent policies can be shadowed entirely. Consolidate your routing logic into a **single master policy** using explicit term ordering.

#### 2. Isolate Intent Structure

Keep structural functions separated cleanly inside your single policy block:

| Term | Function | What it handles |
| :--- | :--- | :--- |
| **Term 1** (Local Ingress) | Inject locally originated routes | `direct`, `static`, `aggregate` |
| **Term 2** (Transit Modification) | Modify protocol path attributes | `next-hop self` for standard BGP streams |

#### 3. Understand the rpd Intake Gate

No matter how permissive your export policy is, BGP can only evaluate routes that pass the `rpd` intake filter. `Local` routes are blocked at the gate. `Direct`, `Static`, and `BGP` routes are admitted. Design your routing table state accordingly — do not assume a permissive policy can override a fundamental daemon limitation.
