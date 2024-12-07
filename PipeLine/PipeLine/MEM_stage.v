

module MEM_stage(addr, Write_Data, mem_write, mem_read, mem_out, clk);
	
    input [31:0] addr, Write_Data;
	input clk, mem_write, mem_read;
	
	output [31:0] mem_out;
	
    DM data_mem(addr, Write_Data, mem_out, mem_write, clk);
	
endmodule