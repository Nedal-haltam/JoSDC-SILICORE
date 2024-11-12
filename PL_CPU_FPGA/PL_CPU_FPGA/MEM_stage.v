

module MEM_stage(addr, wdata, mem_write, mem_read, reg_write, mem_out, /*forwarded_data,*/ clk);
	
    input [31:0] addr, wdata;
	input clk, mem_write, mem_read;
	inout reg_write;
	
	// output [31:0] forwarded_data;
	
	inout [31:0] mem_out;
	
    DM data_mem(addr, wdata, mem_out, mem_write , clk);

	// MUX_2x1 forward_mux(addr, mem_out, mem_read, forwarded_data);
	
endmodule