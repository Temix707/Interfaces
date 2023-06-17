`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.11.2022 22:47:09
// Design Name: 
// Module Name: data_tb
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


module data_tb();
 reg [31:0]   wd_dt;
 reg         clk;
 reg [31:0] A;
    
    reg         we_dt;
    wire   [31:0]     rd_dt;
    initial clk = 0;
    always #10 clk =~clk;
data_memory dut (.wd_dt(wd_dt), .clk(clk), .A(A),.we_dt(we_dt),.rd_dt(rd_dt));
        initial begin
        #20;
        A=32'h2; wd_dt=32'h0; we_dt=1'b1;
     end

 
endmodule
