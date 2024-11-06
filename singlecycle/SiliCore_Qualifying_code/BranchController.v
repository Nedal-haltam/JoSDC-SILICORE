module BranchController(
	input [5:0] opcode, funct,
	input [31:0] operand1, operand2,
	input rst,
	output reg PCsrc
);

`include "opcodes.v"

always@(*) begin
if (~rst)
	PCsrc <= 0;
else if (opcode == beq && operand1 == operand2 || opcode == bne && operand1 != operand2 ||
		 opcode == j || opcode == jal || (opcode == 0 && funct == jr))
	PCsrc <= 1'b1;
else
	PCsrc <= 0;
end

endmodule
 