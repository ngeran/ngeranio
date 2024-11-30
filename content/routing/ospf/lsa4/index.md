+++
title = 'Type 4 LSA - Network'
date = '2024-11-22T13:13:46-05:00'
tags = ["OSPF","LSA","Juniper"]
draft = false
summary = 'OSPF Type 4 LSA Summary'
featured_image = 'featured.jpg'
author = 'nikos'
author_image = '/io.png'
+++

<p><em>Originated by ABR and has Area Scope</em></p>
</blockquote>



<p>Describe the location of a router that is injecting external routes into OSPF. The ASBR will generate a Type 1 LSA with the E bit set, when this LSA is received from other ABRs the Router Type 1 LSA will be converted to a Type 4 LSA when it is flooded into other Areas to let other router know how to reach the External route through the ASBR</p>



<pre class="wp-block-code"><code>0                   1                   2                   3
0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|            LS age             |     Options   |       4       |
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
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+</code></pre>



<p id="bbd3"><strong>Link State ID</strong>: Router ID of the ASBR.</p>
<p id="2293">Advertising Router: Router ID of the ABR advertising the ASBR Summary LSA.</p>
<p id="9b8d">Network Mask: Set to all zeros.</p>
<p id="a452">Metric: Cost to reach the ASBR.</p>
