`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.11.2022 18:27:26
// Design Name: 
// Module Name: tb_miriscv_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



module tb_miriscv_top();

  parameter     HF_CYCLE = 2.5;       // 200 MHz clock
  parameter     RST_WAIT = 10;         // 10 ns reset
  parameter     RAM_SIZE = 256;       // in 32-bit words

  // clock, reset
  reg clk;
  reg rst_n;

  miriscv_top #(
    .RAM_SIZE       ( RAM_SIZE           ),
    .RAM_INIT_FILE  ( "instructions.mem" )
  ) dut (
    .clk_i    ( clk   ),
    .rst_n_i  ( rst_n )
  );

  initial begin
    clk   = 1'b0;
    rst_n = 1'b0;
    #RST_WAIT;
    rst_n = 1'b1;
  end

  always begin
    #HF_CYCLE;
    clk = ~clk;
  end

endmodule
