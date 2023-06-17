`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.10.2022 12:22:27
// Design Name: 
// Module Name: mem_tbb
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


module mem_tbb();
    reg [7:0] adr;
    wire [31:0] rd;
    mem dut (adr,rd);
  initial begin
    #10;
    adr = 8'b00000001;   

  end 
  
    
endmodule
