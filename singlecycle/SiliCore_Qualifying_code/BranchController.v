module BranchController(
	input [5:0] opcode, funct,
	input [31:0] operand1, operand2,
	input rst,
	input excep_flag,
	output reg [1:0] PCsrc
);

`include "opcodes.txt"

always@(*) begin
if (~rst)
	PCsrc <= 0;
else if (excep_flag)
	PCsrc <= 2'b10;
else if (opcode == beq && operand1 == operand2 || 
         opcode == bne && operand1 != operand2 ||
         opcode == blt && $signed(operand1) < $signed(operand2) ||
         opcode == ble && $signed(operand1) <= $signed(operand2) ||
         opcode == bgt && $signed(operand1) > $signed(operand2) ||
         opcode == bge && $signed(operand1) >= $signed(operand2) ||
		 opcode == j || opcode == jal || (opcode == 0 && funct == jr))
	PCsrc <= 2'b01;
else
	PCsrc <= 0;
end

endmodule
 