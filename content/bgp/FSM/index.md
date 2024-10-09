+++
title = 'Finite State Machine'
date = 2024-10-05T08:45:08+03:00
draft = false
+++


<p>This article explains the BGP-FSM, the different states during the BGP neighbor negotiation and is based on Based on RFC 4271 Unlike IGP, BGP does not have its own transport protocol, the BGP peering sessions are manually defined and rely on TCP. TCP eliminates the need to implement explicit update fragmentation, retransmission, acknowledgement, and sequencing.</p>
<p><!-- /wp:paragraph --><!-- wp:paragraph --></p>
<p>BGP listens on TCP port 179 and BGP MUST maintain a separate FSM for each configured peer.</p>
<p><!-- /wp:paragraph --><!-- wp:paragraph --></p>
<p>Each BGP peer paired in a potential connection will attempt to connect to the other, unless configured to remain in the &#8216;idle&#8217; state, or configured to remain passive. Active or connecting is the side of the TCP connection sending the first TCP SYN packet. Passive or listening side is the sender of the first SYN/ACK.</p>						</div>
				</div>
					</div>
		</div>
							</div>
		</section>
				<section class="elementor-section elementor-top-section elementor-element elementor-element-6a67ee0a1 elementor-section-height-min-height elementor-section-boxed elementor-section-height-default elementor-section-items-middle wpr-particle-no wpr-jarallax-no wpr-parallax-no wpr-sticky-section-no" data-id="6a67ee0a1" data-element_type="section" data-settings="{&quot;background_background&quot;:&quot;gradient&quot;}">
						<div class="elementor-container elementor-column-gap-default">
					<div class="aux-parallax-section elementor-column elementor-col-100 elementor-top-column elementor-element elementor-element-3cb183f6" data-id="3cb183f6" data-element_type="column">
			<div class="elementor-widget-wrap elementor-element-populated">
								<div class="elementor-element elementor-element-eadf35a elementor-widget elementor-widget-heading" data-id="eadf35a" data-element_type="widget" data-widget_type="heading.default">
				<div class="elementor-widget-container">
			<h2 class="elementor-heading-title elementor-size-default">BGP Neighbor States</h2>		</div>
				</div>
				<div class="elementor-element elementor-element-5634eb26 elementor-widget elementor-widget-text-editor" data-id="5634eb26" data-element_type="widget" data-widget_type="text-editor.default">
				<div class="elementor-widget-container">
							<p>Six states are involved in the BGP process three for TCP connectivity and three for BGP connectivity as defined by RFC 4271.</p>						</div>
				</div>
				<div class="elementor-element elementor-element-7423683d wpr-table-align-items-center wpr-equal-column-width-yes wpr-data-table-type-custom elementor-widget elementor-widget-wpr-data-table" data-id="7423683d" data-element_type="widget" data-widget_type="wpr-data-table.default">
				<div class="elementor-widget-container">
			
				
		<div class="wpr-table-container">
		<div class="wpr-table-inner-container " data-table-sorting="" data-custom-pagination="" data-row-pagination="" data-entry-info="no" data-rows-per-page="">

		
			<table class="wpr-data-table" id="wpr-data-table">
								
				<thead>
					<tr class="wpr-table-head-row wpr-table-row">
					
						<th class="wpr-table-th elementor-repeater-item-54c3d14" colspan="1">
							<div class="">
																
																	<span class="wpr-table-text">TCP Connectivity</span>
																																															</div>
						</th>
						
						<th class="wpr-table-th elementor-repeater-item-5f38b7f" colspan="1">
							<div class="">
																
																	<span class="wpr-table-text">BGP Connectivity</span>
																																															</div>
						</th>
											</tr>
				</thead>

				<tbody>
									<tr class="wpr-table-body-row wpr-table-row elementor-repeater-item-274c601 wpr-odd">
													
							<td colspan="" rowspan="" class="elementor-repeater-item-1daa34c wpr-table-td">

								<div class="wpr-td-content-wrapper ">

									<img decoding="async" src="" class="wpr-data-table-th-img" alt="">																				<span>
									 
											<span class="wpr-table-text">
												Idle											</span>
																				</span>
																												
								</div>

							</td>
															
							<td colspan="" rowspan="" class="elementor-repeater-item-14afb25 wpr-table-td">

								<div class="wpr-td-content-wrapper ">

																													<span>
									 
											<span class="wpr-table-text">
												OpenSent											</span>
																				</span>
																												
								</div>

							</td>
												</tr>
			        					<tr class="wpr-table-body-row wpr-table-row elementor-repeater-item-c0f9080 wpr-even">
													
							<td colspan="" rowspan="" class="elementor-repeater-item-5ee6d0c wpr-table-td">

								<div class="wpr-td-content-wrapper ">

									<img decoding="async" src="" class="wpr-data-table-th-img" alt="">																				<a href="https://royal-elementor-addons.com/" target="_blank">
									 
											<span class="wpr-table-text">
												Connect											</span>
																				</a>
																												
								</div>

							</td>
															
							<td colspan="" rowspan="" class="elementor-repeater-item-d412f88 wpr-table-td">

								<div class="wpr-td-content-wrapper ">

																													<span>
									 
											<span class="wpr-table-text">
												OpenConfirm											</span>
																				</span>
																												
								</div>

							</td>
												</tr>
			        					<tr class="wpr-table-body-row wpr-table-row elementor-repeater-item-9553adb wpr-odd">
													
							<td colspan="" rowspan="" class="elementor-repeater-item-ed88921 wpr-table-td">

								<div class="wpr-td-content-wrapper ">

									<img decoding="async" src="" class="wpr-data-table-th-img" alt="">																				<a href="https://royal-elementor-addons.com/" target="_blank">
									 
											<span class="wpr-table-text">
												Active											</span>
																				</a>
																												
								</div>

							</td>
															
							<td colspan="" rowspan="" class="elementor-repeater-item-e31bb2d wpr-table-td">

								<div class="wpr-td-content-wrapper ">

																													<span>
									 
											<span class="wpr-table-text">
												Established
											</span>
																				</span>
																												
								</div>

							</td>
												</tr>
			        				</tbody>
			</table>
		</div>
		</div>
    			</div>
				</div>
					</div>
		</div>
							</div>
		</section>
				<section class="elementor-section elementor-top-section elementor-element elementor-element-c0abd12 elementor-section-boxed elementor-section-height-default elementor-section-height-default wpr-particle-no wpr-jarallax-no wpr-parallax-no wpr-sticky-section-no" data-id="c0abd12" data-element_type="section">
						<div class="elementor-container elementor-column-gap-default">
					<div class="aux-parallax-section elementor-column elementor-col-100 elementor-top-column elementor-element elementor-element-18e1a31" data-id="18e1a31" data-element_type="column">
			<div class="elementor-widget-wrap elementor-element-populated">
								<div class="elementor-element elementor-element-3918803 elementor-widget elementor-widget-aux_image" data-id="3918803" data-element_type="widget" data-widget_type="aux_image.default">
				<div class="elementor-widget-container">
			<section class="widget-container aux-widget-image aux-alignnone aux-parent-auc0288542">
    <div class="aux-media-hint-frame ">
        <div class="aux-media-image " >
        
            

            
            <img loading="lazy" decoding="async" width="842" height="578" src="https://ngeran.com/wp-content/uploads/2023/11/fsm-v1.png" class="aux-attachment aux-featured-image aux-attachment-id-1822" alt="fsm-v1" srcset="https://ngeran.com/wp-content/uploads/2023/11/fsm-v1-150x150.png 150w,https://ngeran.com/wp-content/uploads/2023/11/fsm-v1-300x300.png 300w,https://ngeran.com/wp-content/uploads/2023/11/fsm-v1-768x578.png 768w,https://ngeran.com/wp-content/uploads/2023/11/fsm-v1.png 842w" data-ratio="1" data-original-w="842" sizes="(max-width:479px) 480px,(max-width:767px) 768px,(max-width:1023px) 1024px,842px" />            
                </div>
    </div>

</section><!-- widget-container -->		</div>
				</div>
					</div>
		</div>
							</div>
		</section>
				<section class="elementor-section elementor-top-section elementor-element elementor-element-c9ccfea elementor-section-boxed elementor-section-height-default elementor-section-height-default wpr-particle-no wpr-jarallax-no wpr-parallax-no wpr-sticky-section-no" data-id="c9ccfea" data-element_type="section">
						<div class="elementor-container elementor-column-gap-default">
					<div class="aux-parallax-section elementor-column elementor-col-100 elementor-top-column elementor-element elementor-element-3e20b77" data-id="3e20b77" data-element_type="column">
			<div class="elementor-widget-wrap elementor-element-populated">
								<div class="elementor-element elementor-element-1d41d5f elementor-widget elementor-widget-text-editor" data-id="1d41d5f" data-element_type="widget" data-widget_type="text-editor.default">
				<div class="elementor-widget-container">
							<p><!-- /wp:image --><!-- wp:heading --><!-- /wp:heading --><!-- wp:paragraph --></p>
<h2 class="wp-block-heading">Idle State</h2>
<p>In this state, BGP refuses all incoming connections for the local system and no resources are allocated. In response to a ManualStart ( manually configure BGP on the local system ) event or an AutomaticStart ( restart existing session) BGP:</p>
<p><!-- /wp:paragraph --><!-- wp:list --></p>
<ul>
<li style="list-style-type: none;">
<ul><!-- wp:list-item --></ul>
</li>
</ul>
<ul>
<li style="list-style-type: none;">
<ul>
<li>initializes all BGP resources for the peer connection,</li>
</ul>
</li>
</ul>
<p><!-- /wp:list-item --><!-- wp:list-item --></p>
<ul>
<li style="list-style-type: none;">
<ul>
<li>sets ConncectRetryCounter to zero,</li>
</ul>
</li>
</ul>
<p><!-- /wp:list-item --><!-- wp:list-item --></p>
<ul>
<li style="list-style-type: none;">
<ul>
<li>starts the ConnectRetryTimer with the initial value,</li>
</ul>
</li>
</ul>
<p><!-- /wp:list-item --><!-- wp:list-item --></p>
<ul>
<li style="list-style-type: none;">
<ul>
<li>initiates the TCP connection to the other peer,</li>
</ul>
</li>
</ul>
<p><!-- /wp:list-item --><!-- wp:list-item --></p>
<ul>
<li style="list-style-type: none;">
<ul>
<li>listens for a connection that may be initiated by the remote BGP peer and</li>
</ul>
</li>
</ul>
<p><!-- /wp:list-item --><!-- wp:list-item --></p>
<ul>
<li style="list-style-type: none;">
<ul>
<li>changes its state to Connect.</li>
</ul>
</li>
</ul>
<p><!-- /wp:list-item --></p>
<p><!-- /wp:list --><!-- wp:paragraph --></p>
<p>In case of errors, BGP falls back to the Idle state.</p>						</div>
				</div>
					</div>
		</div>
							</div>
		</section>
				<section class="elementor-section elementor-top-section elementor-element elementor-element-c9ce3aa elementor-section-boxed elementor-section-height-default elementor-section-height-default wpr-particle-no wpr-jarallax-no wpr-parallax-no wpr-sticky-section-no" data-id="c9ce3aa" data-element_type="section">
						<div class="elementor-container elementor-column-gap-default">
					<div class="aux-parallax-section elementor-column elementor-col-100 elementor-top-column elementor-element elementor-element-64c118a" data-id="64c118a" data-element_type="column">
			<div class="elementor-widget-wrap elementor-element-populated">
								<div class="elementor-element elementor-element-fa3e39a elementor-widget elementor-widget-text-editor" data-id="fa3e39a" data-element_type="widget" data-widget_type="text-editor.default">
				<div class="elementor-widget-container">
							<h3>Connect State</h3>
<p><!-- /wp:heading --><!-- wp:paragraph --></p>
<p>BGP is waiting for the transport protocol connection to be completed.</p>
<p><!-- /wp:paragraph --><!-- wp:paragraph --></p>
<p><strong>If the TCP connection succeeds</strong></p>
<p><!-- /wp:paragraph --><!-- wp:list --></p>
<ul>
<li style="list-style-type: none;">
<ul><!-- wp:list-item --></ul>
</li>
</ul>
<ul>
<li style="list-style-type: none;">
<ul>
<li>stops the ConnectRetryTimer ( if running ) and sets the ConnectRetryTimer to zero,</li>
</ul>
</li>
</ul>
<p><!-- /wp:list-item --><!-- wp:list-item --></p>
<ul>
<li style="list-style-type: none;">
<ul>
<li>completes the BGP initialization</li>
</ul>
</li>
</ul>
<p><!-- /wp:list-item --><!-- wp:list-item --></p>
<ul>
<li style="list-style-type: none;">
<ul>
<li>sends an OPEN message to its peer,</li>
</ul>
</li>
</ul>
<p><!-- /wp:list-item --><!-- wp:list-item --></p>
<ul>
<li style="list-style-type: none;">
<ul>
<li>sets the HoldTimer to a large value ( the suggestion is 5min), and</li>
</ul>
</li>
</ul>
<p><!-- /wp:list-item --><!-- wp:list-item --></p>
<ul>
<li style="list-style-type: none;">
<ul>
<li>changes its state to OpenSent.</li>
</ul>
</li>
</ul>
<p><!-- /wp:list-item --></p>
<p><!-- /wp:list --><!-- wp:paragraph --></p>
<p><strong>If the TCP connection fails</strong></p>
<p><!-- /wp:paragraph --><!-- wp:list --></p>
<ul>
<li style="list-style-type: none;">
<ul><!-- wp:list-item --></ul>
</li>
</ul>
<ul>
<li style="list-style-type: none;">
<ul>
<li>restarts the ConnectRetryTimer,</li>
</ul>
</li>
</ul>
<p><!-- /wp:list-item --><!-- wp:list-item --></p>
<ul>
<li style="list-style-type: none;">
<ul>
<li>changes its state to Active.</li>
</ul>
</li>
</ul>
<p><!-- /wp:list-item --></p>
<p><!-- /wp:list --><!-- wp:paragraph --></p>
<p><strong>If the ConnectRetry timer expires</strong></p>
<p><!-- /wp:paragraph --><!-- wp:list --></p>
<ul>
<li style="list-style-type: none;">
<ul><!-- wp:list-item --></ul>
</li>
</ul>
<ul>
<li style="list-style-type: none;">
<ul>
<li>remains in the Connect state</li>
</ul>
</li>
</ul>
<p><!-- /wp:list-item --><!-- wp:list-item --></p>
<ul>
<li style="list-style-type: none;">
<ul>
<li>the timer is reset, and transport connection is initiated</li>
</ul>
</li>
</ul>
<p><!-- /wp:list-item --></p>
<p><!-- /wp:list --><!-- wp:paragraph --></p>
<p>In case of any other event the state goes back to Idle.</p>						</div>
				</div>
					</div>
		</div>
							</div>
		</section>
				<section class="elementor-section elementor-top-section elementor-element elementor-element-2b5d8bc elementor-section-boxed elementor-section-height-default elementor-section-height-default wpr-particle-no wpr-jarallax-no wpr-parallax-no wpr-sticky-section-no" data-id="2b5d8bc" data-element_type="section">
						<div class="elementor-container elementor-column-gap-default">
					<div class="aux-parallax-section elementor-column elementor-col-100 elementor-top-column elementor-element elementor-element-bb16ed2" data-id="bb16ed2" data-element_type="column">
			<div class="elementor-widget-wrap elementor-element-populated">
								<div class="elementor-element elementor-element-e70261f elementor-widget elementor-widget-text-editor" data-id="e70261f" data-element_type="widget" data-widget_type="text-editor.default">
				<div class="elementor-widget-container">
							<h2 class="wp-block-heading">Active State</h2>
<p><!-- /wp:heading --><!-- wp:paragraph --></p>
<p>In this state, BGP is trying to acquire a peer by listening for, and accepting a TCP connection</p>
<p><!-- /wp:paragraph --><!-- wp:paragraph --></p>
<p><strong>If the TCP connection succeeds</strong></p>
<p><!-- /wp:paragraph --><!-- wp:list --></p>
<ul>
<li style="list-style-type: none;">
<ul><!-- wp:list-item --></ul>
</li>
</ul>
<ul>
<li style="list-style-type: none;">
<ul>
<li>clears the BGP ConnectRetryTimer,</li>
</ul>
</li>
</ul>
<p><!-- /wp:list-item --><!-- wp:list-item --></p>
<ul>
<li style="list-style-type: none;">
<ul>
<li>sends an OPEN message to its peer,</li>
</ul>
</li>
</ul>
<p><!-- /wp:list-item --><!-- wp:list-item --></p>
<ul>
<li style="list-style-type: none;">
<ul>
<li>changes its state to OpenSent.</li>
</ul>
</li>
</ul>
<p><!-- /wp:list-item --></p>
<p><!-- /wp:list --><!-- wp:paragraph --></p>
<p><strong>If the TCP connection fails</strong></p>
<p><!-- /wp:paragraph --><!-- wp:list --></p>
<ul>
<li style="list-style-type: none;">
<ul><!-- wp:list-item --></ul>
</li>
</ul>
<ul>
<li style="list-style-type: none;">
<ul>
<li>resets the ConnectRetryTimer,</li>
</ul>
</li>
</ul>
<p><!-- /wp:list-item --><!-- wp:list-item --></p>
<ul>
<li style="list-style-type: none;">
<ul>
<li>changes its state to Idle.</li>
</ul>
</li>
</ul>
<p><!-- /wp:list-item --></p>
<p><!-- /wp:list --><!-- wp:paragraph --></p>
<p><strong>If the ConnectRetry timer expires</strong></p>
<p><!-- /wp:paragraph --><!-- wp:list --></p>
<ul>
<li style="list-style-type: none;">
<ul><!-- wp:list-item --></ul>
</li>
</ul>
<ul>
<li style="list-style-type: none;">
<ul>
<li>BGP restarts the ConnectRetry timer</li>
</ul>
</li>
</ul>
<p><!-- /wp:list-item --><!-- wp:list-item --></p>
<ul>
<li style="list-style-type: none;">
<ul>
<li>falls back to the Connect</li>
</ul>
</li>
</ul>
<p><!-- /wp:list-item --></p>
<p><!-- /wp:list --><!-- wp:paragraph --></p>
<p>The state might go back to Idle in case of other events, such as a Stop event initiated by the system or the operator. If the state is oscillating between Connect and Active indicates that something is wrong with the TCP transport connection.</p>						</div>
				</div>
					</div>
		</div>
							</div>
		</section>
				<section class="elementor-section elementor-top-section elementor-element elementor-element-5a91659 elementor-section-boxed elementor-section-height-default elementor-section-height-default wpr-particle-no wpr-jarallax-no wpr-parallax-no wpr-sticky-section-no" data-id="5a91659" data-element_type="section">
						<div class="elementor-container elementor-column-gap-default">
					<div class="aux-parallax-section elementor-column elementor-col-100 elementor-top-column elementor-element elementor-element-bf9f1d1" data-id="bf9f1d1" data-element_type="column">
			<div class="elementor-widget-wrap elementor-element-populated">
								<div class="elementor-element elementor-element-162a29c elementor-widget elementor-widget-text-editor" data-id="162a29c" data-element_type="widget" data-widget_type="text-editor.default">
				<div class="elementor-widget-container">
							<h2 class="wp-block-heading">OpenSent</h2>
<p><!-- /wp:heading --><!-- wp:paragraph --></p>
<p>In this state, BGP waits for an OPEN message from its peer. Once received checks all fields for correctness.</p>
<p><!-- /wp:paragraph --><!-- wp:paragraph --></p>
<p>The OPEN message contains:</p>
<p><!-- /wp:paragraph --><!-- wp:list --></p>
<ul>
<li style="list-style-type: none;">
<ul><!-- wp:list-item --></ul>
</li>
</ul>
<ul>
<li style="list-style-type: none;">
<ul>
<li>BGP version.</li>
</ul>
</li>
</ul>
<p><!-- /wp:list-item --><!-- wp:list-item --></p>
<ul>
<li style="list-style-type: none;">
<ul>
<li>The autonomous system (AS) number.</li>
</ul>
</li>
</ul>
<p><!-- /wp:list-item --><!-- wp:list-item --></p>
<ul>
<li style="list-style-type: none;">
<ul>
<li>The source IP address of the configured neighbor.</li>
</ul>
</li>
</ul>
<p><!-- /wp:list-item --><!-- wp:list-item --></p>
<ul>
<li style="list-style-type: none;">
<ul>
<li>Router-ID uniqueness.</li>
</ul>
</li>
</ul>
<p><!-- /wp:list-item --><!-- wp:list-item --></p>
<ul>
<li style="list-style-type: none;">
<ul>
<li>Security parameters ( TTL, password, etc)</li>
</ul>
</li>
</ul>
<p><!-- /wp:list-item --><!-- wp:list-item --></p>
<ul>
<li style="list-style-type: none;">
<ul>
<li>Capabilities.</li>
</ul>
</li>
</ul>
<p><!-- /wp:list-item --></p>
<p><!-- /wp:list --><!-- wp:paragraph --></p>
<p><strong>If there are errors or capabilities mismatch in the OPEN message the local system:</strong></p>
<p><!-- /wp:paragraph --><!-- wp:list --></p>
<ul>
<li style="list-style-type: none;">
<ul><!-- wp:list-item --></ul>
</li>
</ul>
<ul>
<li style="list-style-type: none;">
<ul>
<li>the system sends an error NOTIFICATION message</li>
</ul>
</li>
</ul>
<p><!-- /wp:list-item --><!-- wp:list-item --></p>
<ul>
<li style="list-style-type: none;">
<ul>
<li>goes back to Active.</li>
</ul>
</li>
</ul>
<p><!-- /wp:list-item --></p>
<p><!-- /wp:list --><!-- wp:paragraph --></p>
<p><strong>If there is an error due to TCP event </strong></p>
<p><!-- /wp:paragraph --><!-- wp:list --></p>
<ul>
<li style="list-style-type: none;">
<ul><!-- wp:list-item --></ul>
</li>
</ul>
<ul>
<li style="list-style-type: none;">
<ul>
<li>the state will change to Active</li>
</ul>
</li>
</ul>
<p><!-- /wp:list-item --><!-- wp:list-item --></p>
<ul>
<li style="list-style-type: none;">
<ul>
<li>will attempt to complete the three-way handshake.</li>
</ul>
</li>
</ul>
<p><!-- /wp:list-item --></p>
<p><!-- /wp:list --><!-- wp:paragraph --></p>
<p><strong>If there are no errors in the OPEN message the local system: </strong></p>
<p><!-- /wp:paragraph --><!-- wp:list --></p>
<ul>
<li style="list-style-type: none;">
<ul><!-- wp:list-item --></ul>
</li>
</ul>
<ul>
<li style="list-style-type: none;">
<ul>
<li>resets the DelayOpenTimer to zero,</li>
</ul>
</li>
</ul>
<p><!-- /wp:list-item --><!-- wp:list-item --></p>
<ul>
<li style="list-style-type: none;">
<ul>
<li>sets ConnectRetryTimer to zero,</li>
</ul>
</li>
</ul>
<p><!-- /wp:list-item --><!-- wp:list-item --></p>
<ul>
<li style="list-style-type: none;">
<ul>
<li>sends a KEEPALIVE message, and</li>
</ul>
</li>
</ul>
<p><!-- /wp:list-item --><!-- wp:list-item --></p>
<ul>
<li style="list-style-type: none;">
<ul>
<li>sets the HoldTimer per the negotiated value, and</li>
</ul>
</li>
</ul>
<p><!-- /wp:list-item --><!-- wp:list-item --></p>
<ul>
<li style="list-style-type: none;">
<ul>
<li>changes its state to OpenConfirm.</li>
</ul>
</li>
</ul>						</div>
				</div>
					</div>
		</div>
							</div>
		</section>
				<section class="elementor-section elementor-top-section elementor-element elementor-element-09f2506 elementor-section-boxed elementor-section-height-default elementor-section-height-default wpr-particle-no wpr-jarallax-no wpr-parallax-no wpr-sticky-section-no" data-id="09f2506" data-element_type="section">
						<div class="elementor-container elementor-column-gap-default">
					<div class="aux-parallax-section elementor-column elementor-col-100 elementor-top-column elementor-element elementor-element-213cc41" data-id="213cc41" data-element_type="column">
			<div class="elementor-widget-wrap elementor-element-populated">
								<div class="elementor-element elementor-element-304583d elementor-widget elementor-widget-text-editor" data-id="304583d" data-element_type="widget" data-widget_type="text-editor.default">
				<div class="elementor-widget-container">
							<h2 class="wp-block-heading">OpenConfirm</h2>
<p><!-- /wp:heading --><!-- wp:paragraph --></p>
<p>In this state, BGP waits for a KEEPALIVE or NOTIFICATION message.</p>
<p><!-- /wp:paragraph --><!-- wp:paragraph --></p>
<p>I<b>f a NOTIFICATION message is received,</b></p>
<p><!-- /wp:paragraph --><!-- wp:list --></p>
<ul>
<li style="list-style-type: none;">
<ul><!-- wp:list-item --></ul>
</li>
</ul>
<ul>
<li style="list-style-type: none;">
<ul>
<li>falls back to the Idle state</li>
</ul>
</li>
</ul>
<p><!-- /wp:list-item --></p>
<p><!-- /wp:list --><!-- wp:paragraph --></p>
<p>I<b>n case of any transport disconnect notification or in response to any stop event</b></p>
<p><!-- /wp:paragraph --><!-- wp:list --></p>
<ul>
<li style="list-style-type: none;">
<ul><!-- wp:list-item --></ul>
</li>
</ul>
<ul>
<li style="list-style-type: none;">
<ul>
<li>the state falls back to Idle state</li>
</ul>
</li>
</ul>
<p><!-- /wp:list-item --></p>
<p><!-- /wp:list --><!-- wp:paragraph --></p>
<p>I<b>f the local system receives a KEPALIVE the local system:</b></p>
<p><!-- /wp:paragraph --><!-- wp:list --></p>
<ul>
<li style="list-style-type: none;">
<ul><!-- wp:list-item --></ul>
</li>
</ul>
<ul>
<li style="list-style-type: none;">
<ul>
<li>restarts the HoldTimer and</li>
</ul>
</li>
</ul>
<p><!-- /wp:list-item --><!-- wp:list-item --></p>
<ul>
<li style="list-style-type: none;">
<ul>
<li>changes its state to Established.</li>
</ul>
</li>
</ul>
<p><!-- /wp:list-item --></p>
<p><!-- /wp:list --><!-- wp:paragraph --></p>
<p>The system sends periodic KEEPALIVE messages at the rate set by the KEEPALIVE timer.</p>						</div>
				</div>
					</div>
		</div>
							</div>
		</section>
				<section class="elementor-section elementor-top-section elementor-element elementor-element-765ec4b elementor-section-boxed elementor-section-height-default elementor-section-height-default wpr-particle-no wpr-jarallax-no wpr-parallax-no wpr-sticky-section-no" data-id="765ec4b" data-element_type="section">
						<div class="elementor-container elementor-column-gap-default">
					<div class="aux-parallax-section elementor-column elementor-col-100 elementor-top-column elementor-element elementor-element-79516f8" data-id="79516f8" data-element_type="column">
			<div class="elementor-widget-wrap elementor-element-populated">
								<div class="elementor-element elementor-element-2049297 elementor-widget elementor-widget-text-editor" data-id="2049297" data-element_type="widget" data-widget_type="text-editor.default">
				<div class="elementor-widget-container">
							<h2 class="wp-block-heading">Established</h2>
<p><!-- /wp:heading --><!-- wp:paragraph --></p>
<p>In the Established state, BGP can exchange UPDATE, NOTIFICATION and KEEPALIVE messages with its peer.</p>
<p><!-- /wp:paragraph --><!-- wp:paragraph --></p>
<p>If the HoldTimer expires before the local system receives a KEPALIVE, NOTIFICATION or an UPADTE message BGP will change its state to Idle.</p>
<p><!-- /wp:paragraph --><!-- wp:paragraph --></p>
<p>The UPDATE messages are checked for errors or missing attributes such as missing attributes. If errors are found, a NOTIFICATION message is sent to the peer, and the state falls back to Idle.</p>
<p><!-- /wp:paragraph --><!-- wp:paragraph --></p>
<p>If the Hold Timer expires, or a disconnect notification is received from the transport protocol, or a Stop event is received, or in response to any other event, the system falls back to the Idle state.</p>