`timescale 1ns / 1ps

import axi_lite_pkg::*;

module tb_axi_lite_fifo_imem();
	
	logic 			aclk, areset_n;
	
	axi_lite_if axi_lite_if();
	
	logic 			start_read;
	logic 			start_write;


	localparam 	STEP = 10;
	
	axi_lite_master master(
		.aclk		      ( aclk				), 
		.areset_n		  ( areset_n		),
		.start_read		( start_read	), 
		.start_write	(	start_write	),

		.m_axi_lite		( axi_lite_if	)
	);

	axi_lite_fifo_imem  slave (
		.aclk					( aclk 				), 
		.areset_n			( areset_n 		),
		
		.s_axi_lite		( axi_lite_if )
	);



// --------------------------------
// TASK
// --------------------------------

  /*
	addr_t 	addr 		= 32'h4;
	data_t 	data 		= 32'hdeadbeef;
	int 		flag_w 	= 1, flag_r = 1;

	task test_write;
		if ( slave.imem[addr] != data ) flag_w = 0;
		$display("actual:%h expected:%h\n", slave.imem[addr], data);

		if ( flag_w ) 
			$display( "Pass" );
		else 
			$display( "Fail" );
	endtask : test_write



	task test_read;
		if ( axi_lite_if.wvalid && axi_lite_if.wready ) begin
			if ( master.rdata != data ) begin
				flag_r = 0;
			end
		end
		
		$display("actual:%h expected:%h\n", master.rdata, data);

		if ( flag_r ) 
			$display( "Pass" );
		else 
			$display( "Fail" );
	endtask : test_read
*/


// --------------------------------
// CLASS
// --------------------------------

	always begin
		aclk = 1; #(STEP / 2);
		aclk = 0; #(STEP / 2);
	end


// --------------------------------
// INITIAL
// --------------------------------

	initial begin
		start_read 	= 0; 
		start_write = 0;
		areset_n 		= 1;

		#(STEP) areset_n = 0;
		#(STEP * 3) areset_n = 1;
		
    // WRITE
    repeat ( COUT_REG_8KB + 10 ) begin
      start_write = 1; #(STEP); 
      start_write	= 0; #(STEP * 10);
    end
    $stop;

    // READ
    repeat ( COUT_REG_8KB + 10 ) begin
      start_read 	= 1; #(STEP) 
      start_read 	= 0; #(STEP * 10);
    end  
    $stop;



    // WRITE
    repeat ( 5 ) begin
      start_write = 1; #(STEP); 
      start_write	= 0; #(STEP * 10);
    end
    $stop;
   
    // READ
    repeat ( 3 ) begin
      start_read 	= 1; #(STEP) 
      start_read 	= 0; #(STEP * 10);
    end  
    $stop;

   	// test_write();
		// test_read();

		$finish;
	end



endmodule
