+++
title = 'Local Preference'
date = 2024-12-12T17:30:21-05:00
draft = true
tags = ["BGP","Routing","Juniper","Attributes"]
featured_image = 'featured.png'
summary = 'The Power of Local Preference. The first BGP attribute used to favor one route over another.'
+++

### Local Preference Power

Local preference is the highest tiebreaker in the BGP path selection process. If a BGP next hop is reachable and BGP knows multiple routes, BGP always chooses the route with the highest local preference to exit the AS.  
The local preference is a **well-known**, **discretionary** attribute, which means it must be supported by all BGP-speaking neighbors but does not have to be included in the BGP update message.  
Local preference is also **non-transitive**, meaning it stays within its own internal AS and cannot be advertised to an external BGP neighbor.

Let's now see how to configure and influance traffic with Local Preference. 

### Topology 

> Taken from Juniper vLabs

![BGP Topology](bgp-topology-diagram.jpg)


### Initial set up

vMX5 advertises the same route **192.168.235.0/24** to both vMX3 and vMX2. 

```
jcluser@vMX5# run show route advertising-protocol bgp 10.100.25.1 

inet.0: 16 destinations, 16 routes (16 active, 0 holddown, 0 hidden)
  Prefix  Nexthop       MED     Lclpref    AS path
* 192.168.235.0/24        Self                                    I

[edit]
jcluser@vMX5# run show route advertising-protocol bgp 10.100.35.1    

inet.0: 16 destinations, 16 routes (16 active, 0 holddown, 0 hidden)
  Prefix  Nexthop       MED     Lclpref    AS path
* 192.168.235.0/24        Self                                    I
```

vMX1 learns the same route from vMX2 and vMX3. Goes throught the Best Path Selection  
process and chooses the route from vMX2 because of the lower **Router ID**.  
In this case both neighbors advertise the route with the "Localpref" of **100** which is the **default**. 

```
jcluser@vMX1# run show route 192.168.235.0/24 exact detail 

inet.0: 13 destinations, 14 routes (13 active, 0 holddown, 0 hidden)
192.168.235.0/24 (2 entries, 1 announced)
        *BGP    Preference: 170/-101
                Next hop type: Indirect, Next hop index: 0
                Address: 0xc4b5dbc
                Next-hop reference count: 2
                Source: 10.100.100.2
                Next hop type: Router, Next hop index: 343
                Next hop: 100.123.0.1 via fxp0.0, selected
                Session Id: 0x0
                Protocol next hop: 10.100.25.2
                Indirect next hop: 0xc61de84 347 INH Session ID: 0x0
                State: <Active Int Ext>
                Local AS: 64522 Peer AS: 64522
                Age: 8:04 Metric2: 0 
                Validation State: unverified 
                Task: BGP_64522.10.100.100.2
                Announcement bits (2): 0-KRT 5-Resolve tree 1 
                AS path: 64544 I 
                Accepted
                Localpref: 100
                Router ID: 10.100.100.2
                Thread: junos-main 
         BGP    Preference: 170/-101
                Next hop type: Indirect, Next hop index: 0
                Address: 0xc4b5e8c
                Next-hop reference count: 1
                Source: 10.100.100.3
                Next hop type: Router, Next hop index: 343
                Next hop: 100.123.0.1 via fxp0.0, selected
                Session Id: 0x0
                Protocol next hop: 10.100.35.2
                Indirect next hop: 0xc61e004 - INH Session ID: 0x0
                State: <NotBest Int Ext Changed>
                Inactive reason: Not Best in its group - Router ID
                Local AS: 64522 Peer AS: 64522
                Age: 8:04 Metric2: 0 
                Validation State: unverified 
                Task: BGP_64522.10.100.100.3
                AS path: 64544 I 
                Accepted
                Localpref: 100
                Router ID: 10.100.100.3
                Thread: junos-main 
```

```
jcluser@vMX3# run show route protocol bgp   

inet.0: 17 destinations, 18 routes (17 active, 0 holddown, 0 hidden)
+ = Active Route, - = Last Active, * = Both

192.168.235.0/24   *[BGP/170] 00:20:44, localpref 100
                      AS path: 64544 I, validation-state: unverified
                    >  to 10.100.35.2 via ge-0/0/0.0
                    [BGP/170] 00:20:43, localpref 100, from 10.100.100.2
                      AS path: 64544 I, validation-state: unverified
                    >  to 100.123.0.1 via fxp0.0
```

### Configuration 

Now lets create a policy to change the Local_Pref value to **200** and observe the impact.

> Change the the Local_Pref for all inbounds routes 
```
jcluser@vMX3# show policy-options 
policy-statement SET_LOCAL_PREF {
    term ROUTE {
        from next-hop 10.100.35.2;
        then {
            local-preference 200;
            accept;
        }
    }
}
```

> Change the the Local_Pref for a specific inbound route.
```
jcluser@vMX3# show policy-options 
policy-statement SET_LOCAL_PREF {
    term ROUTE {
        from {
            route-filter 192.168.235.0/24 exact;
        }
        then {
            local-preference 200;
            accept;
        }
    }
}
```

> Apply the policy inbound (**import**) to change the AS exit point.
```
jcluser@vMX3# show protocols bgp group to-AS64544 
type external;
import SET_LOCAL_PREF; <-- Inbound 
peer-as 64544;
neighbor 10.100.35.2;
```

### The Result 

After appling the policy vMX1 chooses the route learned from vMX3 because of the higher Local_Pref value.

```
jcluser@vMX1# run show route 192.168.235.0/24 exact detail    

inet.0: 13 destinations, 13 routes (13 active, 0 holddown, 0 hidden)
192.168.235.0/24 (1 entry, 1 announced)
        *BGP    Preference: 170/-201
                Next hop type: Indirect, Next hop index: 0
                Address: 0xc4b5e8c
                Next-hop reference count: 2
                Source: 10.100.100.3
                Next hop type: Router, Next hop index: 343
                Next hop: 100.123.0.1 via fxp0.0, selected
                Session Id: 0x0
                Protocol next hop: 10.100.35.2
                Indirect next hop: 0xc61e004 348 INH Session ID: 0x0
                State: <Active Int Ext>
                Local AS: 64522 Peer AS: 64522
                Age: 13 Metric2: 0 
                Validation State: unverified 
                Task: BGP_64522.10.100.100.3
                Announcement bits (2): 0-KRT 5-Resolve tree 1 
                AS path: 64544 I 
                Accepted
                Localpref: 200 <--- Higher than the default 
                Router ID: 10.100.100.3
                Thread: junos-main 
```

```
jcluser@vMX1# run show route protocol bgp   

inet.0: 13 destinations, 13 routes (13 active, 0 holddown, 0 hidden)
+ = Active Route, - = Last Active, * = Both

192.168.235.0/24   *[BGP/170] 00:01:32, localpref 200, from 10.100.100.3
                      AS path: 64544 I, validation-state: unverified
                    >  to 100.123.0.1 via fxp0.0
```

### Advertise to eBGP (non-transitive)

vMX3 has the route **192.168.123.0/24** with **localpref** of  **123**
```
jcluser@vMX3# run show route protocol bgp                         

inet.0: 19 destinations, 20 routes (19 active, 0 holddown, 0 hidden)
+ = Active Route, - = Last Active, * = Both

192.168.123.0/24    [BGP/170] 00:04:39, localpref 123, from 10.100.100.1
                      AS path: I, validation-state: unverified
                    >  to 10.100.13.1 via ge-0/0/4.0
192.168.235.0/24   *[BGP/170] 00:53:00, localpref 200
                      AS path: 64544 I, validation-state: unverified
                    >  to 10.100.35.2 via ge-0/0/0.0
```

> When the route is adveried to a neighbor on a diffrent AS. 

```
jcluser@vMX3# run show route advertising-protocol bgp 10.100.35.2 

inet.0: 19 destinations, 20 routes (19 active, 0 holddown, 0 hidden)
  Prefix  Nexthop       MED     Lclpref    AS path
* 192.168.123.0/24        Self                 1                  I
```

> The Local Preference resets to the default value. 

```
jcluser@vMX5# run show route protocol bgp detail

inet.0: 17 destinations, 17 routes (17 active, 0 holddown, 0 hidden)
192.168.123.0/24 (1 entry, 1 announced)
        *BGP    Preference: 170/-101
                Next hop type: Router, Next hop index: 596
                Address: 0xc4b5f5c
                Next-hop reference count: 2
                Source: 10.100.35.1
                Next hop: 10.100.35.1 via ge-0/0/0.0, selected
                Session Id: 0x141
                State: <Active Ext>
                Local AS: 64544 Peer AS: 64522
                Age: 1:56 Metric: 1 
                Validation State: unverified 
                Task: BGP_64522.10.100.35.1
                Announcement bits (3): 0-KRT 4-BGP_RT_Background 
                                       5-Resolve tree 1 
                AS path: 64522 I 
                Accepted
                Localpref: 100 <-- Original Value
                Router ID: 10.100.100.3
                Thread: junos-main 
```