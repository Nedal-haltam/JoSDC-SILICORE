

module WB_stage(mem_out, alu_out, mem_read, Write_Data_RegFile);
	
	input [31:0] mem_out, alu_out;
	input mem_read;
	
	output [31:0] Write_Data_RegFile;

	assign Write_Data_RegFile = mem_out&{32{mem_read}} | alu_out&{32{~mem_read}};

endmodule
