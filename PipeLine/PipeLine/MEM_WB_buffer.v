
module MEM_WB_buffer
(
	clk, hlt, rst,
	MEM_ALU_OUT, MEM_Data_mem_out, MEM_rd_indzero, MEM_rd_ind, MEM_memread, MEM_regwrite, MEM_opcode,
	WB_ALU_OUT, WB_Data_mem_out, WB_rd_indzero, WB_rd_ind, WB_memread, WB_regwrite,
);
	
	input [31:0] MEM_ALU_OUT, MEM_Data_mem_out;
	input [11:0] MEM_opcode;
	input [4:0]  MEM_rd_ind;
	input MEM_memread, MEM_regwrite, clk, rst, MEM_rd_indzero;
	
	
    output reg [31:0] WB_ALU_OUT, WB_Data_mem_out;
	output reg [4:0]  WB_rd_ind;
	output reg WB_memread, WB_regwrite, hlt, WB_rd_indzero;	
	
	`include "opcodes.txt"
	
	always@(posedge clk, posedge rst) begin
		if (rst)
			{WB_ALU_OUT, WB_Data_mem_out, WB_rd_ind, WB_memread, WB_regwrite, hlt, WB_rd_indzero} <= 0;
		else begin
			WB_ALU_OUT <= MEM_ALU_OUT;
			WB_Data_mem_out <= MEM_Data_mem_out;
			WB_memread <= MEM_memread;
			WB_rd_ind <= MEM_rd_ind;
			WB_regwrite <= MEM_regwrite;
			WB_rd_indzero <= MEM_rd_indzero;
			hlt <= (MEM_opcode == hlt_inst) ? 1'b1 : 1'b0;
		end
	end

endmodule