`timescale 1ns / 1ps

module tb_axi_lite_dmem 
# (
    parameter DATA_WIDTH      = 32,                             // Width of data bus in bits
    parameter ADDR_WIDTH      = 16,                             // Width of address bus in bits
    parameter STRB_WIDTH      = ( DATA_WIDTH / 8 ),             // Width of wstrb (width of data bus in words)
    parameter PIPELINE_OUTPUT = 0                               // Extra pipeline register on output
)
();


  reg                     clk_i;
  reg                     rst_i;

  reg   [ADDR_WIDTH-1:0]  s_axil_awaddr_i;      // ---- AW
  reg                     s_axil_awvalid_i;
  wire                    s_axil_awready_o;
    
  reg   [DATA_WIDTH-1:0]  s_axil_wdata_i;       // ---- W
  reg   [STRB_WIDTH-1:0]  s_axil_wstrb_i;
  reg                     s_axil_wvalid_i;
  wire                    s_axil_wready_o;
    
  wire  [1:0]             s_axil_bresp_o;       // ---- B 
  wire                    s_axil_bvalid_o;
  reg                     s_axil_bready_i;
    
  reg   [ADDR_WIDTH-1:0]  s_axil_araddr_i;      // ---- AR
  reg                     s_axil_arvalid_i;
  wire                    s_axil_arready_o;

  wire  [DATA_WIDTH-1:0]  s_axil_rdata_o;       // ---- R
  wire  [1:0]             s_axil_rresp_o;
  wire                    s_axil_rvalid_o;
  reg                     s_axil_rready_i;




  axi_lite_dmem DMEM (  
    .clk              ( clk_i             ),
    .rst              ( rst_i             ),

    .s_axil_awaddr    ( s_axil_awaddr_i   ),      // ---- AW
    .s_axil_awvalid   ( s_axil_awvalid_i  ),
    .s_axil_awready   ( s_axil_awready_o  ),
      
    .s_axil_wdata     ( s_axil_wdata_i    ),       // ---- W
    .s_axil_wstrb     ( s_axil_wstrb_i    ),
    .s_axil_wvalid    ( s_axil_wvalid_i   ),
    .s_axil_wready    ( s_axil_wready_o   ),
      
    .s_axil_bresp     ( s_axil_bresp_o    ),       // ---- B 
    .s_axil_bvalid    ( s_axil_bvalid_o   ),
    .s_axil_bready    ( s_axil_bready_i   ),
      
    .s_axil_araddr    ( s_axil_araddr_i   ),      // ---- AR
    .s_axil_arvalid   ( s_axil_arvalid_i  ),
    .s_axil_arready   ( s_axil_arready_o  ),

    .s_axil_rdata     ( s_axil_rdata_o    ),       // ---- R
    .s_axil_rresp     ( s_axil_rresp_o    ),
    .s_axil_rvalid    ( s_axil_rvalid_o   ),
    .s_axil_rready    ( s_axil_rready_i   )
  );


  always #10 clk_i = ~clk_i;



  // --------------------------------
	// TASK
	// --------------------------------
  
  task test_write_mem (
    input logic [15:0] addr,
    input logic [31:0] data
  );
    s_axil_awvalid_i = 1;
    s_axil_awaddr_i  = addr;
    s_axil_wdata_i   = data;

    s_axil_wvalid_i  = 1;

    //s_axil_bvalid_o  = 0;
    s_axil_bready_i  = 1;

    //s_axil_awready_o = 0;
    //s_axil_wready_o  = 0;
  endtask



  task test_read_mem (
    input logic [15:0] addr
  );


  endtask


  // -------------------------------- 
	// INITIAL
	// --------------------------------

  initial begin
    clk_i = 0;
    rst_i = 0;
    #17;
    rst_i = 1;
    #17;
    rst_i = 0;

    // WRITE
    test_write_mem( 16'd100, 32'd77 );
    #150;
    test_write_mem( 16'd4234  , 32'd42 );
    #150;

    $finish;

  end


  always_ff @( negedge s_axil_awready_o ) begin
    s_axil_awvalid_i = 0;
  end

endmodule