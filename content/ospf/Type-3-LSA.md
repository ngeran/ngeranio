+++
title = 'Type 3 LSA'
date = 2024-10-05T16:11:39+03:00
draft = true
+++

Type 3 — The Summary LSA
0                   1                   2                   3
0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|            LS age             |     Options   |       3       |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                        Link State ID                          |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                     Advertising Router                        |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                     LS sequence number                        |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|         LS checksum           |             length            |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                         Network Mask                          |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|      0        |                  metric                       |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|     TOS       |                TOS  metric                    |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
Originated by the ABR — has area scope

Describes networks outside of the area

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
plus:
(4-byte) Network Mask: Subnet mask of the advertised network. It is used in conjunction with the link-state ID filed, which encapsulates the network address in a Type 3 LSA.
(1-byte) Reserved ( set to 0):
(3-byte) Metric: This field provides the cost of the route to the network destination.When the summary LSA is representing an aggregated route (using the area-range command), this field is set to the largest current metric of the contributing routes.
(1-byte) ToS (not used):This field describes any optional ToS information encoded within the network described. The Junos OS does not use this field.
(3-byte) ToS metric ( not used):
