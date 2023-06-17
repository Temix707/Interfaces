`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
           
  `define RESET_ADDR 32'h00000000

`define ALU_OP_WIDTH  5

`define ALU_ADD   5'b00000
`define ALU_SUB   5'b01000

`define ALU_XOR   5'b00100
`define ALU_OR    5'b00110
`define ALU_AND   5'b00111

// shifts
`define ALU_SRA   5'b01101
`define ALU_SRL   5'b00101
`define ALU_SLL   5'b00001

// comparisons
`define ALU_LTS   5'b11100
`define ALU_LTU   5'b11110
`define ALU_GES   5'b11101
`define ALU_GEU   5'b11111
`define ALU_EQ    5'b11000
`define ALU_NE    5'b11001

// set lower than operations
`define ALU_SLTS  5'b00010
`define ALU_SLTU  5'b00011

// opcodes
`define LOAD_OPCODE      5'b00_000
`define MISC_MEM_OPCODE  5'b00_011
`define OP_IMM_OPCODE    5'b00_100
`define AUIPC_OPCODE     5'b00_101
`define STORE_OPCODE     5'b01_000
`define OP_OPCODE        5'b01_100
`define LUI_OPCODE       5'b01_101
`define BRANCH_OPCODE    5'b11_000
`define JALR_OPCODE      5'b11_001
`define JAL_OPCODE       5'b11_011
`define SYSTEM_OPCODE    5'b11_100

// dmem type load store
`define LDST_B           3'b000
`define LDST_H           3'b001
`define LDST_W           3'b010
`define LDST_BU          3'b100
`define LDST_HU          3'b101

// operand a selection
`define OP_A_RS1         2'b00
`define OP_A_CURR_PC     2'b01
`define OP_A_ZERO        2'b10

// operand b selection
`define OP_B_RS2         3'b000
`define OP_B_IMM_I       3'b001
`define OP_B_IMM_U       3'b010
`define OP_B_IMM_S       3'b011
`define OP_B_INCR        3'b100

// writeback source selection
`define WB_EX_RESULT     1'b0
`define WB_LSU_DATA      1'b1




module dec(
    input [31:0]    fetched_instr_i,
    input           INT,
    output reg      INT_RST,
    output reg  [2:0]  CSRop,
    output reg         csr,
	output reg[1:0] ex_op_a_sel_o,
	output reg[2:0] ex_op_b_sel_o,
	output reg[`ALU_OP_WIDTH-1:0] alu_op_o,
	output reg mem_req_o,
	output reg mem_we_o,
  	output reg [2:0] mem_size_o,
	output reg gpr_we_a_o,
	output reg wb_src_sel_o,
	output reg illegal_instr_o,
	output reg branch_o,
	output reg jal_o,
	output reg [1:0] jalr_o
);
wire   [2:0]      funct3;
wire   [6:0]      funct7;

assign funct3 = fetched_instr_i[14:12];
assign funct7= fetched_instr_i[31:25];
always@(*) begin
	ex_op_a_sel_o = 2'b0;
	ex_op_b_sel_o = 3'b0;
	alu_op_o = `ALU_OP_WIDTH'b0;
	mem_req_o = 1'b0;
	mem_we_o = 1'b0;
	mem_size_o = 3'b0;
	gpr_we_a_o = 1'b0;
	wb_src_sel_o = 1'b0;
	branch_o = 1'b0;
	jal_o = 1'b0;
	jalr_o = 2'b00;
	illegal_instr_o = 1'b0;
	CSRop = 0;
    INT_RST = 0;
    csr = 0;
    
	if(fetched_instr_i[1:0] != 2'b11)
		illegal_instr_o = 1'b1;	
	else	
	case(fetched_instr_i[6:2]) 
		`OP_OPCODE:	
			begin
				
				gpr_we_a_o = 1'b1;
				case({funct7,funct3})
					10'b0000000_000: alu_op_o = `ALU_ADD;
					10'b0100000_000: alu_op_o = `ALU_SUB;
					10'b0000000_100: alu_op_o = `ALU_XOR;
					10'b0000000_110: alu_op_o = `ALU_OR;
					10'b0000000_111: alu_op_o = `ALU_AND;
					10'b0000000_001: alu_op_o = `ALU_SLL;
					10'b0000000_101: alu_op_o = `ALU_SRL;
					10'b0100000_101: alu_op_o = `ALU_SRA;
					10'b0000000_010: alu_op_o = `ALU_SLTS;
					10'b0000000_011: alu_op_o = `ALU_SLTU;
					default: illegal_instr_o = 1'b1;
				endcase
			end
		`OP_IMM_OPCODE: // ALU OP R-I
			begin
			//ex_op_a, wb_src_sel
			gpr_we_a_o = 1'b1;
			ex_op_b_sel_o = 3'd1;
				case(funct3)
					3'h0: alu_op_o = `ALU_ADD;
					3'h4: alu_op_o = `ALU_XOR;
					3'h6: alu_op_o = `ALU_OR;
					3'h7: alu_op_o = `ALU_AND;
					3'h1: 
						if(funct7 == 7'h00) 
							alu_op_o = `ALU_SLL;
						else 
							illegal_instr_o = 1'b1;
					3'h5:
						case(funct7)
							7'h00: alu_op_o = `ALU_SRL;
							7'h20: alu_op_o = `ALU_SRA;
							default: illegal_instr_o = 1'b1;
						endcase 
					3'h2: alu_op_o = `ALU_SLTS;
					3'h3: alu_op_o = `ALU_SLTU;
					default: illegal_instr_o = 1'b1;
				endcase
			end
		`LOAD_OPCODE: // LOAD INSTR
			begin
				//ex_op_a_sel_o
				gpr_we_a_o = 1'b1;
				wb_src_sel_o = 1'b1;
				mem_req_o = 1'b1;
				ex_op_b_sel_o = 3'h1;
				alu_op_o = `ALU_ADD;
				case(funct3) 
					3'h0: mem_size_o = `LDST_B;
					3'h1: mem_size_o = `LDST_H;
					3'h2: mem_size_o = `LDST_W;
					3'h4: mem_size_o = `LDST_BU;
					3'h5: mem_size_o = `LDST_HU;
					default: illegal_instr_o = 1'b1;
				endcase
			end
		`STORE_OPCODE: // STORE INSTR
			begin
				//ex_op_a_sel_o
				mem_req_o = 1'b1;
				mem_we_o = 1'b1;
				ex_op_b_sel_o = 3'h3;
				alu_op_o = `ALU_ADD;
				case(funct3) 
					3'h0: mem_size_o = `LDST_B;
					3'h1: mem_size_o = `LDST_H;
					3'h2: mem_size_o = `LDST_W;
					default: illegal_instr_o = 1'b1;
				endcase
			end	
		`BRANCH_OPCODE: // BRANCH INSTR
			begin
				// ex_op_a_sel_o, ex_op_b_sel_o
				branch_o = 1'b1;
				case(funct3) 
					3'h0: alu_op_o = `ALU_EQ;
					3'h1: alu_op_o = `ALU_NE;
					3'h4: alu_op_o = `ALU_LTS;
					3'h5: alu_op_o = `ALU_GES;
					3'h6: alu_op_o = `ALU_LTU;
					3'h7: alu_op_o = `ALU_GEU;
					default: illegal_instr_o = 1'b1;
				endcase
			end
		`JAL_OPCODE: // JAL INSTR
			begin
				// wb_src_sel_o, branch_o, jalr_o
				jal_o = 1'b1;
				ex_op_a_sel_o = 2'h1;
				ex_op_b_sel_o = 3'h4;
				alu_op_o = `ALU_ADD;
				gpr_we_a_o = 1'b1;
			end
		`JALR_OPCODE: // JALR INSTR
			begin
				if(funct3 != 3'h0)
			  illegal_instr_o = 1'b1;
				jalr_o = 2'b01;
				ex_op_a_sel_o = 2'h1;
				ex_op_b_sel_o = 3'h4;
				alu_op_o = `ALU_ADD;
				gpr_we_a_o = 1'b1;
			end
		`LUI_OPCODE: // LUI INSTR
			begin
				// wb_src_sel_o
				ex_op_a_sel_o = 2'h2;
				ex_op_b_sel_o = 3'h2;
				alu_op_o = `ALU_ADD;
				gpr_we_a_o = 1'b1;
			end
		`AUIPC_OPCODE:	// AUIPC INSTR
			begin
				// wb_src_sel_o
				ex_op_a_sel_o = 2'h1;
				ex_op_b_sel_o = 3'h2;
				alu_op_o = `ALU_ADD;
				gpr_we_a_o = 1'b1;
			end
		`MISC_MEM_OPCODE: 
			begin
				
			end
			
		`SYSTEM_OPCODE: // ECALL, EBREAK INSTR
			begin
			csr = 1'b1;
			 case(funct3)
                3'b000: //PC = mepc
                    begin
                    jalr_o    = 2'b10;
                    CSRop   =3'b100;
                        if (INT)begin
                        INT_RST =1;
                            end
                    end
                    
                3'b001: //rd = csr, csr = rs1
                    begin
                    jalr_o = 2'b11;
                    CSRop  = 3'b101;
                    end
                    
                3'b010: //rd = csr, csr = csr | rs1
                    begin
                    jalr_o = 2'b11;
                    CSRop = 3'b111;
                    end
                    
                3'b011: //rd = csr, csr = csr & ~rs1
                    begin
                    jalr_o  = 2'b11;
                    CSRop   = 3'b110;
                    end
                    
                default: illegal_instr_o = 1;
            endcase
            
				
			end

		default: 
			illegal_instr_o = 1'b1;
	endcase

end

endmodule               
                 
                 
                 
                 
                 
                 
                 
                 
                 
                 
                 
                 
                    
                   
                       
                            
                                   
                                      


