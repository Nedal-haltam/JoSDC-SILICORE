
module control_unit(opcode, regwrite, memread, memwrite, is_oper2_immed, is_beq, is_bne, is_blt, is_ble, is_bgt, is_bge);

   input [6:0] 	opcode;
	
	output regwrite; 																
	output memread; 								
	output memwrite;
	output is_oper2_immed;
	output is_beq, is_bne, is_blt, is_ble, is_bgt, is_bge;

`include "opcodes.txt"
	

assign is_oper2_immed = (opcode == addi || opcode == andi || opcode == ori || 
	opcode == xori || opcode == lw   || opcode == sw  || 
	opcode == sll  || opcode == srl  || opcode == slti  );

assign is_beq = opcode == beq;
assign is_bne = opcode == bne;
assign is_blt = opcode == blt;
assign is_ble = opcode == ble;
assign is_bgt = opcode == bgt;
assign is_bge = opcode == bge;

assign regwrite = (!(opcode == jr || opcode == sw || opcode == beq || opcode == bne || opcode == blt || opcode == ble || opcode == bgt || opcode == bge || opcode == j));
assign memread = opcode == lw;
assign memwrite = opcode == sw;

endmodule