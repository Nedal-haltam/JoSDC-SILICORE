
module forwardC(EX_opcode, EX_rs1, EX_rs2, 
				MEM_rd_ind_zero, MEM_rd, MEM_Write_en, 
				WB_rd_ind_zero, WB_rd, WB_Write_en, 
				store_rs2_forward, clk
);

`include "opcodes.txt"

input [11:0] EX_opcode;
input [4:0] EX_rs1, EX_rs2;				
input [4:0] MEM_rd, WB_rd; 
input MEM_Write_en, WB_Write_en, MEM_rd_ind_zero, WB_rd_ind_zero, clk;

output [1:0] store_rs2_forward; // the selection lines for the register that is going to be stored in the data memory
	
assign store_rs2_forward[0] = MEM_Write_en && MEM_rd_ind_zero && MEM_rd == EX_rs2;
assign store_rs2_forward[1] = WB_Write_en && WB_rd_ind_zero && WB_rd == EX_rs2;

endmodule
