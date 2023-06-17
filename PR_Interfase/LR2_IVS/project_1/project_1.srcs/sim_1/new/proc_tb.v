`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.10.2022 20:05:48
// Design Name: 
// Module Name: proc_tb
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


module proc_tb();
    reg         rst;
    reg         clk;
    reg         en;

    initial clk = 0;
    always #10 clk =~clk;
proc dut ( .rstn_n_i(en), .clk_i(clk));
        initial begin
        #20;
        en =1; rst = 0;

   end 
endmodule
