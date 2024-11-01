
module MEM_WB_buffer(MEM_ALU_OUT, MEM_rs2, MEM_Data_mem_out, MEM_rs1_ind, MEM_rs2_ind, MEM_rd_ind, MEM_PC, MEM_INST, MEM_opcode,
					 MEM_memread, MEM_memwrite, MEM_regwrite, MEM_FLUSH, clk,
					 WB_ALU_OUT, WB_rs2, WB_Data_mem_out, WB_rs1_ind, WB_rs2_ind,
					 WB_rd_ind, WB_PC, WB_INST, WB_opcode, WB_memread, WB_memwrite, WB_regwrite, hlt);
	
	input [31:0] MEM_ALU_OUT, MEM_rs2, MEM_Data_mem_out, MEM_PC, MEM_INST;
	input [4:0] MEM_rs1_ind, MEM_rs2_ind, MEM_rd_ind;
	input [6:0] MEM_opcode;
	input MEM_memread, MEM_memwrite, MEM_regwrite, MEM_FLUSH, clk;
	
	
    output reg [31:0] WB_ALU_OUT, WB_rs2, WB_Data_mem_out, WB_PC, WB_INST;
	output reg [4:0] WB_rs1_ind, WB_rs2_ind, WB_rd_ind;
	output reg [6:0] WB_opcode;
	output reg WB_memread, WB_memwrite, WB_regwrite, hlt;	
	
	
	always@(negedge clk) begin

		if (MEM_opcode == 7'b1111111)
			hlt <= 1'b1;
		
		else if(!MEM_FLUSH) begin
			
			WB_ALU_OUT <= MEM_ALU_OUT;
			WB_rs2 <= MEM_rs2;
			WB_Data_mem_out <= MEM_Data_mem_out;
			WB_rs1_ind <= MEM_rs1_ind;
			WB_rs2_ind <= MEM_rs2_ind;
			WB_rd_ind <= MEM_rd_ind;
			WB_opcode <= MEM_opcode;
			WB_memread <= MEM_memread;
			WB_memwrite <= MEM_memwrite;
			WB_regwrite <= MEM_regwrite;
			WB_PC <= MEM_PC;
			WB_INST <= MEM_INST;
			hlt <= 1'b0;
		end 
		else 
        {WB_ALU_OUT, WB_PC, WB_INST, WB_rs2, WB_Data_mem_out, WB_rs1_ind, WB_rs2_ind, WB_rd_ind, WB_opcode, WB_memread, WB_memwrite, WB_regwrite, hlt} <= 0;
		
	end
	
endmodule