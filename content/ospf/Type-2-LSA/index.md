+++
title = 'Type 2 LSA - Network'
date = 2024-10-05T16:11:35+03:00
tags = ["OSPF","Posts","New"]
draft = false
+++

<p><em>Originated by the Designated Router and has Area Local Scope</em></p>
</blockquote>


<p>For each transit broadcast or NBMA networks the designated router originates a Network LSA only if it has at least one full adjacency to at least one other router. The Network LSA flooded throughout the area that contains the network and describes all the routers attached to the network.</p>

<blockquote class="wp-block-quote is-layout-flow wp-block-quote-is-layout-flow">
<p><em>The Designated Router includes itself int the router list</em></p>
</blockquote>



<pre class="wp-block-code"><code>0                   1                   2                   3
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
</code></pre>



<ul>
<li><strong>LS Age:</strong>&nbsp;The time in seconds since the LSA was originated.</li>
<li><strong>Options:&nbsp;</strong>Optional Capabilities supported.</li>
<li><strong>LS Type:&nbsp;</strong>The Type of the LSA —&nbsp;<strong>Type 2&nbsp;</strong>in this case the Router LSA.</li>
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
            5         The destination network's IP address.</code></pre>



<ul>
<li><strong>Advertising Router:</strong>&nbsp;The Router ID of the router that originated the LSA.</li>
<li><strong>LS Sequence Number:</strong>&nbsp;Used for old or duplicated LSA detection</li>
<li><strong>LS Checksum:</strong>&nbsp;Checksum of the complete LSA including the header</li>
<li><strong>Network Mask:</strong>&nbsp;The Network Subnet Mask</li>
<li><strong>Attached Router:&nbsp;</strong>All Router IDs that are fully adjacent with the DR, on the attached Network. DRs Router ID included.</li>
</ul>

<blockquote class="wp-block-quote is-layout-flow wp-block-quote-is-layout-flow">
<p><em>Network LSAs can be eliminated from the LSDB if Point-to-Point is defined at interface type.</em></p>