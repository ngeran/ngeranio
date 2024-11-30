+++
title = 'Type 3 LSA - Network'
date = '2024-11-22T13:13:42-05:00'
tags = ["OSPF","LSA","Juniper"]
draft = false
summary = 'OSPF Type 3 LSA Summary'
featured_image = '/featured.jpg'
author = 'nikos'
author_image = '/io.png'
+++

<pre class="wp-block-code"><code>
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
</code></pre>

<blockquote class="wp-block-quote is-layout-flow wp-block-quote-is-layout-flow">
<p><em>Originated by the ABR — has area scope</em></p>
</blockquote>

<p id="4905">Describes networks outside of the area</p>

<ul>
<li><strong>Link State ID:</strong>&nbsp;Identifies the piece of the routing domain that<br>is being described by the LSA</li>
</ul>



<pre class="wp-block-code"><code>            LS Type   Link State ID
            _______________________________________________
            1         The originating router's Router ID.
            2         The IP interface address of the
                      network's Designated Router.
            3         The destination network's IP address.
            4         The Router ID of the described AS
                      boundary router.
            5         The destination network's IP address.
</code></pre>

<ul>
<li><strong>Advertising Router:</strong>&nbsp;The Router ID of the router that originated the LSA.</li>
<li><strong>LS Sequence Number:</strong>&nbsp;Used for old or duplicated LSA detection</li>
<li><strong>LS Checksum:</strong>&nbsp;Checksum of the complete LSA including the header</li>
<li>plus:</li>
<li><strong>(4-byte) Network Mask:&nbsp;</strong>Subnet mask of the advertised network. It is used in conjunction with the link-state ID filed, which encapsulates the network address in a Type 3 LSA.</li>



<li><strong>(1-byte) Reserved ( set to 0):</strong></li>
<li><strong>(3-byte) Metric:&nbsp;</strong>This field provides the cost of the route to the network destination.When the summary LSA is representing an aggregated route (using the area-range command), this field is set to the largest current metric of the contributing routes.</li>
<li><strong>(1-byte) ToS (not used):</strong>This field describes any optional ToS information encoded within the network described. The Junos OS does not use this field.</li>
<li><strong>(3-byte) ToS metric ( not used):</strong></li>
</ul>