`timescale 1ns / 1ps


module data_memory(
input [31: 0] wd_dt,
input [31: 0] A,//adr
input         clk,
input         we_dt,
input           I,
output [31:0] rd_dt
    );

reg [31:0] ram_dt [0:255];
assign rd_dt =  ram_dt[A];//(A[31:24] == 8'h60) ? rd_dt[A[9:2]]: 32'b0 ;
always @(posedge clk)
if (we_dt)
    ram_dt [A] <= wd_dt;
    
    
    

    endmodule
