+++
title = 'BGP Attributes'
date = 2024-12-10T17:36:42-05:00
draft = false
tags = ["BGP","Routing","Juniper"]
featured_image = 'featured.png'
summary = 'BGP uses different attributes to control the advertisement and influence path selection'
+++


> BGP attributes are grouped in four separate categories:

### Well-known mandatory

**Must** be supported from all BGP neighbors and  
**Must** be included with every BGP update message.  

- Origin 
- AS_Path 
- Next_Hop

### Well-known discretionary

**Must** be supported from all BGP neighbors but   
do not have to be includes in all BGP update messages.

- Local_Preference
- Atomic-Aggregator

### Optional transitive 

Does not have to be supported by all BGP neighbors, but if
present it must be passed to other neighbors. 

- Community

### Optional nontransitive 

Does not have to be supported by all BGP neighbors, but If
such an attribute is not recognized, it is ignored and not passed to other neighbors.

- Multi_Exit_Discriminator
- Originator_ID
- Cluster_List

