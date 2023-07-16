`timescale 1ns / 1ps


module spi_master_v2_tb();

  logic         clk_i;
  logic         arst_i;
  logic [15:0]  data_i;

  logic         spi_cs_l_o;    
  logic         spi_sclk_o;      
  logic         spi_data_o;     
  logic [4:0]   counter;         


  spi_master_v2 DUT_SPI
  (
    .clk_i        ( clk_i       ),
    .arst_i       ( arst_i      ),
    .data_i       ( data_i      ),

    .spi_cs_l_o   ( spi_cs_l_o  ),
    .spi_sclk_o   ( spi_sclk_o  ),
    .spi_data_o   ( spi_data_o  ),
    .counter      ( counter     )
  );

always #5 clk_i = ~clk_i;


initial begin
  clk_i  = 0;
  arst_i = 1;
  data_i = 0;
end

initial begin
  #10   arst_i = 1'b0;

  #10   data_i = 16'hA569;
  #335  data_i = 16'h2563;
  #335  data_i = 16'h9B63;
  #335  data_i = 16'h6A61;

  #335  data_i = 16'hA265;
  #335  data_i = 16'h7564;
end

endmodule
