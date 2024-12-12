module ID_EX_buffer1
(
	clk, FLUSH, rst,
	ID_opcode, ID_rs1_ind, ID_rs2_ind, ID_rd_indzero, ID_rd_ind, ID_PC, ID_rs1, ID_rs2, ID_regwrite, ID_memread, ID_memwrite, ID_PFC_to_EX, ID_predicted, ID_is_oper2_immed, ID_is_beq, ID_is_bne, ID_is_jr, ID_is_jal, ID_forward_to_B,
	EX1_opcode, EX1_rs1_ind, EX1_rs2_ind, EX1_rd_indzero, EX1_rd_ind, EX1_PC, EX1_rs1, EX1_rs2, EX1_regwrite, EX1_memread, EX1_memwrite, EX1_PFC, EX1_predicted, EX1_is_oper2_immed, EX1_is_beq, EX1_is_bne, EX1_is_jr, EX1_is_jal, EX1_forward_to_B
);


`include "opcodes.txt"

input clk, FLUSH, rst;

input [11:0] ID_opcode;

input [4:0] ID_rs1_ind,
			ID_rs2_ind,
			ID_rd_ind;

input [31:0] ID_PC,
			 ID_rs1,
			 ID_rs2,
			 ID_PFC_to_EX,
			 ID_forward_to_B;


input ID_regwrite,
	  ID_memread,
	  ID_memwrite,
	  ID_predicted,
	  ID_is_oper2_immed,
	  ID_is_beq,
	  ID_is_bne,
	  ID_is_jr,
	  ID_is_jal,
	  ID_rd_indzero;


output reg [11:0] EX1_opcode;

output reg [4:0] EX1_rs1_ind,
			EX1_rs2_ind,
			EX1_rd_ind;

output reg [31:0] EX1_PC,
			 EX1_rs1,
			 EX1_rs2,
			 EX1_PFC,
			 EX1_forward_to_B;


output reg EX1_regwrite,
	  EX1_memread,
	  EX1_memwrite,
	  EX1_predicted,
	  EX1_is_oper2_immed,
	  EX1_is_beq,
	  EX1_is_bne,
	  EX1_is_jr,
	  EX1_is_jal,
	  EX1_rd_indzero;


always@(posedge clk, posedge rst) begin

if (rst) begin
{EX1_opcode, EX1_rs1_ind, EX1_rs2_ind, EX1_rd_ind, EX1_PC, EX1_rs1, EX1_rs2, EX1_regwrite, EX1_memread, 
EX1_memwrite, EX1_PFC, EX1_predicted, EX1_is_oper2_immed, EX1_is_beq, EX1_is_bne, EX1_is_jr, EX1_is_jal, EX1_forward_to_B, EX1_rd_indzero} <= 0;
end

else if (~FLUSH) begin
EX1_opcode <= ID_opcode;
EX1_rs1_ind <= ID_rs1_ind;
EX1_rs2_ind <= ID_rs2_ind;
EX1_rd_ind <= ID_rd_ind;
EX1_PC <= ID_PC;
EX1_rs1 <= ID_rs1;
EX1_rs2 <= ID_rs2;
EX1_regwrite <= ID_regwrite;
EX1_memread <= ID_memread;
EX1_memwrite <= ID_memwrite;
EX1_PFC <= ID_PFC_to_EX;
EX1_predicted <= ID_predicted;
EX1_is_oper2_immed <= ID_is_oper2_immed;
EX1_is_beq <= ID_is_beq;
EX1_is_bne <= ID_is_bne;
EX1_is_jr <= ID_is_jr;
EX1_is_jal <= ID_is_jal;
EX1_forward_to_B <= ID_forward_to_B;
EX1_rd_indzero <= ID_rd_indzero;
end

else begin
{EX1_opcode, EX1_rs1_ind, EX1_rs2_ind, EX1_rd_ind, EX1_PC, EX1_rs1, EX1_rs2, EX1_regwrite, EX1_memread, 
EX1_memwrite, EX1_PFC, EX1_predicted, EX1_is_oper2_immed, EX1_is_beq, EX1_is_bne, EX1_is_jr, EX1_is_jal, EX1_forward_to_B, EX1_rd_indzero} <= 0;
end


end
endmodule




module ID_EX_buffer2
(
	clk, FLUSH, rst,
	EX1_ALU_OPER1, EX1_ALU_OPER2, EX1_opcode, EX1_rs1_ind, EX1_rs2_ind, EX1_rd_indzero, EX1_rd_ind, EX1_PC, EX1_rs1, EX1_rs2_out, EX1_regwrite, EX1_memread, EX1_memwrite, EX1_predicted, EX1_is_oper2_immed, EX1_is_beq, EX1_is_bne, EX1_is_jr, EX1_is_jal, EX1_forward_to_B, EX1_PFC_to_IF, 
	EX2_ALU_OPER1, EX2_ALU_OPER2, EX2_opcode, EX2_rs1_ind, EX2_rs2_ind, EX2_rd_indzero, EX2_rd_ind, EX2_PC, EX2_rs1, EX2_rs2_out, EX2_regwrite, EX2_memread, EX2_memwrite, EX2_predicted, EX2_is_oper2_immed, EX2_is_beq, EX2_is_bne, EX2_is_jr, EX2_is_jal, EX2_forward_to_B,	EX2_PFC_to_IF
);

`include "opcodes.txt"

input clk, FLUSH, rst;


input [31:0] EX1_ALU_OPER1,
EX1_ALU_OPER2,
EX1_PC,
EX1_rs1,
EX1_rs2_out,
EX1_forward_to_B,
EX1_PFC_to_IF;

input [11:0] EX1_opcode;

input [4:0] EX1_rs1_ind,
EX1_rs2_ind,
EX1_rd_ind;

input EX1_regwrite,
EX1_memread,
EX1_memwrite,
EX1_predicted,
EX1_is_oper2_immed,
EX1_is_beq,
EX1_is_bne,
EX1_is_jr,
EX1_is_jal,
EX1_rd_indzero;




output reg [31:0] EX2_ALU_OPER1,
EX2_ALU_OPER2,
EX2_PC,
EX2_rs1,
EX2_rs2_out,
EX2_forward_to_B,
EX2_PFC_to_IF;

output reg [11:0] EX2_opcode;

output reg [4:0] EX2_rs1_ind,
EX2_rs2_ind,
EX2_rd_ind;

output reg EX2_regwrite,
EX2_memread,
EX2_memwrite,
EX2_predicted,
EX2_is_oper2_immed,
EX2_is_beq,
EX2_is_bne,
EX2_is_jr,
EX2_is_jal,
EX2_rd_indzero;





always@(posedge clk, posedge rst) begin

if (rst) begin
{EX2_ALU_OPER1, EX2_ALU_OPER2, EX2_opcode, EX2_rs1_ind, EX2_rs2_ind, EX2_rd_ind, EX2_PC, EX2_rs1, EX2_rs2_out, EX2_regwrite, EX2_memread, 
EX2_memwrite, EX2_predicted, EX2_is_oper2_immed, EX2_is_beq, EX2_is_bne, EX2_is_jr, EX2_is_jal, EX2_forward_to_B, EX2_PFC_to_IF, EX2_rd_indzero} <= 0;
end

else if (~FLUSH) begin
EX2_ALU_OPER1 <= EX1_ALU_OPER1;
EX2_ALU_OPER2 <= EX1_ALU_OPER2;
EX2_opcode <= EX1_opcode;
EX2_rs1_ind <= EX1_rs1_ind;
EX2_rs2_ind <= EX1_rs2_ind;
EX2_rd_ind <= EX1_rd_ind;
EX2_PC <= EX1_PC;
EX2_rs1 <= EX1_rs1;
EX2_rs2_out <= EX1_rs2_out;
EX2_regwrite <= EX1_regwrite;
EX2_memread <= EX1_memread;
EX2_memwrite <= EX1_memwrite;
EX2_predicted <= EX1_predicted;
EX2_is_oper2_immed <= EX1_is_oper2_immed;
EX2_is_beq <= EX1_is_beq;
EX2_is_bne <= EX1_is_bne;
EX2_is_jr <= EX1_is_jr;
EX2_is_jal <= EX1_is_jal;
EX2_forward_to_B <= EX1_forward_to_B;
EX2_PFC_to_IF <= EX1_PFC_to_IF;
EX2_rd_indzero <= EX1_rd_indzero;
end

else begin
{EX2_ALU_OPER1, EX2_ALU_OPER2, EX2_opcode, EX2_rs1_ind, EX2_rs2_ind, EX2_rd_ind, EX2_PC, EX2_rs1, EX2_rs2_out, EX2_regwrite, EX2_memread, 
EX2_memwrite, EX2_predicted, EX2_is_oper2_immed, EX2_is_beq, EX2_is_bne, EX2_is_jr, EX2_is_jal, EX2_forward_to_B, EX2_PFC_to_IF, EX2_rd_indzero} <= 0;
end

end


endmodule