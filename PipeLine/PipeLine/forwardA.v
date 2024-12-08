module forwardA
(
	EX1_rs1_ind, 
	
	EX2_rd_indzero, EX2_rd_ind, EX2_regwrite, 
	MEM_rd_indzero, MEM_rd_ind, MEM_regwrite, 
	WB_rd_indzero, WB_rd_ind, WB_regwrite,
	
	alu_selA
);

`include "opcodes.txt"

input [4:0] EX1_rs1_ind, EX2_rd_ind, MEM_rd_ind, WB_rd_ind;

input EX2_rd_indzero, MEM_rd_indzero, WB_rd_indzero;
input EX2_regwrite, MEM_regwrite, WB_regwrite;

output [1:0] alu_selA;

wire idhaz, exhaz, memhaz;
assign idhaz = EX2_regwrite && EX2_rd_indzero && EX2_rd_ind == EX1_rs1_ind;
assign exhaz = MEM_regwrite && MEM_rd_indzero && MEM_rd_ind == EX1_rs1_ind;
assign memhaz = WB_regwrite && WB_rd_indzero && WB_rd_ind == EX1_rs1_ind;


assign alu_selA[0] = idhaz || (memhaz && ~exhaz);
assign alu_selA[1] = idhaz || exhaz;

endmodule
