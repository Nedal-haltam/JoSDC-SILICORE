module EX_stage(pc, oper1, oper2, EX_opcode, alu_out, predicted, Wrong_prediction, rst, is_beq, is_bne, is_jal);
	
	`include "opcodes.txt"

	input [31:0] pc, oper1, oper2;
	input [11:0] EX_opcode;
	input predicted, rst, is_beq, is_bne, is_jal;
	
    output [31:0] alu_out; 
	output Wrong_prediction;
  
	wire [31:0] alu_outw;
	wire [3:0] ALU_OP;
	wire ZF, CF, BranchDecision;

    ALU_OPER alu_oper(EX_opcode, ALU_OP);
	
	ALU alu(oper1, oper2, alu_outw, ZF, CF, ALU_OP);

	assign alu_out = (is_jal) ? pc + 1'b1 : alu_outw;

	BranchDecision BDU(oper1, oper2, BranchDecision, is_beq, is_bne);

	assign Wrong_prediction = ~(rst || ~(BranchDecision ^ predicted));

endmodule