
module forwardC(id_ex_opcode, id_ex_rs1, id_ex_rs2, 
					ex_mem_rdzero, ex_mem_rd, ex_mem_wr , mem_wb_rdzero, mem_wb_rd, mem_wb_wr, 
					store_rs2_forward
					);
parameter bit_width = 32;

`include "opcodes.txt"

// these might containg the funct for the I-format but we will stick the opcode just for naming simplicity
input [6:0] id_ex_opcode;

// forward to 2 places (aka stages)
input [4:0] id_ex_rs1, id_ex_rs2;				

// forward from 3 places (aka stages)
input [4:0] ex_mem_rd, mem_wb_rd; 

input ex_mem_wr, mem_wb_wr, ex_mem_rdzero, mem_wb_rdzero;

output [1:0] store_rs2_forward; // the selection lines for the register that is going to be stored in the data memory
	
	

assign store_rs2_forward = (ex_mem_wr && ex_mem_rdzero && ex_mem_rd == id_ex_rs2) ? 2'b01 : 
(
	(mem_wb_wr && mem_wb_rdzero && mem_wb_rd == id_ex_rs2) ? 2'b10 : 2'b00
);

endmodule
