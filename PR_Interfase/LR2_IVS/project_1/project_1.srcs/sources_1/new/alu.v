`timescale 1ns / 1ps

`define SUM 5'b00000
`define SUBT 5'b01000  //A-B
`define SLT_SIGN_L 5'b00001  //A<<B
`define LESS_SIGN 5'b00010  //A<B
`define LESS_UNSIGN 5'b00011  //unsigned(A<B)
`define XOR 5'b00100  //A^B исключающее или
`define SLT_SIGN_R 5'b00101  //A>>B
`define SLT_ARITH 5'b01101  //A>>>B (A sign, B unsign)
`define OR 5'b00110  //A|B
`define AND 5'b00111  //A&B
`define EQUALITY 5'b11000  //A==B
`define NOT_EQUALITY 5'b11001  //A!=B
`define LESS_SIGN_FLAG 5'b11100  //A<B flag
`define MORE_OR_EQU 5'b11101  //A>=B
`define LESS_UNSIGN_FLAG 5'b11110  //unsigned(A<B) flag
`define MORE_OR_EQU_UNSIGN 5'b11111  //unsigned(A>=B)

module alu(A, B, ALUOp, Flag, Result);
 parameter WIDTH = 32;
input   [WIDTH-1:0] A;
input   [WIDTH-1:0] B;
input   [4:0] ALUOp;
output reg  Flag;
output reg [WIDTH-1:0] Result;

    always @(*) begin
    
        case (ALUOp)
        
          `SUM:
                begin
                    Flag = 0;
                    Result = A+B;          
               end
           `SUBT:
                begin
                    Flag = 0;
                    Result = A-B ;
                      end
           `SLT_SIGN_L:
                    begin
                    Flag = 0;
                    Result = A << B;
                end
                
            `LESS_SIGN:
                begin
                    Flag = 0;
                    Result = ( ( $signed(A) < $signed(B) ) ? 1 : 0);                  
                end
                
            `LESS_UNSIGN:
                begin
                    Flag = 0;
                    Result = ( ( A < B ) ? 1 : 0);
                end
                
            `XOR:
                begin
                    Flag = 0;
                    Result = ( A ^ B );
                end
                
            `SLT_SIGN_R:
                begin
                    Flag=0;
                    Result = A >> B;
                end
                
            `SLT_ARITH:
                begin
                    Flag=0;
                    Result = $signed(A) >>> B;
                end
                
            `OR:
                begin
                    Flag=0;
                    Result = ( ( A | B ) ? 1 : 0 );
                end
                
            `AND:
                begin
                    Flag=0;
                    Result = ( ( A & B ) ? 1 : 0 );
                end
                
            `EQUALITY:
                begin
                    Result=0;
                    Flag = A == B;
                end
                
            `NOT_EQUALITY:
                begin
                    Result=0;
                    Flag = A != B;
                end
                
            `LESS_SIGN_FLAG:
                begin
                    Result=0;
                    Flag = $signed(A) < $signed(B);
                end
                
            `MORE_OR_EQU:
                begin
                    Result=0;
                    Flag = $signed(A) >= $signed(B);
                end
                
            `LESS_UNSIGN_FLAG:
                begin
                    Result=0;
                    Flag = A < B;
                end
                
            `MORE_OR_EQU_UNSIGN:
                begin
                    Result=0;
                    Flag = A >= B;
                end
        
        endcase
end
  endmodule

