

module exception_detect_unit(ID_PC, ID_opcode, excep_flag, id_flush, EX_FLUSH, MEM_FLUSH, clk, rst);
	
input clk, rst;
input [31:0] ID_PC;
input [11:0] ID_opcode;

output excep_flag, id_flush, EX_FLUSH, MEM_FLUSH;

`include "opcodes.txt"


assign excep_flag = (rst) ? 0 : 
					 ((ID_opcode == add || ID_opcode == sub || ID_opcode == addu || 
					 ID_opcode == subu || ID_opcode == addi || ID_opcode == and_ || ID_opcode == andi || 
					 ID_opcode == or_ || ID_opcode == ori || ID_opcode == xor_ || 
					 ID_opcode == xori || ID_opcode == nor_ || ID_opcode == sll || ID_opcode == srl || 
					 ID_opcode == lw || ID_opcode == sw || 
					 ID_opcode == beq || ID_opcode == bne ||
					 ID_opcode == j || ID_opcode == jal || 
					 ID_opcode == jr || ID_opcode == slt || ID_opcode == sgt || ID_opcode == slti || ID_opcode == hlt_inst
					 /*TODO: check for invalid PC from fetch stage (IF_PC) and check ID_address ...*/) ? 0 : 1'b1);


assign id_flush = excep_flag;
assign EX_FLUSH = 0;
assign MEM_FLUSH = 0;
endmodule