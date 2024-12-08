
module EX_MEM_buffer
(
	clk, rst,
	EX_ALU_OUT, EX_rs2_out, EX_rd_indzero, EX_rd_ind, EX_opcode, EX_regwrite, EX_memread, EX_memwrite,
	MEM_ALU_OUT, MEM_rs2, MEM_rd_indzero, MEM_rd_ind, MEM_opcode, MEM_regwrite, MEM_memread, MEM_memwrite
);					 
	
	input [31:0] EX_ALU_OUT, EX_rs2_out;
	input [4:0]  EX_rd_ind;
	input [11:0] EX_opcode;
	input EX_regwrite, EX_memread, EX_memwrite, clk, rst, EX_rd_indzero;
	
	
	output reg [31:0] MEM_ALU_OUT, MEM_rs2;
	output reg [4:0]  MEM_rd_ind;
	output reg [11:0] MEM_opcode;
	output reg MEM_regwrite, MEM_memread, MEM_memwrite, MEM_rd_indzero;
	
	
	
	always@(posedge clk, posedge rst) begin
		
	if (rst) begin
		{MEM_ALU_OUT, MEM_rs2, MEM_rd_ind, MEM_opcode, MEM_memread, MEM_memwrite, MEM_regwrite, MEM_rd_indzero} <= 0;
	end
	else begin
			
		MEM_ALU_OUT <= EX_ALU_OUT;
		MEM_rs2 <= EX_rs2_out;
		MEM_rd_ind <= EX_rd_ind;
		MEM_opcode <= EX_opcode;
		MEM_memread <= EX_memread;
		MEM_memwrite <= EX_memwrite;
		MEM_regwrite <= EX_regwrite;
		MEM_rd_indzero <= EX_rd_indzero;
			
	end
end
	
endmodule