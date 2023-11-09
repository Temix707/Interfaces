/*module axi_lite_intc_top(
  input	logic			    aclk,
  input logic			    areset_n,

  input logic 				start_read,
	input logic 				start_write
);

	localparam addr0 = 32'h4;
	localparam addr1 = 32'h14;

  axi_lite_if axi_lite_if_m0();
	axi_lite_if axi_lite_if_m1();
	axi_lite_if axi_lite_if_s0();
	axi_lite_if axi_lite_if_s1();

	axi_lite_master 
	#( addr0 ) 
	master0 (
		.aclk					( aclk 															), 
		.areset_n			( areset_n 													),
		.m_axi_lite		( axi_lite_if_m0 										),
		.start_read		( start_read_0 											), 
		.start_write	( start_write_0 										)
	);

	axi_lite_master 
	#( addr1 ) 
	master1 (
		.aclk					( aclk 															), 
		.areset_n			( areset_n 													),
		.m_axi_lite		( axi_lite_if_m1 										),
		.start_read		( start_read_1 											), 
		.start_write	( start_write_1 										)
	);

	axi_lite_slave slave0 (
		.aclk					( aclk 															), 
		.areset_n			( areset_n 													),
		.s_axi_lite		( axi_lite_if_s0 										)
	);

	axi_lite_slave slave1 (
		.aclk					( aclk 					 										), 
		.areset_n			( areset_n       										),
		.s_axi_lite		( axi_lite_if_s1 										)
	);

	axi_lite_interconnect axi_lite_ic (
		.aclk					( aclk															), 
		.areset_n			( areset_n													),
		.axim					( '{axi_lite_if_m0, axi_lite_if_m1}	), 
		.axis					( '{axi_lite_if_s0, axi_lite_if_s1}	)
	);



endmodule
*/