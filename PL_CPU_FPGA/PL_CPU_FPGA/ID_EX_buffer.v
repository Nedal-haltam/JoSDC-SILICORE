
module ID_EX_buffer(ID_opcode, ID_rs1_ind, ID_rs2_ind, ID_rd_ind,
					ID_PC, ID_INST, ID_Immed, ID_rs1, ID_rs2, ID_regwrite,
					ID_memread, ID_memwrite, clk, ID_FLUSH, ID_PFC, ID_predicted, ID_is_oper2_immed, ID_is_beq, ID_is_bne,
					EX_opcode, EX_rs1_ind,
					EX_rs2_ind, EX_rd_ind, EX_PC,
					EX_INST, EX_Immed, EX_rs1,
					EX_rs2, EX_regwrite, EX_memread, EX_memwrite, EX_PFC, EX_predicted, EX_is_oper2_immed, rst, EX_is_beq, EX_is_bne);
					
`include "opcodes.v"
	
	input [6:0] ID_opcode;
	input [4:0] ID_rs1_ind, ID_rs2_ind, ID_rd_ind;
	input [31:0] ID_PC, ID_INST, ID_Immed, ID_rs1, ID_rs2, ID_PFC;
	input ID_regwrite, ID_memread, ID_memwrite, clk;
	input ID_FLUSH, rst, ID_predicted, ID_is_oper2_immed, ID_is_beq, ID_is_bne;
	
	output reg [6:0] EX_opcode;
	output reg [4:0] EX_rs1_ind, EX_rs2_ind, EX_rd_ind;
	output reg [31:0] EX_PC, EX_INST, EX_Immed, EX_rs1, EX_rs2, EX_PFC;
	output reg EX_regwrite, EX_memread, EX_memwrite, EX_predicted, EX_is_oper2_immed, EX_is_beq, EX_is_bne;
	
	always@(posedge clk, posedge rst) begin
		
	if (rst) begin
		{EX_opcode, EX_rs1_ind, EX_rs2_ind, EX_rd_ind, EX_PC, EX_INST, EX_Immed, EX_rs1, EX_rs2, EX_regwrite, EX_memread, EX_memwrite, EX_predicted, EX_is_oper2_immed, EX_is_beq, EX_is_bne} <= 0;
	end
	else if (!ID_FLUSH) begin
		
		EX_opcode <= ID_opcode;
		EX_rs1_ind <= ID_rs1_ind;
		EX_rs2_ind <= ID_rs2_ind;
		EX_rd_ind <= ID_rd_ind;
		EX_PC <= ID_PC;
		EX_INST <= ID_INST;
		EX_Immed <= ID_Immed;
		EX_rs1 <= ID_rs1;
		EX_rs2 <= ID_rs2;
		EX_regwrite <= ID_regwrite;
		EX_memread <= ID_memread;
		EX_memwrite <= ID_memwrite;
		EX_PFC <= ID_PC + 32'd1;
		EX_predicted <= ID_predicted;
		EX_is_oper2_immed <= ID_is_oper2_immed;
		EX_is_beq <= ID_is_beq; 
		EX_is_bne <= ID_is_bne;
			
		end 
		else
			{EX_opcode, EX_rs1_ind, EX_rs2_ind, EX_rd_ind, EX_PC, EX_INST, EX_Immed, EX_rs1, EX_rs2, EX_regwrite, EX_memread, EX_memwrite, EX_PFC, EX_predicted, EX_is_oper2_immed, EX_is_beq, EX_is_bne} <= 0;
		
	end
	
endmodule