

module proc(
    input          rst,
    input          clk,
    input  [31:0]  mepc,
    input  [31:0]  mtvec,
    input  [31:0] instr,
    output [31:0] adr,
    
    input [31:0]    data_rdata_i,
    output         data_req_o,   
    output         data_we_o,    
    output [3:0]   data_be_o,    
    output [31:0]  data_addr_o,  
    output [31:0]  data_wdata_o
   // input  [31:0]  int_req //запрос на прерывание
 
    );
    
    wire [4:0]  ra1;
    wire [4:0]  ra2;
    wire [4:0]  wa3;
    wire [31:0] imm_I;
    wire [31:0] imm_S;
    wire [31:0] imm_J;
    wire [31:0] imm_B;
    wire [31:0] rd1;
    wire [31:0] rd2;
    reg [31:0] A;
    reg [31:0] B;
    wire [31:0] result;
    wire [31:0] rd_lsu;
    wire [31:0] wd3;
    wire [31:0] mux_add;
    wire [31:0] mux_PC_1;
    wire [31:0] mux_PC;
    wire [31:0] mux_csr;
    wire [31:0] RD;
    wire [31:0] csr;
    wire we_rf;
    wire [1:0] muxA;
    wire [2:0] muxB;
    wire b;
    wire comp;
    wire jal;
    wire [1:0] jalr;
    wire wss;
    wire [31:0] alupa;
    wire [2:0] h;
    wire we_wr;
    reg [31:0] PC = 32'b0; 
    wire lsu_req_i;
    wire nen;
    wire en;
    wire [2:0] CSRop;
   assign en = ~nen;
    
    
    assign mux_csr = csr ? RD : wd3; 
    assign ra1 =instr[19:15];
    assign ra2 =instr[24:20];
    assign wa3 = instr[11:7];
    assign imm_I = {  {20{instr[31]}}  ,instr[31:20]};
    assign imm_S = {{20{instr[31]}} ,instr[31:25],instr[11:7]}; 
    assign imm_J = {{11{instr[31]}},instr[31],instr[19:12],instr[20],instr[30:21], 1'b0}; 
    assign imm_B = {{18{instr[31]}},instr[31],instr[7],instr[30:25],instr[11:8],1'b0}; 
  //  assign A = muxA[0] ?  32'b0 : (muxA[1] ? PC : rd1);
  always @*
    case(muxA)
        2'b00: A = rd1;
        2'b01: A = PC;
        2'b10: A =32'b0;
     endcase
   // assign B = muxB[0] ?  4 : (muxB[1] ? (muxB[2] ? imm_S : {instr[31:12],11'b0}): (muxB [2] ? imm_I : rd2));    
   always@*    
    case (muxB)
      3'b000: B = rd2;
      3'b001: B = imm_I;
      3'b010: B = {instr[31:12],11'b0};
      3'b011: B = imm_S;
      3'b100: B = 4;
   endcase
     assign mux_PC_1 = b ? imm_B : imm_J;
     assign mux_PC = (jal | (comp & b)) ? mux_PC_1 : 4;
      always @(posedge clk)
        begin 
        if(en)
     //PC <= PC+mux_PC;
      case(jalr)
            2'b00: PC <= PC + mux_PC;
            2'b01: PC <= rd1 + imm_I;
            2'b10: PC <= mepc;
            2'b11: PC <= mtvec;
            endcase
       // PC <= jalr ? (rd1+imm_I) : (PC+mux_PC);
        end
        
     assign adr = PC;//(PC[7:0] != 8'h0 )? PC[9:2] : 8'b0;
     //////////////////////////
     
     assign wd3 = wss ? rd_lsu : result;
     wire INT_to_dec;
     wire INT_RST_to_IC;
     
     
     dec dec ( 
               .fetched_instr_i (instr),
               .alu_op_o(alupa),
               .gpr_we_a_o(we_rf),
               .ex_op_a_sel_o (muxA),
               .ex_op_b_sel_o(muxB),
               .mem_we_o (we_wr),
               .wb_src_sel_o(wss),
               .mem_size_o(h),
               .mem_req_o(lsu_req_i),
               .branch_o(b),
               .jalr_o(jalr),
               .jal_o(jal),
               .csr(csr),
               .CSRop(CSRop),
               .INT(INT_to_dec),
               .INT_RST(INT_RST_to_IC)
               );
    
     RF rf ( 
             .clk(clk),
             .we_rf(we_rf),
             .a1(ra1),
             .a2(ra2),
             .a3(wa3), 
             .wd_rf(mux_csr),
             .rd1(rd1),
             .rd2(rd2)
             );      
   // data_memory dt(
   //                 .clk(clk),
   //                 .we_dt(we_wr),
   //                 .I(h),
   //                 .wd_dt(rd2),
   //                 .A(result),
   //                 .rd_dt(rd_dt)
   //                 );
   alu alu (
            .Result(result),
            .A(A),
            .B(B),
            .Flag(comp),
            .ALUOp(alupa)
            );
 // mem mem (
  //          .adr(adr),
   //         .rd_mem(instr)
  //         );
LS_U lsu(   .clk_i(clk),
            .lsu_addr_i(result),
            .lsu_we_i(we_wr),  
            .lsu_size_i(h),
            .lsu_data_i(rd2),
            .lsu_req_i(lsu_req_i),
            .lsu_stall_req_o(nen),
            .lsu_data_o(rd_lsu),
            .arstn_i(rst),
            .data_rdata_i (data_rdata_i),
            .data_req_o(data_req_o),   
            .data_we_o(data_we_o),    
            .data_be_o(data_be_o),    
            .data_addr_o(data_addr_o),  
            .data_wdata_o(data_wdata_o) 
            
          );
          wire[31:0] mcause;
          wire [31:0] mie_to_IC;
CSR CSR(    .OP(CSRop),
            .A(instr[31:20]),
            .WD(rd1),
            .PC(PC),
            .clk(clk),
            .RD(RD),
            .mcause_in(mcause),
            .mie(mie_to_IC),
            .mtvec(mtvec),
            .mepc(mepc)  
            );
        
            
 IC IC(      .clk(clk),    
             .mie(mie_to_IC),    
          //   .int_req(int_req),
             .INT_RST(INT_RST_to_IC),
             
             .INT(INT_to_dec),    
             .mcause(mcause)  
        );
  
endmodule
