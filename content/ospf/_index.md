---
description: I provide in depth knowledge of tech topics on this website"
---


<h4>Overview</h4>
OSPF is an interior gateway protocol (IGP) that routes IP in a single routing domain. Each OSPF-speaking router in the network attempts to form an adjacency with each neighboring OSPF router. When these adjacencies are in place, each router generates and floods LSAs into the network in a reliable manner. The LSAs are placed into the LSDB on each router where the SPF algorithm is calculated to find the best path to each end node in the network.

<h4>Neighbors Use Hello Packets</h4>

OSPF routers send out hello packets to form and maintain adjacencies with their neighbors. Hellos are sent to AllSPFRoutes address (224.0.0.5), once OSPF speaking routes see hellos from another router, they will compare parameters and if they match will form an adjacency and become neighbors.

<h4>LSAs Are Flooded</h4>

OSPF uses IP protocol number 89 and the AllSPFRouters multicast address of 224.0.0.5 to flood LSAs. OSPF routers forward all LSAs through all OSPF configured interfaces except the one on which an LSA was received ( Split Horizon)

<h4>Hierarchical Design</h4>

OSPF gains scalability as a protocol through the use of a hierarchical design. Portions of the network are designated as separate areas. These remote areas are then connected through a common area known as the backbone.