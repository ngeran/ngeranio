+++
title = 'Type 1 LSA'
date = 2024-10-05T08:45:39+03:00
draft = false
+++


Type 1 — The Router LSA
Type 1 LSAs are the Router LSAs each router in an area originates a Type 1 LSA. The Type 1 LSA describes the state and cost of the routers interfaces inside the area. If the router has more than one interface inside an area all interfaces must be described in a single Type 1 LSA. Type 1 LSAs have area local scope and ONLY flooded within a single area.

0                   1                   2                   3
0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|            LS age             |     Options   |       1       |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                        Link State ID                          |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                     Advertising Router                        |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                     LS sequence number                        |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|         LS checksum           |             length            |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|  0  Nt|W|V|E|B|        0      |            # links            |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                          Link ID                              |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                         Link Data                             |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|     Type      |     # TOS     |            metric             |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                              ...                              |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|      TOS      |        0      |          TOS  metric          |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                          Link ID                              |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                         Link Data                             |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
Common 20 byte header

LS Age: The time in seconds since the LSA was originated.
Options: Optional Capabilities supported.
LS Type: The Type of the LSA — Type 1 in this case the Router LSA.
Link State ID: Identifies the piece of the routing domain that
is being described by the LSA
            LS Type   Link State ID
            _______________________________________________
            1         The originating router's Router ID.
            2         The IP interface address of the
                      network's Designated Router.
            3         The destination network's IP address.
            4         The Router ID of the described AS
                      boundary router.
            5         The destination network's IP address.
Advertising Router: The Router ID of the router that originated the LSA.
LS Sequence Number: Used for old or duplicated LSA detection
LS Checksum: Checksum of the complete LSA including the header
Type 1 LSA

bit V: V is for virtual link endpoint.
bit E: When set, the router is an AS boundary router (E is for
external).
bit B: When set, the router is an area border router (B is for border).
# links: The number of router links described in this LSA. The total interfaces in the area.
The following fields are used to describe each interface in the area

Type    Description
 __________________________________________________
 1       Point-to-point connection to another router
 2       Connection to a transit network
 3       Connection to a stub network
 4       Virtual link
Link ID: Identifies the object that this router link connects to. Value depends on the link’s Type. When connecting to an object that also originates an LSA (i.e., another router or a transit network) the Link ID is equal to the neighboring LSA’s Link State ID. This provides the key for looking up the neighboring LSA in the link state database during the routing table calculation.
Type   Link ID
 ______________________________________
 1     Neighboring router’s Router ID
 2     IP address of Designated Router
 3     IP network/subnet number
 4     Neighboring router’s Router ID
Link Data: Value again depends on the link’s Type field. For connections to stub networks, Link Data specifies the network’s IP address mask. For unnumbered point-to-point connections, it specifies the interface’s MIB-II ifIndex value. For the other link types it specifies the router interface’s IP address. This latter piece of information is needed during the routing table
build process, when calculating the IP address of the next hop.
# TOS ( Type Of Service): The number of different TOS metrics given for this link, not counting the required link metric.
metric: The cost of using this router link.
TOS: Type of Service
TOS metric: TOS-specific metric information.
Router LSA — Type 1: Router LSAs example in Junos

The operational mode command show ospf database router
The command shows all router LSAs in all areas
Can use area , advertising-router , lsa-id to narrow down the output results
Can use the detail and extensive flags to tailor output level of detail
Can use the summary flag for an overview of the LSAs


R2’s Originated — Router-LSA for AREA 0.0.0.0

LS age = 697                   
Options = (B-bit)              
LS type = 1                    Router-LSA
ID = 172.30.5.2                RT2's router ID
Adv Rtr = 172.30.5.2           RT2's router ID
bit E = 0                      not an AS boundary router
bits 0x1(B = 1)                area border router
link count = 3                 3 attached interfaces in AREA 0 
       Link ID = 172.30.0.14   DR interface IP 
       Link Data = 172.30.0.13 R2’s Interface IP 
       Type = 2               Connects to Transit Network 
       # TOS metrics = 0      Type of Service 
       metric = 1
       Link ID = 172.30.0.18   DR interface IP 
       Link Data = 172.30.0.17 R2’s Interface IP 
       Type = 2               Connects to Transit Network 
       # TOS metrics = 0      Type of Service 
       metric = 1

       Link ID = 172.30.5.2         R2’s Loopback 
       Link Data = 255.255.255.255  Subnet Mask 
       Type = 3                     Connects to STUB network
       # TOS metrics = 0
       metric = 0
Type = Transit                      Link Type 
Node ID = 172.30.0.18               DR Interface IP 
Type = Transit                      Link Type 
Node ID = 172.30.0.14               DR Interface IP
Gen Timer = 00:36:46      How long until LSA regeneration 
Aging time = 00:39:47     How long until the LSA expires 
Installed = 00:20:13      LSA was installed
expires in = 00:48:23     If not refreshed 
sent = 00:11:35 ago       LSA was flooded
Last changed = 4d 17:22:47 ago The route was installed
Change Count = 19         Number of times the route was changed 
Ours Indicates that this is a local advertisement
