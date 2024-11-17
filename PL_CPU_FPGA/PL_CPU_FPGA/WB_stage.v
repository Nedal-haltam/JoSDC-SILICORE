

module WB_stage(mem_out, alu_out, mem_read, wdata_to_reg_file);
	
	input [31:0] mem_out, alu_out;
	input mem_read;
	
	output [31:0] wdata_to_reg_file;

	assign wdata_to_reg_file = mem_out&{32{mem_read}} | alu_out&{32{~mem_read}};

	// assign wdata_to_reg_file = (mem_read) ? mem_out : alu_out;

endmodule
