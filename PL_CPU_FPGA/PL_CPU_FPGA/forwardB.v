
module forwardB(id_ex_opcode, id_ex_rs1, id_ex_rs2, 
					ex_mem_rdzero, ex_mem_rd, ex_mem_wr , mem_wb_rdzero, mem_wb_rd, mem_wb_wr, 
					forwardB, is_oper2_immed
					);
parameter bit_width = 32;

`include "opcodes.v"

// these might containg the funct for the I-format but we will stick the opcode just for naming simplicity
input [6:0] id_ex_opcode;

// forward to 2 places (aka stages)
input [4:0] id_ex_rs1, id_ex_rs2;				

// forward from 3 places (aka stages)
input [4:0] ex_mem_rd, mem_wb_rd; 

input ex_mem_wr, mem_wb_wr, is_oper2_immed, ex_mem_rdzero, mem_wb_rdzero;

output [2:0] forwardB; // the selection lines for the ALU oprands mux


assign forwardB = 
(id_ex_opcode == jal)  ? 3'b001 :
	(
		(is_oper2_immed) ? 3'b000 :
			(
				(ex_mem_wr && ex_mem_rdzero && ex_mem_rd == id_ex_rs2) ? 3'b010 :
					(
						(mem_wb_wr && mem_wb_rdzero && mem_wb_rd == id_ex_rs2) ? 3'b011 : 3'b100
					)
			)
	);

endmodule
