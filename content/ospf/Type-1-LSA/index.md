+++
title = 'Type 1 LSA'
date = 2024-10-05T08:45:39+03:00
draft = false
+++

<p>Type 1 LSAs are the Router LSAs each router in an area originates a Type 1 LSA. The Type 1 LSA describes the state and cost of the routers interfaces inside the area. If the router has more than one interface inside an area all interfaces must be described in a single Type 1 LSA. Type 1 LSAs have area local scope and ONLY flooded within a single area.</p>



<pre class="wp-block-code"><code>0                   1                   2                   3
0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|            LS age             |     Options   |       1       |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                        Link State ID                          |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                     Advertising Router                        |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                     LS sequence number                        |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|         LS checksum           |             length            |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|  0  Nt|W|V|E|B|        0      |            # links            |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                          Link ID                              |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                         Link Data                             |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|     Type      |     # TOS     |            metric             |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                              ...                              |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|      TOS      |        0      |          TOS  metric          |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                          Link ID                              |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                         Link Data                             |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
</code></pre>



<p><em>Common 20 byte header</em></p>



<ul>
<li><strong>LS Age:</strong>&nbsp;The time in seconds since the LSA was originated.</li>
<li><strong>Options:&nbsp;</strong>Optional Capabilities supported.</li>
<li><strong>LS Type:&nbsp;</strong>The Type of the LSA —&nbsp;<strong>Type 1</strong>&nbsp;in this case the Router LSA.</li>
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
</ul>


<p><em>Type 1 LSA</em></p>


<ul>
<li><strong>bit V:&nbsp;</strong>V is for virtual link endpoint.</li>
<li><strong>bit E:&nbsp;</strong>When set, the router is an AS boundary router (E is for<br>external).</li>
<li><strong>bit B:&nbsp;</strong>When set, the router is an area border router (B is for border).</li>
<li><strong># links:&nbsp;</strong>The number of router links described in this LSA. The total interfaces in the area.</li>
</ul>


<p>The following fields are used to describe each interface in the area</p>



<pre class="wp-block-code"><code>Type    Description
 __________________________________________________
 1       Point-to-point connection to another router
 2       Connection to a transit network
 3       Connection to a stub network
 4       Virtual link</code></pre>



<ul>
<li><strong>Link ID:</strong>&nbsp;Identifies the object that this router link connects to. Value depends on the link’s Type. When connecting to an object that also originates an LSA (i.e., another router or a transit network) the Link ID is equal to the neighboring LSA’s Link State ID. This provides the key for looking up the neighboring LSA in the link state database during the routing table calculation.</li>
</ul>



<pre class="wp-block-code"><code>Type   Link ID
 ______________________________________
 1     Neighboring router’s Router ID
 2     IP address of Designated Router
 3     IP network/subnet number
 4     Neighboring router’s Router ID</code></pre>



<ul>
<li><strong>Link Data:&nbsp;</strong>Value again depends on the link’s Type field. For connections to stub networks, Link Data specifies the network’s IP address mask. For unnumbered point-to-point connections, it specifies the interface’s MIB-II ifIndex value. For the other link types it specifies the router interface’s IP address. This latter piece of information is needed during the routing table<br>build process, when calculating the IP address of the next hop.</li>



<li><strong># TOS ( Type Of Service):</strong>&nbsp;The number of different TOS metrics given for this link, not counting the required link metric.</li>



<li><strong>metric:&nbsp;</strong>The cost of using this router link.</li>
<li><strong>TOS:</strong>&nbsp;Type of Service</li>
<li><strong>TOS metric:</strong>&nbsp;TOS-specific metric information.</li>
</ul>



<blockquote class="wp-block-quote is-layout-flow wp-block-quote-is-layout-flow">
<p id="a047">Router LSA — Type 1: Router LSAs example in Junos</p>
</blockquote>



<ul>
<li>The operational mode command&nbsp;<code>show ospf database router</code></li>
</ul>

<ol>
<li>The command shows all router LSAs in all areas</li>
<li>Can use&nbsp;<code>area&nbsp;</code>,&nbsp;<code>advertising-router&nbsp;</code>,&nbsp;<code>lsa-id&nbsp;</code>to narrow down the output results</li>
<li>Can use the&nbsp;<code>detail</code>&nbsp;and&nbsp;<code>extensive</code>&nbsp;flags to tailor output level of detail</li>

<li>Can use the&nbsp;<code>summary</code>&nbsp;flag for an overview of the LSAs</li>
</ol>

<figure class="wp-block-image"><img decoding="async" src="https://miro.medium.com/v2/resize:fit:1294/1*EVIbXaUwHpMm4FL_eXno9w.png" alt=""/></figure>
<figure class="wp-block-image"><img decoding="async" src="https://miro.medium.com/v2/resize:fit:1294/1*8rrBBOzfjHutyfx5q5Gqtw.png" alt=""/></figure>

<blockquote class="wp-block-quote is-layout-flow wp-block-quote-is-layout-flow">
<p><em>R2’s Originated — Router-LSA for AREA 0.0.0.0</em></p>
</blockquote>


<pre class="wp-block-code"><code>LS age = 697                   
Options = (B-bit)              
LS type = 1                    Router-LSA
ID = 172.30.5.2                RT2's router ID
Adv Rtr = 172.30.5.2           RT2's router ID
bit E = 0                      not an AS boundary router
bits 0x1(B = 1)                area border router
link count = 3                 3 attached interfaces in AREA 0 
       Link ID = 172.30.0.14   DR interface IP 
       Link Data = 172.30.0.13 R2’s Interface IP 
       Type = 2               Connects to Transit Network 
       # TOS metrics = 0      Type of Service 
       metric = 1
       Link ID = 172.30.0.18   DR interface IP 
       Link Data = 172.30.0.17 R2’s Interface IP 
       Type = 2               Connects to Transit Network 
       # TOS metrics = 0      Type of Service 
       metric = 1

       Link ID = 172.30.5.2         R2’s Loopback 
       Link Data = 255.255.255.255  Subnet Mask 
       Type = 3                     Connects to STUB network
       # TOS metrics = 0
       metric = 0
Type = Transit                      Link Type 
Node ID = 172.30.0.18               DR Interface IP 
Type = Transit                      Link Type 
Node ID = 172.30.0.14               DR Interface IP
Gen Timer = 00:36:46      How long until LSA regeneration 
Aging time = 00:39:47     How long until the LSA expires 
Installed = 00:20:13      LSA was installed
expires in = 00:48:23     If not refreshed 
sent = 00:11:35 ago       LSA was flooded
Last changed = 4d 17:22:47 ago The route was installed
Change Count = 19         Number of times the route was changed 
Ours Indicates that this is a local advertisement  </code></pre>
