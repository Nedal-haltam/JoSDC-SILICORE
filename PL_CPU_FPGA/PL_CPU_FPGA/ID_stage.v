
module ID_stage(pc, inst, ID_opcode, EX_opcode, EX_memread, id_haz, ex_haz, mem_haz, wr_reg_data, rs1_ind, rs2_ind,
				id_ex_rd_ind, wr_reg_from_wb,
			    id_ex_flush, Wrong_prediction, exception_flag, clk, PFC_to_IF, PFC_to_EX, predicted, rs1, rs2, pc_src, 
				pc_write, if_id_write, if_id_flush, imm,reg_write_from_wb, reg_write, mem_read, mem_write, rst, is_oper2_immed, 
				ID_is_beq, ID_is_bne, ID_is_jr, ID_is_jal, ID_is_j, is_branch_and_taken, forward_to_B);
	
	`include "opcodes.txt"


	input rst;
	input [31:0] pc, inst, id_haz, ex_haz, mem_haz, wr_reg_data;
	input [11:0] ID_opcode, EX_opcode;
	input [4:0] rs1_ind, rs2_ind,id_ex_rd_ind, wr_reg_from_wb;
	input Wrong_prediction, exception_flag, clk, reg_write_from_wb, EX_memread;
	
	output [31:0] PFC_to_IF, PFC_to_EX, rs1, rs2, forward_to_B;
	output [2:0] pc_src;
	output pc_write, if_id_write, reg_write, mem_read, mem_write, if_id_flush, predicted, is_oper2_immed,
		   ID_is_beq, ID_is_bne, ID_is_jr, ID_is_jal, ID_is_j;
	
	wire [31:0] mux_out, comp_oper1, comp_oper2;
	output id_ex_flush;
	
	output wire [31:0] imm;
    
	REG_FILE reg_file(rs1_ind, rs2_ind, wr_reg_from_wb, wr_reg_data, rs1, rs2, reg_write_from_wb, clk, rst);
	
	Immed_Gen_unit immed_gen(inst, ID_opcode, imm);
	// TODO: choose between the immediate and the rs2 here
	assign forward_to_B = (is_oper2_immed) ? imm : rs2;

	output wire is_branch_and_taken;
	assign is_branch_and_taken = (ID_is_beq || ID_is_bne) && predicted;

	assign PFC_to_IF[9:0] = (is_branch_and_taken) ? pc[9:0] + imm[9:0] : imm[9:0];
	assign PFC_to_EX[9:0] = (is_branch_and_taken) ? pc[9:0] : pc[9:0] + imm[9:0];
	assign PFC_to_IF[31:10] = 0;
	assign PFC_to_EX[31:10] = 0;

    BranchResolver BR(pc_src, exception_flag, ID_opcode, EX_opcode, predicted, Wrong_prediction, rst, clk);
	
	// control section
    control_unit cu(ID_opcode, reg_write, mem_read, mem_write, is_oper2_immed, ID_is_beq, ID_is_bne, ID_is_jr, ID_is_jal, ID_is_j);

	
	StallDetectionUnit SDU(Wrong_prediction, ID_opcode, EX_memread, rs1_ind, rs2_ind, id_ex_rd_ind, 
						  pc_write, if_id_write, if_id_flush, id_ex_flush);
	
endmodule