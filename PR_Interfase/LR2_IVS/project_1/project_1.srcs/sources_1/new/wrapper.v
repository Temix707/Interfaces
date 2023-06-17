`timescale 1ns / 1ps

module wrapper( 
    input [31:0]   IN,
    input          en,
    input          clk,
    input          rst, 
    output [31:0]  OUT
   
);
reg [7:0] PC = 8'b00000000;
    
   wire [31:0] rd ;
    wire [31:0] rd1;
    wire [31:0] Result;
    
    wire [31:0] rd2;       
    wire       b;
    wire       c;         
    wire [4:0] ra1;
    wire [4:0] ra2;
    wire [7:0] const; 
    wire [4:0] wa;
 
    wire [1:0] ws;
    wire ws_to_we3;
         
    wire [31:0] se;    
    
    wire  [31:0] mux_wd;      

    wire [7:0] adr;
    
    wire [7:0] mux_PC;
    wire [4:0] ALUOp;
    
    assign OUT = rd1;
    assign b = rd[31];
    assign c = rd[30];
    assign ra1 = rd [22:18];
    assign ra2= rd [17:13];
    assign const = rd [12:5];
    assign wa = rd [4:0];
    
    assign ws = rd[29:28];
    assign ws_to_we3 =  ws[1] | ws[0];
      
    assign  se = {{10{rd[31]}},rd [27:5]};
    
   
    assign mux_wd = ws[1]?(ws[0]? Result : se):( ws[0] ? IN : 23'b0);
    assign mux_PC = (b |( Flag & c)) ? rd[12:5] : 8'b00000001;
    assign ALUOp = rd[27:23];
   assign adr = PC;
   
        always @(posedge clk)
        begin 
        if(en)
        PC <= PC +  mux_PC;
        else
        PC <= PC;
        end 
      
  
        
        
        
    mem mem (
             .adr(adr),
             .rd_mem(rd)
             
             );
             
             
    alu ALU( 
             .A(rd1),
             .B(rd2),
             .ALUOp(ALUOp),
             .Result (Result),
             .Flag(Flag)
             );
             
    RF rf (
            .clk(clk),
            .a1(ra1),
            .a2(ra2),
            .a3(wa),
            .we_rf(ws_to_we3),
            .wd_rf(mux_wd), 
            .rd1(rd1),
            .rd2(rd2)
            );

            
    
endmodule

