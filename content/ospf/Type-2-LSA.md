+++
title = 'Type 2 LSA'
date = 2024-10-05T16:11:35+03:00
draft = true
+++

Originated by the Designated Router and has Area Local Scope

For each transit broadcast or NBMA networks the designated router originates a Network LSA only if it has at least one full adjacency to at least one other router. The Network LSA flooded throughout the area that contains the network and describes all the routers attached to the network.

The Designated Router includes itself int the router list

0                   1                   2                   3
0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|            LS age             |      Options  |      2        |
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
|                        Attached Router                        |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
LS Age: The time in seconds since the LSA was originated.
Options: Optional Capabilities supported.
LS Type: The Type of the LSA — Type 2 in this case the Router LSA.
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
Network Mask: The Network Subnet Mask
Attached Router: All Router IDs that are fully adjacent with the DR, on the attached Network. DRs Router ID included.
Network LSAs can be eliminated from the LSDB if Point-to-Point is defined at interface type.
