
module EX_MEM_buffer(EX_ALU_OUT, EX_rs2, EX_rs1_ind, EX_rs2_ind, EX_rd_indzero, EX_rd_ind,
					 EX_PC, EX_INST, EX_opcode, EX_memread, EX_memwrite, EX_regwrite, EX_FLUSH, clk,
					 MEM_ALU_OUT, MEM_rs2, MEM_rs1_ind, MEM_rs2_ind,
					 MEM_rd_indzero, MEM_rd_ind, MEM_PC, MEM_INST, MEM_opcode, MEM_memread, MEM_memwrite, MEM_regwrite, rst);
	
	input [31:0] EX_ALU_OUT, EX_rs2, EX_PC, EX_INST;
	input [4:0] EX_rs1_ind, EX_rs2_ind, EX_rd_ind;
	input [6:0] EX_opcode;
	input EX_memread, EX_memwrite, EX_regwrite, EX_FLUSH, clk, rst, EX_rd_indzero;
	
	
	output reg [31:0] MEM_ALU_OUT, MEM_rs2, MEM_PC, MEM_INST;
	output reg [4:0] MEM_rs1_ind, MEM_rs2_ind, MEM_rd_ind;
	output reg [6:0] MEM_opcode;
	output reg MEM_regwrite, MEM_memread, MEM_memwrite, MEM_rd_indzero;
	
	
	
	always@(posedge clk, posedge rst) begin
		
	if (rst) begin
		{MEM_ALU_OUT, MEM_PC, MEM_INST, MEM_rs2, MEM_rs1_ind, MEM_rs2_ind, MEM_rd_ind, MEM_opcode, MEM_memread, MEM_memwrite, MEM_regwrite, MEM_rd_indzero} <= 0;
	end
	else if (!EX_FLUSH) begin
			
		MEM_ALU_OUT <= EX_ALU_OUT;
		MEM_rs2 <= EX_rs2;
		MEM_rs1_ind <= EX_rs1_ind;
		MEM_rs2_ind <= EX_rs2_ind;
		MEM_rd_ind <= EX_rd_ind;
		MEM_opcode <= EX_opcode;
		MEM_memread <= EX_memread;
		MEM_memwrite <= EX_memwrite;
		MEM_regwrite <= EX_regwrite;
		MEM_PC <= EX_PC;
		MEM_INST <= EX_INST;
		MEM_rd_indzero <= EX_rd_indzero;
			
		end else
        {MEM_ALU_OUT, MEM_PC, MEM_INST, MEM_rs2, MEM_rs1_ind, MEM_rs2_ind, MEM_rd_ind, MEM_opcode, MEM_memread, MEM_memwrite, MEM_regwrite, MEM_rd_indzero} <= 0;
		
	end
	
endmodule