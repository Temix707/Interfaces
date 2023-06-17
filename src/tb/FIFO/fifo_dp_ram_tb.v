`timescale 1ns / 1ps

module fifo_dp_ram_tb
  #( parameter BIT_D = 32 )
  ();

  reg                  clk_i_tb;
  reg                  srst_i_tb;
  reg                  rd_i_tb;
  reg                  wr_i_tb;    
  reg     [BIT_D-1:0]  data_i_tb;
    
  wire    [BIT_D-1:0]  data_o_tb;
  wire    [2:0]        fifo_cnt_o_tb;
  wire                 wr_full_o_tb;
  wire                 rd_empty_o_tb;

  always #10 clk_i_tb = ~clk_i_tb;

  fifo_dp_ram dut(
    .clk_i            ( clk_i_tb ),
    .srst_i           ( srst_i_tb ),
    .rd_i             ( rd_i_tb ),
    .wr_i             ( wr_i_tb ),
    .data_i           ( data_i_tb ),
        
    .data_o           ( data_o_tb ),
    .fifo_cnt_o       ( fifo_cnt_o_tb ),
    .wr_full_o        ( wr_full_o_tb ),
    .rd_empty_o       ( rd_empty_o_tb )
  );

  initial begin
    clk_i_tb   = 1'b0;
    srst_i_tb  = 1'b0;
    rd_i_tb    = 1'b0;
    wr_i_tb    = 1'b0;    
    data_i_tb  = 8'd0;
  end


  initial begin
    srst_i_tb = 1'b1;
    #20
    srst_i_tb = 1'b0;
    
    Write ( clk_i_tb, 1'b1, 32'd7 );
    #20
    Write ( clk_i_tb, 1'b1, 32'd8 );
    #20
    Write ( clk_i_tb, 1'b1, 32'd6 );
    #20
    wr_i_tb = 1'b0;
    Read  ( clk_i_tb, 1'b1 );
    #20
    rd_i_tb = 1'b0;   
    Write ( clk_i_tb, 1'b1, 32'd12 );
    #20
    Write ( clk_i_tb, 1'b1, 32'd4 );
    #20
    Write ( clk_i_tb, 1'b1, 32'd9 );
    #20
    Write ( clk_i_tb, 1'b1, 32'd1 );
    #20
    wr_i_tb = 1'b0;
    Read  ( clk_i_tb, 1'b1 );
    #40
    rd_i_tb = 1'b0;
    Write ( clk_i_tb, 1'b1, 32'd10 );
    Read  ( clk_i_tb, 1'b1 );
    #20
        
    srst_i_tb = 1'b1;
    #40
        
    $stop;
  end

  task Write;
    input               clk_i_exp;
    input               wr_i_exp;
    input [BIT_D-1:0]   data_i_exp;
    begin
      clk_i_tb   =      clk_i_exp;
      wr_i_tb    =      wr_i_exp;
      data_i_tb  =      data_i_exp;
    end
  endtask
      
  task Read;
    input               clk_i_exp;
    input               rd_i_exp;
    begin
      clk_i_tb   =      clk_i_exp;
      rd_i_tb    =      rd_i_exp;
    end
  endtask
  
endmodule
