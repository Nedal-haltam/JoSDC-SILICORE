
module control_unit(opcode, regwrite, memread, memwrite);

   input [6:0] 	opcode;
	
	output reg			regwrite; 																
	output reg			memread; 								
	output reg			memwrite;
	
	
`include "opcodes.v"

	
	
always @(opcode) begin
		{regwrite, memread, memwrite} <= 0; //By Default all Control Signals are equal to zero
		// if none of these instructions then the the regwrite = 1
		if (!(opcode == jr || opcode == sw || opcode == beq || opcode == bne || opcode == blt || opcode == bge || opcode == j))
			regwrite <= 1'b1;
		if (opcode == lw)
			memread <= 1'b1;
		if (opcode == sw)
			memwrite <= 1'b1;
			
end	
endmodule