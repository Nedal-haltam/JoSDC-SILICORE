

module WB_stage(mem_out, alu_out, mem_read, wdata_to_reg_file);
	
	input [31:0] mem_out, alu_out;
	input mem_read;
	
// 	inout reg_write;
// 	inout [4:0] wr_reg;
	
	output [31:0] wdata_to_reg_file;

	MUX_2x1 wb_mux(alu_out , mem_out, mem_read, wdata_to_reg_file);
	
endmodule
