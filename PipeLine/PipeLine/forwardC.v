module forwardC
(
	EX1_rs2_ind, 

	EX2_rd_indzero, EX2_rd_ind, EX2_regwrite, 
	MEM_rd_indzero, MEM_rd_ind, MEM_regwrite, 
	WB_rd_indzero, WB_rd_ind, WB_regwrite,
	
	store_rs2_forward
);

`include "opcodes.txt"


input [4:0] EX1_rs2_ind, EX2_rd_ind, MEM_rd_ind, WB_rd_ind;

input EX2_rd_indzero, EX2_regwrite, MEM_rd_indzero, MEM_regwrite, WB_rd_indzero, WB_regwrite;

output [1:0] store_rs2_forward;

wire idhaz, exhaz, memhaz;
assign idhaz = EX2_regwrite && EX2_rd_indzero && EX2_rd_ind == EX1_rs2_ind;
assign exhaz = MEM_regwrite && MEM_rd_indzero && MEM_rd_ind == EX1_rs2_ind;
assign memhaz = WB_regwrite && WB_rd_indzero && WB_rd_ind == EX1_rs2_ind;

assign store_rs2_forward[0] = idhaz || (memhaz && ~exhaz);
assign store_rs2_forward[1] = idhaz || exhaz;

endmodule
