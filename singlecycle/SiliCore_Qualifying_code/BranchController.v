module BranchController(
	input [5:0] opcode,
	input [31:0] operand1, operand2,
	input rst,
	output reg PCsrc
);

`include "opcodes.v"

always@(*) begin
if (~rst)
	PCsrc <= 0;
else if (opcode == _beq && operand1 == operand2)
	PCsrc <= 1'b1;
else
	PCsrc <= 0;
end
// assign PCsrc = (~rst) ? 0 : ((opcode == _beq && operand1 == operand2) ? 1'b1 : 1'b0);

endmodule
 