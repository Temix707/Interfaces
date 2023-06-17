module CSR(
    input         clk,
    input  [12:0] A,
    input  [31:0] WD,
    input  [2: 0] OP,
    input  [31:0] PC,
    input  [31:0] mcause_in,
    output reg  [31:0] RD,
    output reg [31:0] mie,
    output reg [31:0] mtvec,
    output reg [31:0] mepc
);

  reg [31:0] to_regs;
  reg [31:0] mscratch;
  reg [31:0] mcause;  
    always @(posedge clk) begin
       case (A)
          12'h304:
           if (OP[1] | OP[0])
               mie<=to_regs;
          
          12'h305: 
            if ( OP[1] | OP[0] )
                mtvec <= to_regs;
          12'h340:
           if ( OP[1] | OP[0] )
               mscratch <= to_regs; 
          12'h341: 
             if (( OP[1] | OP[0] )| OP[2] )
                mepc<= to_regs;
          12'h342: 
              if (( OP[1] | OP[0] )| OP[2] )
                 mcause <= to_regs; 
          endcase  
        if(OP[2]) begin
      mepc <= PC;
      mcause<= mcause_in;       
       end 
      end
      always@(*) begin
        case(A)
            12'h304: RD <= mie;
            12'h305: RD <= mtvec;
            12'h340: RD <= mscratch;
            12'h341: RD <= mepc;
            12'h342: RD <= mcause;
      endcase
       case(OP[1:0])
        2'b00: to_regs <= 32'b0; 
        
        2'b01: to_regs <= WD;   //funct3 001
        
        2'b10: to_regs <= RD & ~WD; //funct3 011
        
        2'b11: to_regs <= RD | WD; //funct3 010
    endcase
end

endmodule
