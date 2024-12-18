+++
title = 'AS Path'
date = 2024-12-17T16:04:48-05:00
draft = true
tags = ["BGP","Routing","Juniper"]
featured_image = 'featured.png'
summary = 'Indicate path back to the route source and prevents routing loops.'
+++


### Basics
The AS Path is a **well-known** and **mandatory** attribute, which means it must be supported by all BGP-speaking neighbors and must be included in the BGP update message. 

![AS PATH ](as_path-dark.png)

> Each external BGP router prepends its AS number (ASN) to the path.

The AS Path describes the path back to the route source, listing the autonomous systems that the route has traversed since its initial advertisement into BGP.  

To prevent routing loops, when a BGP-speaking router receives a route in a BGP update message, its first action is to check whether its own AS number (ASN) is present in the AS Path. If it is, this indicates that the route has already passed through the AS. Accepting such a route would create a loop; therefore, the router drops the route.  

The AS Path changes as the route moves between different autonomous systems. Initially, the AS Path is null until the route is advertised out of the originating AS. As the route leaves the AS, the router adds its local AS number to the front of the path before sending the route to the next AS peer.  

Junos before advertising the route to the next AS peer checks if the peers AS number listed in the path, if listed the router does not advertise the route.  

Using policy, we can modify the AS Path attribute before the route is readvertised to other BGP peers, making the path through the local AS more or less attractive to other autonomous systems. The way to alter the AS PATH is by adding to it by prepending.  
 
**Prepending** = artificialy adding informtion into AS PATH.