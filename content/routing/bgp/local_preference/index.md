+++
title = 'Local Preference'
date = 2024-12-12T17:30:21-05:00
draft = true
tags = ["BGP","Routing","Juniper","Attributes"]
featured_image = 'featured.png'
summary = 'The Power of Local Preference. The first BGP attribute used to favor a one route over another.'
+++

### Local Preference Power

The BGP attribute of local preference is the highest tiebreaker in the BGP path selection process. If a BGP next hop is reachable, and BGP knows multiple routes, BGP always chooses the route with the highest local preference. Thus, local preference is the first BGP attribute that favors one path over another. 


### Highest Local Prefernce Wins

Highest Local Preference Wins Because of the position of the BGP local preference, neither the AS-path length, nor the origin code, nor the MED value matter. The route with the highest local-preference value is always chosen as the exit point of the AS-the end. 