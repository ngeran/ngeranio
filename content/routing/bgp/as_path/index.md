+++
title = 'AS Path'
date = 2024-12-17T16:04:48-05:00
draft = true
tags = ["BGP","Routing","Juniper"]
featured_image = 'featured.png'
summary = 'Indicate path back to the route source and prevents routing loops.'
+++


### Basics
The AS Path is a **well-known** and **mandatory** attribute, which means it must be supported by all BGP-speaking neighbors and must be included in the BGP update message. The AS Path is used to indicate the path back to the route source and to prevent routing loops.
Each eBGP router prepends its AS number to the AS Path. If a router receives a route with its own AS in the AS Path, it is considered looped and is rejected.