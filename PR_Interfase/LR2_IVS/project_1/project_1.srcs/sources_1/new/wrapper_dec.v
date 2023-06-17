`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.10.2022 22:45:30
// Design Name: 
// Module Name: wrapper_dec
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


module wrapper_dec(
    input [31:0]   instr,
    input          en,
    input          clk,
    input          rst, 
    output [31:0]  OUT

    );
    wire [31:0] op;
    wire [4:0] ra1;
    wire [4:0] ra2;
    wire [4:0] wa3;
    wire [11:0] imm_I;
    wire [11:0] imm_S;
    wire [19:0] imm_J;
    wire [11:0] imm_B;
    wire [31:0] rd1;
    wire [31:0] rd2;
    wire [31:0] A;
    wire [31:0] B;
    wire [31:0] result;
    wire [31 :0] rd;
    wire [31:0] wd3;
    wire [31:0] adr;
    wire [31:0] mux_add;
    wire [31:0] mux_PC_1;
    wire [31:0] mux_PC;
    
    wire [1:0] scrA;
    wire [2:0] scrB;
    wire b;
    wire comp;
    wire jal;
    wire jalr;
    wire wss;
    
    
    
    
    
    
    
    
    
    reg [31:0] PC;
    assign op = instr;
    assign ra1 =instr[19:5];
    assign ra2 =instr[24:20];
    assign wa3 = instr[11:7];
    assign imm_I = instr[31:20];
    assign imm_S = {instr[31:25],instr[11:7]}; //дополнить биты
    assign imm_J = {instr[31],instr[19:12],instr[20],instr[30:21]}; // доополнить биты
    assign imm_B = {instr[31],instr[7],instr[30:25],instr[11:8]}; 
    assign A = scrA[0] ?  32'b0 : (scrA[1] ? PC : rd1);
    assign B = scrB[0] ?  4 : (scrB[1] ? (scrB[2] ? imm_S : {instr[31:12],11'b0}): (scrB [2] ? imm_I : rd2));    
//   always@*    
//    case (scrB)
//      3'b000: B = rd2;
//      3'b001: B = imm_I;
//      3'b010: B = {instr[31:12],11'b0};
//      3'b011: B = imm_S;
//      3'b100: B = 4;
//   endcase
     assign mux_PC_1 = b ? imm_B : imm_J;
     assign mux_PC = (jal | (comp & b)) ? mux_PC_1 : 4;
      always @(posedge clk)
        begin 
        if(en)
        PC <= jalr ? rd1 : (PC + mux_PC);
        else
        PC <= jalr ? rd1 : PC;
        end 
     assign adr = PC;
     assign wd3 = wss ? rd : result;
     
     // подключить модули 
        
      
    
endmodule
