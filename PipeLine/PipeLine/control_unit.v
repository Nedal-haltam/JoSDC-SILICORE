
module control_unit(ID_opcode, regwrite, memread, memwrite, is_oper2_immed, is_beq, is_bne, is_jr, is_jal, is_j);

input [11:0] ID_opcode;
	
output regwrite;
output memread;
output memwrite;
output is_oper2_immed;
output is_beq, is_bne, is_jr, is_jal, is_j;

`include "opcodes.txt"


assign is_oper2_immed = (ID_opcode == addi || ID_opcode == andi || ID_opcode == ori || 
	ID_opcode == xori || ID_opcode == lw   || ID_opcode == sw  || 
	ID_opcode == sll  || ID_opcode == srl  || ID_opcode == slti  );

assign is_beq = ID_opcode == beq;
assign is_bne = ID_opcode == bne;
assign is_jr = ID_opcode == jr;
assign is_jal = ID_opcode == jal;
assign is_j = ID_opcode == j;

assign regwrite = (!(ID_opcode == jr || ID_opcode == sw || ID_opcode == beq || ID_opcode == bne || ID_opcode == j));
assign memread = ID_opcode == lw;
assign memwrite = ID_opcode == sw;

endmodule