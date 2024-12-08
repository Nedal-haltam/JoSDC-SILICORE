module forwardB
(
	EX1_rs2_ind, 
	
	EX2_rd_indzero, EX2_rd_ind, EX2_regwrite, 
	MEM_rd_indzero, MEM_rd_ind, MEM_regwrite, 
	WB_rd_indzero, WB_rd_ind, WB_regwrite,
	
	alu_selB, EX1_is_oper2_immed
);

`include "opcodes.txt"

input [4:0] EX1_rs2_ind, EX2_rd_ind, MEM_rd_ind, WB_rd_ind;

input EX2_rd_indzero, MEM_rd_indzero, WB_rd_indzero;
input EX2_regwrite, MEM_regwrite, WB_regwrite;
input EX1_is_oper2_immed;

output [1:0] alu_selB;

wire idhaz, exhaz, memhaz;
assign idhaz = EX2_regwrite && EX2_rd_indzero && EX2_rd_ind == EX1_rs2_ind;
assign exhaz = MEM_regwrite && MEM_rd_indzero && MEM_rd_ind == EX1_rs2_ind;
assign memhaz = WB_regwrite && WB_rd_indzero && WB_rd_ind == EX1_rs2_ind;


assign alu_selB[0] =  (idhaz || (memhaz && ~exhaz)) && ~EX1_is_oper2_immed;
assign alu_selB[1] = (idhaz ||  exhaz) && ~EX1_is_oper2_immed;

endmodule
