

module exception_detect_unit(ID_PC, ID_opcode, excep_flag, id_flush, EX_FLUSH, MEM_FLUSH, clk, rst);
	
input clk, rst;
input [31:0] ID_PC;
input [6:0] ID_opcode;

output excep_flag, id_flush, EX_FLUSH, MEM_FLUSH;

parameter numofinst = 24;
parameter [0 : 7 * numofinst - 1] opcodes  = {7'h20, 7'h22, 7'h21, 7'h23, 7'h48, 7'h24, 7'h4c, 7'h25, 7'h4d, 7'h26, 
		    7'h4e, 7'h27, 7'h00, 7'h02, 7'h63, 7'h6b, 7'h44, 7'h45, 7'h50, 7'h51, 
			7'h42, 7'h43, 7'h08, 7'h2a };

`include "opcodes.v"



assign excep_flag = (rst) ? 0 : 
					 ((ID_opcode == add || ID_opcode == sub || ID_opcode == addu || 
					 ID_opcode == subu || ID_opcode == addi || ID_opcode == and_ || ID_opcode == andi || 
					 ID_opcode == or_ || ID_opcode == ori || ID_opcode == xor_ || 
					 ID_opcode == xori || ID_opcode == nor_ || ID_opcode == sll || ID_opcode == srl || 
					 ID_opcode == lw || ID_opcode == sw || ID_opcode == beq || ID_opcode == bne || 
					 /*ID_opcode == blt || ID_opcode == bge ||*/ID_opcode == j || ID_opcode == jal || 
					 ID_opcode == jr || ID_opcode == slt || ID_opcode == sgt || ID_opcode == slti || ID_opcode == hlt_inst) ? 0 : 1'b1);


assign id_flush = excep_flag;
assign EX_FLUSH = excep_flag;
assign MEM_FLUSH = excep_flag;
endmodule