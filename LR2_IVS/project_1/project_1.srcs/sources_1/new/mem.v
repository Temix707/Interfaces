`timescale 1ns / 1ps


module mem(
 input  [7:0]  adr,  

 output [31:0]  rd_mem   
);
	        
reg [31:0] RAM [0:255];

initial $readmemb ("instructions.mem",RAM);
                    
assign rd_mem =  RAM[adr];
endmodule
