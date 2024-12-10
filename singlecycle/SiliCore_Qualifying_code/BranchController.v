module BranchController(
	input [5:0] opcode, funct,
	input [31:0] operand1, operand2,
	input rst,
	output reg PCsrc
);

`include "opcodes.txt"

always@(*) begin
if (~rst)
	PCsrc <= 0;
else begin
PCsrc <= (opcode == beq && operand1 == operand2 || 
         opcode == bne && operand1 != operand2 ||
		 opcode == j || opcode == jal || (opcode == 0 && funct == jr));
end
end
endmodule
 