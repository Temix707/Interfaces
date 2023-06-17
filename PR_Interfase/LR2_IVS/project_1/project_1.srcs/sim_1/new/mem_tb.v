`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.10.2022 21:43:42
// Design Name: 
// Module Name: mem_tb
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


module mem_tb();
 reg  [32:0]  adr;  
 reg          clk;
 //input          we,
// input  [32:0]  wd,
 wire [32:0]  rd ;  
initial clk = 0;
always #30 clk =~clk;
		
mem DUT(adr, rd, clk);
    initial begin 
    



endmodule
