+++
title = 'Route Selection'
date = 2024-12-01T09:15:27-05:00
draft = false
tags = ["BGP","Routing","Juniper"]
featured_image = 'featured.png'
summary = 'How to influance the route selection with the approptiate attributes.'
+++


>Before the router even starts the route selection process it needs to make sure that the route is valid, checks the **Martian** routes, **AS loops** and **next-hop reachability**. 

## Best Path Selection

| Attribute                        | Preference   | Default Behavior                                    |
| :------------------------------- | :----------  | :-------------------------------------------------- |
| 1. Route Preference              | Lowest       | Default value is 170                                |
| 2. Local Preference              | Highest      | Default learned value is 100                        |
| 3. AS-Path                       | Shortest     | Usualy the first time route selection occurs        |
| 4. Origin                        | Lowest       | IGP (I) >  EGP (E), EGP > incomplete (?)            |
| 5. Multi Exit Discriminator (MED)| Lowest       | Compared when routes are learned from the same AS   |
| 6. Route Type                    | External     | Internal vs External, External prefered             |
| 7. IGP Cost                      | Lowest       | lowest cost towards the BGP next-hop                |
| 8. Internal vs External          | Lowest       | Lowest R-ID,  Oldest active route                   |
| 10. Cluster List                 | Shortest     | When route reflection is used                       |
| 11. Peer IP Address              | Lowest       | Multiple peerings between the same router           |


>For JUNOS the route selection results and criteria can be seen in the output of:  
- **show route details**
- **show route extensive**


## Lowest Route Preference

The Juniper default BGP preference is 170 below you can see a route selection which is based on a non-default route preference of 160.
Junos OS is kind enough to tell us why the second route has lost in the route selection.  
> The Inactive Reason is **Route Preference**

```
jcluser@vMX4# run show route 192.168.250.0/24 exact detail       

inet.0: 14 destinations, 15 routes (14 active,0 holddown,0 hidden)
192.168.250.0/24 (2 entries, 1 announced)
        *BGP    Preference: 160/-101
                Next hop type: Router, Next hop index: 595
                Address: 0xc4b5f5c
                Next-hop reference count: 2
                Source: 10.100.34.1
                Next hop: 10.100.34.1 via ge-0/0/1.0,selected
                Session Id: 0x141
                State: <Active Ext>
                Local AS: 64533 Peer AS: 64522
                Age: 7 
                Validation State: unverified
                Task: BGP_64522.10.100.34.1
                Announcement bits(2):0-KRT 4-BGP_RT_Background
                AS path: 64522 I 
                Accepted
                Localpref: 100
                Router ID: 10.100.100.3
                Thread: junos-main 
         BGP    Preference: 170/-101
                Next hop type: Router,Next hop index: 596
                Address: 0xc4b5ef4
                Next-hop reference count: 1
                Source: 10.100.24.1
                Next hop: 10.100.24.1 via ge-0/0/0.0,selected
                Session Id: 0x140
                State: <Ext>
                Inactive reason: Route Preference
                Local AS: 64533 Peer AS: 64522
                Age: 9:18 
                Validation State: unverified 
                Task: BGP_64522.10.100.24.1
                AS path: 64522 I 
                Accepted
                Localpref: 100
                Router ID: 10.100.100.2
                Thread: junos-main 
```

## Highest Local Preference 

The default BGP **Local Preference** is 100 the route below has been selected for its higher non-default value of **200**. 
> The Inactive Reason is **Local Preference**

```
jcluser@vMX4# run show route 192.168.250.0/24 exact detail 

inet.0: 14 destinations, 15 routes (14 active, 0 holddown, 0 hidden)
192.168.250.0/24 (2 entries, 1 announced)
        *BGP    Preference: 170/-201
                Next hop type: Router, Next hop index: 595
                Address: 0xc4b5f5c
                Next-hop reference count: 2
                Source: 10.100.34.1
                Next hop: 10.100.34.1 via ge-0/0/1.0, selected
                Session Id: 0x141
                State: <Active Ext>
                Local AS: 64533 Peer AS: 64522
                Age: 24 
                Validation State: unverified 
                Task: BGP_64522.10.100.34.1
                Announcement bits (2): 0-KRT 4-BGP_RT_Background 
                AS path: 64522 I 
                Accepted
                Localpref: 200
                Router ID: 10.100.100.3
                Thread: junos-main 
         BGP    Preference: 170/-101
                Next hop type: Router, Next hop index: 596
                Address: 0xc4b5ef4
                Next-hop reference count: 1
                Source: 10.100.24.1
                Next hop: 10.100.24.1 via ge-0/0/0.0, selected
                Session Id: 0x140
                State: <Ext>
                Inactive reason: Local Preference
                Local AS: 64533 Peer AS: 64522
                Age: 51:52 
                Validation State: unverified 
                Task: BGP_64522.10.100.24.1
                AS path: 64522 I 
                Accepted
                Localpref: 100
                Router ID: 10.100.100.2
                Thread: junos-main 
```

## Shortest AS Path 

The route below has been selected because of its shortest AS Path.  
The selected route has 1 AS vs 5 AS.   
 
> The Inactive Reason is **AS Path**

```
jcluser@vMX4# run show route 192.168.250.0/24 exact detail 

inet.0: 14 destinations, 15 routes (14 active, 0 holddown, 0 hidden)
192.168.250.0/24 (2 entries, 1 announced)
        *BGP    Preference: 170/-101
                Next hop type: Router, Next hop index: 596
                Address: 0xc4b5ef4
                Next-hop reference count: 2
                Source: 10.100.24.1
                Next hop: 10.100.24.1 via ge-0/0/0.0, selected
                Session Id: 0x140
                State: <Active Ext>
                Local AS: 64533 Peer AS: 64522
                Age: 1:23:04 
                Validation State: unverified 
                Task: BGP_64522.10.100.24.1
                Announcement bits (2): 0-KRT 4-BGP_RT_Background 
                AS path: 64522 I 
                Accepted
                Localpref: 100
                Router ID: 10.100.100.2
                Thread: junos-main 
         BGP    Preference: 170/-101
                Next hop type: Router, Next hop index: 595
                Address: 0xc4b5f5c
                Next-hop reference count: 1
                Source: 10.100.34.1
                Next hop: 10.100.34.1 via ge-0/0/1.0, selected
                Session Id: 0x141
                State: <Ext>
                Inactive reason: AS path
                Local AS: 64533 Peer AS: 64522
                Age: 15 
                Validation State: unverified 
                Task: BGP_64522.10.100.34.1
                AS path: 64522 64522 64522 64522 64522 I 
                Accepted
                Localpref: 100
                Router ID: 10.100.100.3
                Thread: junos-main 
```

## Lowest Origin 

The active route is chosen based on its lower origin setting of I (IGP), compared to the second route which has an origin of ? (Incomplete). 

> The inactive reason is **Origin**

```
jcluser@vMX4# run show route 192.168.250.0/24 exact detail    

inet.0: 14 destinations, 15 routes (14 active, 0 holddown, 0 hidden)
192.168.250.0/24 (2 entries, 1 announced)
        *BGP    Preference: 170/-101
                Next hop type: Router, Next hop index: 596
                Address: 0xc4b5ef4
                Next-hop reference count: 2
                Source: 10.100.24.1
                Next hop: 10.100.24.1 via ge-0/0/0.0, selected
                Session Id: 0x140
                State: <Active Ext>
                Local AS: 64533 Peer AS: 64522
                Age: 1:45:36 
                Validation State: unverified 
                Task: BGP_64522.10.100.24.1
                Announcement bits (2): 0-KRT 4-BGP_RT_Background 
                AS path: 64522 I 
                Accepted
                Localpref: 100
                Router ID: 10.100.100.2
                Thread: junos-main 
         BGP    Preference: 170/-101
                Next hop type: Router, Next hop index: 595
                Address: 0xc4b5f5c
                Next-hop reference count: 1
                Source: 10.100.34.1
                Next hop: 10.100.34.1 via ge-0/0/1.0, selected
                Session Id: 0x141
                State: <Ext Changed>
                Inactive reason: Origin
                Local AS: 64533 Peer AS: 64522
                Age: 10 
                Validation State: unverified 
                Task: BGP_64522.10.100.34.1
                AS path: 64522 ? 
                Accepted
                Localpref: 100
                Router ID: 10.100.100.3
                Thread: junos-main 
```


## Lowest MED

The active route has a MED value of 20 shown as metric in the output.  
The second route has a MED of 150.

> Inactive reason **Not Best in its group - Route Metric or MED comparison**

```
jjcluser@vMX4# run show route 192.168.250.0/24 exact detail       

inet.0: 14 destinations, 15 routes (14 active, 0 holddown, 0 hidden)
192.168.250.0/24 (2 entries, 1 announced)
        *BGP    Preference: 170/-101
                Next hop type: Router, Next hop index: 595
                Address: 0xc4b5f5c
                Next-hop reference count: 2
                Source: 10.100.34.1
                Next hop: 10.100.34.1 via ge-0/0/1.0, selected
                Session Id: 0x141
                State: <Active Ext>
                Local AS: 64533 Peer AS: 64522
                Age: 36:03 Metric: 20 
                Validation State: unverified 
                Task: BGP_64522.10.100.34.1
                Announcement bits (2): 0-KRT 4-BGP_RT_Background 
                AS path: 64522 I 
                Accepted
                Localpref: 100
                Router ID: 10.100.100.3
                Thread: junos-main 
         BGP    Preference: 170/-101
                Next hop type: Router, Next hop index: 596
                Address: 0xc4b5ef4
                Next-hop reference count: 1
                Source: 10.100.24.1
                Next hop: 10.100.24.1 via ge-0/0/0.0, selected
                Session Id: 0x140
                State: <NotBest Ext>
                Inactive reason: Not Best in its group - 
                                 Route Metric or MED comparison
                Local AS: 64533 Peer AS: 64522
                Age: 13 Metric: 150 
                Validation State: unverified 
                Task: BGP_64522.10.100.24.1
                AS path: 64522 I 
                Accepted
                Localpref: 100
                Router ID: 10.100.100.2
                Thread: junos-main
```

## Route Type 

The directly adverised external route is preferred over the external route learned via an internal neighbor. 
This can be seen from the Local AS and Peer AS line.  
The **Local AS** and **Peer AS** line gives information on if the route is learned from an    
internal or external neighbor.  
The order of preference is:   
- Local redistributed routes into BGP **(Interior)**
- External route directly learned from External BGP peers **(Exterior)**
- External route learned through an Internal BGP peer **(Exterior via Interior)**

> Inactive reason **Interior > Exterior > Exterior via Interior**

```
jcluser@vMX6# run show route 192.168.250.0/24 exact detail 

inet.0: 11 destinations, 12 routes (11 active, 0 holddown, 0 hidden)
192.168.250.0/24 (2 entries, 1 announced)
        *BGP    Preference: 170/-101
                Next hop type: Router, Next hop index: 587
                Address: 0xc4b5dbc
                Next-hop reference count: 2
                Source: 10.100.46.1
                Next hop: 10.100.46.1 via ge-0/0/3.0, selected
                Session Id: 0x141
                State: <Active Ext>
                Local AS: 64544 Peer AS: 64533
                Age: 50 
                Validation State: unverified 
                Task: BGP_64533.10.100.46.1
                Announcement bits (3):0-KRT 4-BGP_RT_Background 
                                     5-Resolve tree 1 
                AS path: 64533 I 
                Accepted
                Localpref: 100
                Router ID: 10.100.100.4
                Thread: junos-main 
         BGP    Preference: 170/-101
                Next hop type: Indirect, Next hop index: 0
                Address: 0xc4b5d54
                Next-hop reference count: 1
                Source: 10.100.100.5
                Next hop type: Router, Next hop index: 349
                Next hop: 100.123.0.1 via fxp0.0, selected
                Session Id: 0x0
                Protocol next hop: 10.100.25.1
                Indirect next hop: 0xc61de84 338 INH Session ID: 0x0
                State: <Int Ext>
                Inactive reason: Interior > 
                                 Exterior > 
                                 Exterior via Interior
                Local AS: 64544 Peer AS: 64544
                Age: 6:58 Metric2: 0 
                Validation State: unverified 
                Task: BGP_64544.10.100.100.5
                AS path: 64522 I 
                Accepted
                Localpref: 100
                Router ID: 10.100.100.5
                Thread: junos-main 

```

## Lowest IGP cost

The active route is chosen based on the lowest IGP cost to the BGP next-hop, shown as protocol next-hop in the output.
The IGP cost is shown as metric2 in the output.  
The active route has a metric2 of 5 vs metric2 of 10 for the inactive. 
> Inactive reason **IGP metric**

```
jcluser@vMX4# run show route 192.168.252.0/24 exact detail    

inet.0: 16 destinations, 18 routes (16 active, 0 holddown, 0 hidden)
192.168.252.0/24 (2 entries, 1 announced)
        *BGP    Preference: 170/-101
                Next hop type: Router, Next hop index: 595
                Address: 0xc4b5f5c
                Next-hop reference count: 3
                Source: 10.100.34.1
                Next hop: 10.100.34.1 via ge-0/0/1.0, selected
                Next hop: 10.100.24.1 via ge-0/0/1.0 
                Session Id: 0x141
                State: <Active Ext>
                Local AS: 64533 Peer AS: 64522
                Age: 16:59       Metric2: 5
                Validation State: unverified 
                Task: BGP_64522.10.100.34.1
                Announcement bits (2): 0-KRT 4-BGP_RT_Background 
                AS path: 64522 64544 I 
                Accepted
                Localpref: 100
                Router ID: 10.100.100.3
                Thread: junos-main 
         BGP    Preference: 170/-101
                Address: 0xc4b5fc4
                Next-hop reference count: 2
                Source: 10.100.24.1
                Next hop type: Router, Next hop index: 0
                Next hop: 10.100.34.1 via ge-0/0/1.0, selected
                Next hop: 10.100.24.1 via ge-0/0/1.0 
                Session Id: 0x0
                State: <NotBest Ext Changed>
                Inactive reason: Not Best in its group - IGP metric
                Local AS: 64533 Peer AS: 64522
                Age: 16:59       Metric2: 10
                Validation State: unverified 
                Task: BGP_64522.10.100.24.1
                AS path: 64522 64544 I 
                Accepted
                Localpref: 100
                Router ID: 10.100.100.2
                Thread: junos-main 
```

## Lowest R-ID or Oldest Active

> Internal sessions **Router-ID**

The inactive route has a router-id 10.100.100.2 which is higher than the 10.100.100.1.

> Inactive reason **Not Best in its group - Router ID**

```
jcluser@vMX4# run show route 192.168.252.0/24 exact detail 

inet.0: 16 destinations, 18 routes (16 active, 0 holddown, 0 hidden)
192.168.252.0/24 (2 entries, 1 announced)
        *BGP    Preference: 170/-101
                Next hop type: Router, Next hop index: 595
                Address: 0xc4b5f5c
                Next-hop reference count: 2
                Source: 10.100.34.1
                Next hop: 10.100.34.1 via ge-0/0/1.0, selected
                Session Id: 0x141
                State: <Active Ext>
                Local AS: 64533 Peer AS: 64522
                Age: 1:00 
                Validation State: unverified 
                Task: BGP_64522.10.100.34.1
                Announcement bits (2): 0-KRT 4-BGP_RT_Background 
                AS path: 64522 64544 I 
                Accepted
                Localpref: 100
                Router ID: 10.100.100.1
                Thread: junos-main 
         BGP    Preference: 170/-101
                Next hop type: Router, Next hop index: 0
                Address: 0xc4b5fc4
                Next-hop reference count: 1
                Source: 10.100.24.1
                Next hop: 10.100.24.1 via ge-0/0/0.0, selected
                Session Id: 0x0
                State: <NotBest Ext Changed>
                Inactive reason: Not Best in its group - 
                                 Router ID
                Local AS: 64533 Peer AS: 64522
                Age: 1:00 
                Validation State: unverified 
                Task: BGP_64522.10.100.24.1
                AS path: 64522 64544 I 
                Accepted
                Localpref: 100
                Router ID: 10.100.100.2
                Thread: junos-main 
```

> External sessions **Router-ID**

To use the Router-ID as a tie-breaker the command **path-selection external-router-id** needs to be coinfigured.
The inactive route behaves as the internal and has a router-id 10.100.100.2 which is higher than the 10.100.100.1.

> Inactive reason **Not Best in its group - Router ID**
```
jcluser@vMX4# run show route 192.168.252.0/24 exact detail 

inet.0: 16 destinations, 18 routes (16 active, 0 holddown, 0 hidden)
192.168.252.0/24 (2 entries, 1 announced)
        *BGP    Preference: 170/-101
                Next hop type: Router, Next hop index: 595
                Address: 0xc4b5f5c
                Next-hop reference count: 2
                Source: 10.100.34.1
                Next hop: 10.100.34.1 via ge-0/0/1.0, selected
                Session Id: 0x141
                State: <Active Ext>
                Local AS: 64533 Peer AS: 64522
                Age: 1:00       Metric2: 5 
                Validation State: unverified 
                Task: BGP_64522.10.100.34.1
                Announcement bits (2): 0-KRT 4-BGP_RT_Background 
                AS path: 64522 64544 I 
                Accepted
                Localpref: 100
                Router ID: 10.100.100.1
                Thread: junos-main 
         BGP    Preference: 170/-101
                Next hop type: Router, Next hop index: 0
                Address: 0xc4b5fc4
                Next-hop reference count: 1
                Source: 10.100.24.1
                Next hop: 10.100.24.1 via ge-0/0/0.0, selected
                Session Id: 0x0
                State: <NotBest Ext Changed>
                Inactive reason: Not Best in its group - 
                                 Router ID
                Local AS: 64533 Peer AS: 64522
                Age: 1:00
                Validation State: unverified 
                Task: BGP_64522.10.100.24.1
                AS path: 64522 64544 I 
                Accepted
                Localpref: 100
                Router ID: 10.100.100.2
                Thread: junos-main 
```

> External sessions 

For Satbility reasons the oldest route is prefered 

> The inactive reason **Not Best in its group - Active preferred**

```
jcluser@vMX4# run show route 192.168.252.0/24 exact detail 

inet.0: 16 destinations, 18 routes (16 active, 0 holddown, 0 hidden)
192.168.252.0/24 (2 entries, 1 announced)
        *BGP    Preference: 170/-101
                Next hop type: Router, Next hop index: 595
                Address: 0xc4b5f5c
                Next-hop reference count: 2
                Source: 10.100.34.1
                Next hop: 10.100.34.1 via ge-0/0/1.0, selected
                Session Id: 0x141
                State: <Active Ext>
                Local AS: 64533 Peer AS: 64522
                Age: 1:00 
                Validation State: unverified 
                Task: BGP_64522.10.100.34.1
                Announcement bits (2): 0-KRT 4-BGP_RT_Background 
                AS path: 64522 64544 I 
                Accepted
                Localpref: 100
                Router ID: 10.100.100.3
                Thread: junos-main 
         BGP    Preference: 170/-101
                Next hop type: Router, Next hop index: 0
                Address: 0xc4b5fc4
                Next-hop reference count: 1
                Source: 10.100.24.1
                Next hop: 10.100.24.1 via ge-0/0/0.0, selected
                Session Id: 0x0
                State: <NotBest Ext Changed>
                Inactive reason: Not Best in its group - 
                                 Active preferred
                Local AS: 64533 Peer AS: 64522
                Age: 1:00 
                Validation State: unverified 
                Task: BGP_64522.10.100.24.1
                AS path: 64522 64544 I 
                Accepted
                Localpref: 100
                Router ID: 10.100.100.2
                Thread: junos-main 
```

## Cluster List

The shortest cluster list will be preferred when we have multiple route reflectors.

>Inactive reason **Not Best in its group - Cluster list length**

```
Output TBD 
```



## Lowest Peer IP

This is the last tie-breaker we can come this when for load-balancing purposed two routers peer two or more time with eachother. 
The route has been selected based on the lowest peer ip address, shown as **Source** in the output. 

> Inactive reason is **Not Best in its group - Update source**

```
jcluser@vMX2# run show route 192.168.251.0/24 exact detail 

inet.0: 26 destinations, 27 routes (26 active, 0 holddown, 0 hidden)
192.168.251.0/24 (2 entries, 1 announced)
        *BGP    Preference: 170/-101
                Next hop type: Indirect, Next hop index: 0
                Address: 0xc4b6234
                Next-hop reference count: 3
                Source: 10.100.150.1
                Next hop type: Router, Next hop index: 607
                Next hop: 10.100.12.1 via ge-0/0/0.0, selected
                Session Id: 0x143
                Protocol next hop: 10.100.100.1
                Indirect next hop: 0xc633184 1048574 
                                   INH Session ID: 0x144
                State: <Active Int Ext>
                Local AS: 64500 Peer AS: 64500
                Age: 1:37 Metric2: 10 
                Validation State: unverified 
                ORR Generation-ID: 0 
                Task: BGP_64500.10.100.150.1
                Announcement bits (3): 0-KRT 4-BGP_RT_Background 
                                       5-Resolve tree 4 
                AS path: 64544 I  (Originator)
                Cluster list:  1.1.1.1
                Originator ID: 10.100.100.1
                Accepted
                Localpref: 100
                Router ID: 10.100.150.1
                Thread: junos-main 
         BGP    Preference: 170/-101
                Next hop type: Indirect, Next hop index: 0
                Address: 0xc4b6234
                Next-hop reference count: 3
                Source: 10.100.150.2
                Next hop type: Router, Next hop index: 607
                Next hop: 10.100.12.1 via ge-0/0/0.0, selected
                Session Id: 0x143
                Protocol next hop: 10.100.100.1
                Indirect next hop: 0xc633184 1048574 
                                   INH Session ID: 0x144
                State: <NotBest Int Ext>
                Inactive reason: Not Best in its group - 
                                 Update source
                Local AS: 64500 Peer AS: 64500
                Age: 1:37 Metric2: 10 
                Validation State: unverified 
                ORR Generation-ID: 0 
                Task: BGP_64500.10.100.150.2
                AS path: 64544 I  (Originator)
                Cluster list:  2.2.2.2
                Originator ID: 10.100.100.1
                Accepted
                Localpref: 100
                Router ID: 10.100.150.2
                Thread: junos-main 
```



