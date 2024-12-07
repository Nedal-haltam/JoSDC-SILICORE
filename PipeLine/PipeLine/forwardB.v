
module forwardB(EX_opcode, EX_rs1, EX_rs2, 
				MEM_rd_ind_zero, MEM_rd, MEM_Write_en, 
				WB_rd_ind_zero, WB_rd, WB_Write_en, 
				forwardB, is_oper2_immed, 
				clk, is_jal
);

`include "opcodes.txt"

input [11:0] EX_opcode;
input [4:0] EX_rs1, EX_rs2;				
input [4:0] MEM_rd, WB_rd; 
input MEM_Write_en, WB_Write_en, is_oper2_immed, MEM_rd_ind_zero, WB_rd_ind_zero, clk, is_jal;

output [1:0] forwardB; // the selection lines for the ALU oprands mux

wire exhaz, memhaz;
assign exhaz = MEM_Write_en && MEM_rd_ind_zero && MEM_rd == EX_rs2;
assign memhaz = WB_Write_en && WB_rd_ind_zero && WB_rd == EX_rs2;


assign forwardB[0] = is_jal || (memhaz && ~exhaz);
assign forwardB[1] = (is_jal ||  exhaz) && ~is_oper2_immed;

endmodule
