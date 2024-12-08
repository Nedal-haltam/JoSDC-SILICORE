
module ID_stage(pc, inst, ID_opcode, EX_opcode, EX_memread, wr_reg_data, ID_rs1_ind, ID_rs2_ind,
				EX_rd_ind, WB_rd_ind,
			    ID_EX_flush, Wrong_prediction, exception_flag, clk, PFC_to_IF, PFC_to_EX, predicted_to_EX, rs1, rs2, PC_src, 
				pc_write, IF_ID_write, IF_ID_flush,reg_write_from_wb, reg_write, mem_read, mem_write, rst, is_oper2_immed, 
				ID_is_beq, ID_is_bne, ID_is_jr, ID_is_jal, ID_is_j, is_branch_and_taken, forward_to_B);
	
	`include "opcodes.txt"


	input rst;
	input [31:0] pc, inst, wr_reg_data;
	input [11:0] ID_opcode, EX_opcode;
	input [4:0] ID_rs1_ind, ID_rs2_ind, EX_rd_ind, WB_rd_ind;
	input Wrong_prediction, exception_flag, clk, reg_write_from_wb, EX_memread;
	
	output [31:0] PFC_to_IF, PFC_to_EX, rs1, rs2, forward_to_B;
	output [2:0] PC_src;
	output pc_write, IF_ID_write, reg_write, mem_read, mem_write, predicted_to_EX, is_oper2_immed,
		   ID_is_beq, ID_is_bne, ID_is_jr, ID_is_jal, ID_is_j;
	
	output IF_ID_flush, ID_EX_flush;
	
	wire [31:0] imm;
    
	wire predicted;

	REG_FILE reg_file(ID_rs1_ind, ID_rs2_ind, WB_rd_ind, wr_reg_data, rs1, rs2, reg_write_from_wb, clk, rst);
	
	Immed_Gen_unit immed_gen(inst, ID_opcode, imm);
	
	assign forward_to_B = (is_oper2_immed) ? imm : rs2;

	output wire is_branch_and_taken;
	assign is_branch_and_taken = (ID_is_beq || ID_is_bne) && predicted;

	assign PFC_to_IF[9:0] = ((ID_is_beq || ID_is_bne) && predicted) ? pc[9:0] + imm[9:0] : inst[9:0];
	assign PFC_to_EX[9:0] = ((ID_is_beq || ID_is_bne) && predicted_to_EX) ? pc[9:0] + 10'd1 : pc[9:0] + imm[9:0];
	assign PFC_to_IF[31:10] = 0;
	assign PFC_to_EX[31:10] = 0;

    BranchResolver BR(PC_src, exception_flag, ID_opcode, EX_opcode, predicted, predicted_to_EX, Wrong_prediction, rst, clk);
	
    control_unit cu(ID_opcode, reg_write, mem_read, mem_write, is_oper2_immed, ID_is_beq, ID_is_bne, ID_is_jr, ID_is_jal, ID_is_j);
	
	StallDetectionUnit SDU(Wrong_prediction, ID_opcode, EX_memread, ID_rs1_ind, ID_rs2_ind, EX_rd_ind, 
						  pc_write, IF_ID_write, IF_ID_flush, ID_EX_flush);
	
endmodule