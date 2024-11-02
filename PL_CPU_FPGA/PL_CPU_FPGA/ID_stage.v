
module ID_stage(pc, inst, opcode, id_haz, ex_haz, mem_haz, wr_reg_data, rs1_ind, rs2_ind,id_ex_rd_ind, wr_reg_from_wb, comp_selA, comp_selB, 
				    target_addr_adder_mux_sel, id_flush,id_flush_mux_sel, id_ex_memread, exception_flag, clk, pfc, rs1, rs2, pc_src, 
					 pc_write, if_id_write, imm,reg_write_from_wb, reg_write, mem_read, mem_write, rst);
	
	input rst;
	input [31:0] pc, inst, id_haz, ex_haz, mem_haz, wr_reg_data;
	input [6:0] opcode;
	input [4:0] rs1_ind, rs2_ind,id_ex_rd_ind, wr_reg_from_wb;
	input [1:0] comp_selA, comp_selB;
	input [2:0] target_addr_adder_mux_sel;
	input id_flush, id_ex_memread, exception_flag, clk, reg_write_from_wb;
	
	output [31:0] pfc, rs1, rs2;
	wire [28:0] paddedbits;
	output [1:0] pc_src;
	output pc_write, if_id_write, reg_write, mem_read, mem_write;
	
	wire [31:0] mux_out, comp_oper1, comp_oper2;
	wire reg_write_wire, mem_read_wire, mem_write_wire, id_ex_stall;
	
	output wire [31:0] imm;
	output wire id_flush_mux_sel;
    
	REG_FILE reg_file(rs1_ind, rs2_ind, wr_reg_from_wb, wr_reg_data, rs1, rs2, reg_write_from_wb, clk, rst);
	
	Immed_Gen_unit immed_gen(inst, opcode, imm);
	
	// compute target address
    MUX_8x1 target_addr_mux(id_haz, ex_haz, mem_haz, rs1 , pc , 0, 0, 0, target_addr_adder_mux_sel, mux_out);
	
	assign pfc = mux_out + imm;
	
	// comparator section
	MUX_4x1 comp_mux_oper1(id_haz, ex_haz, mem_haz, rs1, comp_selA, comp_oper1);
    MUX_4x1 comp_mux_oper2(id_haz, ex_haz, mem_haz, rs2, comp_selB, comp_oper2); 
	
    comparator comp(comp_oper1, comp_oper2, pc_src, exception_flag, opcode, rst);
	
	// control section
    control_unit cu(opcode, reg_write_wire, mem_read_wire, mem_write_wire);
	StallDetectionUnit SDU(id_ex_memread, opcode, rs1_ind, rs2_ind, id_ex_rd_ind, pc_write, if_id_write, id_ex_stall);
	
	// control unit mux
	or flush(id_flush_mux_sel, id_flush, id_ex_stall);
	assign {reg_write, mem_read, mem_write} = (id_flush_mux_sel) ? 0 : {reg_write_wire, mem_read_wire, mem_write_wire};

endmodule