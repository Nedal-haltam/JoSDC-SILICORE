
module control_unit(opcode, regwrite, memread, memwrite, is_oper2_immed, is_beq, is_bne);

   input [6:0] 	opcode;
	
	output regwrite; 																
	output memread; 								
	output memwrite;
	output is_oper2_immed;
	output is_beq, is_bne;

`include "opcodes.v"

	
	

assign is_oper2_immed = (opcode == addi || opcode == andi || opcode == ori || 
	opcode == xori || opcode == lw   || opcode == sw  || 
	opcode == sll  || opcode == srl  || opcode == slti  );

assign is_beq = opcode == beq;
assign is_bne = opcode == bne;

assign regwrite = (!(opcode == jr || opcode == sw || opcode == beq || opcode == bne || opcode == j));
assign memread = opcode == lw;
assign memwrite = opcode == sw;
// always @(opcode) begin
// 		{regwrite, memread, memwrite} <= 0; //By Default all Control Signals are equal to zero
// 		// if none of these instructions then the the regwrite = 1
// 		if (!(opcode == jr || opcode == sw || opcode == beq || opcode == bne || opcode == j))
// 			regwrite <= 1'b1;
// 		if (opcode == lw)
// 			memread <= 1'b1;
// 		if (opcode == sw)
// 			memwrite <= 1'b1;
			
// end	
endmodule