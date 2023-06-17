`timescale 1ns / 1ps

module RF(
    input         clk,
    input  [4:0]  a1,
    input  [4:0]  a2,
    input  [4:0]  a3,
    input         we_rf,
    input  [31:0] wd_rf,
    output [31:0] rd1, rd2
    );
    reg [31:0] RAM [0:31];

    assign rd1 = (a1==5'b0)? 32'b0:RAM[a1];   
    assign rd2 = (a1==5'b0) ?32'b0: RAM[a2];
    always @ (posedge clk) begin
        if(we_rf) 
        RAM[a3] <= wd_rf;
    end
        
endmodule
