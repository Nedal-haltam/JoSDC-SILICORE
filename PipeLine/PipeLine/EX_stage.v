module EX_stage(pc, EX_PFC, EX_PFC_to_IF, EX_opcode, ex_haz, mem_haz, rs1, EX_forward_to_B, 
				alu_selA, alu_selB, store_rs2_forward, rs2_in, rs2_out, 
				alu_out, predicted, Wrong_prediction, rst, is_beq, is_bne, is_jr);
	
	`include "opcodes.txt"

	input [31:0] pc, EX_PFC, ex_haz, mem_haz, rs1, EX_forward_to_B, rs2_in;
	input [11:0] EX_opcode;
    input [1:0] alu_selA, store_rs2_forward, alu_selB;
	input predicted, rst, is_beq, is_bne, is_jr;
	
    output [31:0] alu_out, rs2_out, EX_PFC_to_IF; 
	output Wrong_prediction;
  
	wire [31:0] oper1, oper2;
	wire [3:0] ALU_OP;
	wire ZF, CF, BranchDecision;
	
	MUX_4x1 alu_oper1(rs1, mem_haz, ex_haz, pc, alu_selA, oper1);
	
	MUX_4x1 alu_oper2(EX_forward_to_B, mem_haz, ex_haz, 32'd1, alu_selB, oper2);
	
	ALU alu(oper1, oper2, alu_out, ZF, CF, ALU_OP);

    ALU_OPER alu_oper(EX_opcode, ALU_OP);

	assign EX_PFC_to_IF = (is_jr) ? oper1 : EX_PFC;

    MUX_4x1 store_rs2_mux(rs2_in, ex_haz, mem_haz, 0, store_rs2_forward, rs2_out);

	BranchDecision BDU(oper1, oper2, BranchDecision, is_beq, is_bne);

	assign Wrong_prediction = ~(rst || ~(BranchDecision ^ predicted)) || is_jr;

endmodule