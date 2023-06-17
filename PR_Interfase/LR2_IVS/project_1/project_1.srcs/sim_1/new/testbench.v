`timescale 1ns / 100ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.09.2022 17:20:46
// Design Name: 
// Module Name: testbench
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
//`define SUM 5'b00000
//`define SUBT 5'b01000  //A-B
//`define SLT_SIGN_L 5'b00001  //A<<B
//`define LESS_SIGN 5'b00010  //A<B
//`define LESS_UNSIGN 5'b00011  //unsigned(A<B)
//`define XOR 5'b00100  //A^B исключающее или
//`define SLT_SIGN_R 5'b00101  //A>>B
//`define SLT_ARITH 5'b01101  //A>>>B (A sign, B unsign)
//`define OR 5'b00110  //A|B
//`define AND 5'b00111  //A&B
//`define EQUALITY 5'b11000  //A==B
//`define NOT_EQUALITY 5'b11001  //A!=B
//`define LESS_SIGN_FLAG 5'b11100  //A<B flag
//`define MORE_OR_EQU 5'b11101  //A>=B
//`define LESS_UNSIGN_FLAG 5'b11110  //unsigned(A<B) flag
//`define MORE_OR_EQU_UNSIGN 5'b11111  //unsigned(A>=B)

module ALU_tb();
    
    reg [31:0] scrA;
    reg [31:0] scrB;
    reg [4:0] oper;
    wire [31:0] result; 
    wire flag;  

    alu ALU_tb  //connect ALU to testbench
        (
            .Result(result),
            .A(scrA),
            .B(scrB),
            .ALUOp(oper),
            .Flag(flag));
      initial 
    begin           
 alu_test(5'b00000,1,2);
 #20
 alu_test(5'b01000,5,1); //A-B
 #20
 alu_test(5'b00010,1,6);//A<B
 #20
 alu_test(5'b00001,4,3);  //A<<B
 #20
 alu_test(5'b00011,2,9); //unsigned(A<B)
 #20
 alu_test(5'b00100,3,4);//A^B исключающее или
 #20
 alu_test(5'b00101,5,2);//A>>B
  
  end          
            task alu_test;  //task for ALU
        input [4:0]   oper_tb;
        input [31:0]  scrA_tb;
        input [31:0]  scrB_tb;
        begin
            oper=oper_tb;
            scrB=scrB_tb;
            scrA=scrA_tb;
            #10;

            
                $display("scrA= %d", scrA, " scrB = %d" , scrB, " result = %d", result);
                $display("Time = t", $realtime) ;
                
        end    
    endtask
    

endmodule




