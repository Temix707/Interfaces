import axi_lite_pkg::*;

module axi_lite_slave (
	input logic 			aclk,
	input logic 			areset_n,

	axi_lite_if.slave s_axi_lite
);

	typedef enum logic [2 : 0] {
		IDLE, 
		RADDR, 
		RDATA, 
		WADDR, 
		WDATA, 
		WRESP
	} state_type;
	
	state_type state, next_state;

	addr_t addr;
	data_t buffer[0 : 31];

	// AR
	assign s_axi_lite.arready = ( state == RADDR ) ? 1 : 0;

	// R
	assign s_axi_lite.rdata  	= ( state == RDATA ) ? buffer[addr] : 0;
	assign s_axi_lite.rresp  	= RESP_OKAY;
	assign s_axi_lite.rvalid 	= ( state == RDATA ) ? 1 : 0;

	// AW
	assign s_axi_lite.awready = ( state == WADDR ) ? 1 : 0;

	// W
	assign s_axi_lite.wready 	= ( state == WDATA ) ? 1 : 0;

	// B
	assign s_axi_lite.bvalid 	= ( state == WRESP ) ? 1 : 0;
	assign s_axi_lite.bresp  	= RESP_OKAY;



	// --------------------------------
	// ADDR
	// --------------------------------

	always_ff @( posedge aclk ) begin
		if ( ~areset_n ) begin
			addr <= 0;
		end 
		else begin
			case ( state )
				RADDR 	: addr <= s_axi_lite.araddr;
				WADDR 	: addr <= s_axi_lite.awaddr;
				default : addr <= 32'h0;
			endcase
		end
	end


	// --------------------------------
	// WDATA
	// --------------------------------

	always_ff @( posedge  aclk ) begin
		if ( ~areset_n ) begin
			for ( int i = 0; i < 32; i++ ) begin
				buffer[i] 		<= 32'h0;
			end
		end 
		else begin
			if ( state == WDATA ) begin
				buffer[addr] 	<= s_axi_lite.wdata;
			end
		end
	end


	// --------------------------------
	// FSM
	// --------------------------------

	always_ff @( posedge aclk ) begin
		if ( ~areset_n ) begin
			state <= IDLE;
		end 
		else begin
			state <= next_state;
		end
	end


	always_comb begin
		case ( state )
			IDLE 	: begin
				next_state = ( s_axi_lite.arvalid ) ? RADDR : ( s_axi_lite.awvalid ) ? WADDR : IDLE;
			end
			
			RADDR : begin
				if ( s_axi_lite.arvalid && s_axi_lite.arready ) 
					next_state 	= RDATA;
			end

			RDATA : begin 
				if ( s_axi_lite.rvalid  && s_axi_lite.rready ) 
					next_state 	= IDLE;
			end




			WADDR : begin 
				if ( s_axi_lite.awvalid && s_axi_lite.awready ) 
					next_state 	= WDATA;
			end
			
			WDATA : begin
				if ( s_axi_lite.wvalid  && s_axi_lite.wready ) 
					next_state 	= WRESP;
			end

			WRESP : begin
				if ( s_axi_lite.bvalid  && s_axi_lite.bready ) 
					next_state 	= IDLE;
			end

			default : next_state = IDLE;
		endcase
	end


endmodule 
