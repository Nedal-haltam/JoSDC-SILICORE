

module MEM_stage(addr, wdata, mem_write, mem_read, reg_write, mem_out, clk);
	
    input [31:0] addr, wdata;
	input clk, mem_write, mem_read;
	inout reg_write;
	
	inout [31:0] mem_out;
	
    DM data_mem(addr, wdata, mem_out, mem_write , clk);

	
endmodule