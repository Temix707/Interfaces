`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.09.2022 16:47:27
// Design Name: 
// Module Name: pr
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


module pr(
    input [15:0] SW,
    output [15:0] LED
    );
    alu alu(
    .A(SW[3:0]),
    .B(SW[7:4]),
    .ALUOp(SW[12:8]),
    .Result(LED[3:0]),
    .Flag(LED[15]));
endmodule
