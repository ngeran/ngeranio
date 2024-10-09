+++
title = 'Type 5 LSA'
date = 2024-10-05T16:12:05+03:00
draft = false
+++

<p><em>Originated by the ASBR, describes networks external to OSPF domain and has domain flooding scope.</em></p>
</blockquote>

<pre class="wp-block-code"><code>
0                   1                   2                   3
0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|            LS age             |     Options   |      5        |
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
|E|     0       |                  metric                       |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                      Forwarding address                       |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                      External Route Tag                       |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|E|    TOS      |                TOS  metric                    |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                      Forwarding address                       |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                      External Route Tag                       |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
</code></pre>



<p id="33bf"><strong>Network Mask</strong>: Represents the subnet mask associated with the advertised network.</p>
<p id="e4c2"><strong>E bit</strong>: The E bit determines the type of external metric represented by the metric field.</p>
<p id="44b2">Type 1: E bit is set therefore, the encoded metric of the route should be added to the cost to reach the advertising ASBR</p>
<p id="77f6">Type 2 (default): E bit is not set, inter-area OSPF link cost is not taken into consideration.</p>
<p id="ed7f"><strong>Metric</strong>: This field represents the cost of the network as set by the ASBR.</p>
<p id="7600"><strong>Forwarding Address:</strong>&nbsp;Is the address toward which packets should be sent to reach the network. A value of 0.0.0.0 represents the ASBR itself.</p>
<p id="60f8"><strong>External Route Tag</strong>: This 32-bit value field can be assigned to the external route. OSPF does not use this value, but it might be interpreted by other protocols (similar to BGP communities).</p>
