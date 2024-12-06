
module control_unit(opcode, regwrite, memread, memwrite, is_oper2_immed, is_beq, is_bne, is_jr, is_jal, is_j);

   input [11:0] 	opcode;
	
	output regwrite; 																
	output memread; 								
	output memwrite;
	output is_oper2_immed;
	output is_beq, is_bne, is_jr, is_jal, is_j;

`include "opcodes.txt"
	

assign is_oper2_immed = (opcode == addi || opcode == andi || opcode == ori || 
	opcode == xori || opcode == lw   || opcode == sw  || 
	opcode == sll  || opcode == srl  || opcode == slti  );

assign is_beq = opcode == beq;
assign is_bne = opcode == bne;
assign is_jr = opcode == jr;
assign is_jal = opcode == jal;
assign is_j = opcode == j;
assign regwrite = (!(opcode == jr || opcode == sw || opcode == beq || opcode == bne || opcode == j));
assign memread = opcode == lw;
assign memwrite = opcode == sw;

endmodule