
module ID_stage(pc, inst, opcode, EX_memread, id_haz, ex_haz, mem_haz, wr_reg_data, rs1_ind, rs2_ind,id_ex_rd_ind, wr_reg_from_wb,
			    id_flush,id_flush_mux_sel, Wrong_prediction, exception_flag, clk, pfc, rs1, rs2, pc_src, 
				pc_write, if_id_write, if_id_flush, imm,reg_write_from_wb, reg_write, mem_read, mem_write, rst);
	
	`include "opcodes.v"


	input rst;
	input [31:0] pc, inst, id_haz, ex_haz, mem_haz, wr_reg_data;
	input [6:0] opcode;
	input [4:0] rs1_ind, rs2_ind,id_ex_rd_ind, wr_reg_from_wb;
	input id_flush, Wrong_prediction, exception_flag, clk, reg_write_from_wb, EX_memread;
	
	output [31:0] pfc, rs1, rs2;
	output [2:0] pc_src;
	output pc_write, if_id_write, reg_write, mem_read, mem_write, if_id_flush;
	
	wire [31:0] mux_out, comp_oper1, comp_oper2;
	wire reg_write_wire, mem_read_wire, mem_write_wire, id_ex_stall;
	
	output wire [31:0] imm;
	output wire id_flush_mux_sel;
    
	REG_FILE reg_file(rs1_ind, rs2_ind, wr_reg_from_wb, wr_reg_data, rs1, rs2, reg_write_from_wb, clk, rst);
	
	Immed_Gen_unit immed_gen(inst, opcode, imm);
	
	assign pfc = (opcode == beq || opcode == bne) ? pc + imm : imm;
	/*
	always@(opcode , pc, imm) begin
		if (opcode == beq || opcode == bne)
			pfc <= pc + imm;
		else
			pfc <= imm;
	end
	*/
	
	
    BranchResolver BR(pc_src, exception_flag, opcode, Wrong_prediction, rst);
	
	// control section
    control_unit cu(opcode, reg_write_wire, mem_read_wire, mem_write_wire);
	StallDetectionUnit SDU(Wrong_prediction, opcode, EX_memread, rs1_ind, rs2_ind, id_ex_rd_ind, pc_write, if_id_write, if_id_flush, id_ex_stall);
	
	// control unit mux
	or flush(id_flush_mux_sel, id_flush, id_ex_stall);
	assign {reg_write, mem_read, mem_write} = (id_flush_mux_sel) ? 0 : {reg_write_wire, mem_read_wire, mem_write_wire};

endmodule