module AXI_stream_top
# (
  parameter width = 8, depth = 10
)
(
  input                clk,
  input                rst,
 
// IN SLAVE
  input  [width - 1:0] up_data,
  input                up_valid,    // upstream
  output               up_ready,

// OUT MASTER
  input                down_ready,
  output               down_valid,  // downstream
  output [width - 1:0] down_data
);

  wire fifo_push;
  wire fifo_pop;
  wire fifo_empty;
  wire fifo_full;

  // SLAVE
  assign up_ready   = ~ fifo_full;
  assign fifo_push  = up_valid & up_ready;

  // MASTER
  assign down_valid = ~ fifo_empty;
  assign fifo_pop   = down_valid & down_ready;

  AXI_stream_optimized
  # (.width (width), .depth (depth))
  fifo
  (
    .clk        ( clk        ),
    .rst        ( rst        ),
    .push       ( fifo_push  ),
    .pop        ( fifo_pop   ),
    .write_data ( up_data    ),
    .read_data  ( down_data  ),
    .empty      ( fifo_empty ),
    .full       ( fifo_full  )
  );

endmodule


/*
  //                        SLAVE
  assign s_axi_lite.wready   = ~ fifo_full;
  assign fifo_push  = s_axi_lite.wvalid & s_axi_lite.wready;

  //                        MASTER
  assign s_axi_lite.rvalid = ~ fifo_empty;
  assign fifo_pop   = s_axi_lite.rvalid & s_axi_lite.rready;
*/