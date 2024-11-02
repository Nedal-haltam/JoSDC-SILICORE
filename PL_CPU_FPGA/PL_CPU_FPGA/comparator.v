
module comparator(A, B, PC_src, exception_flag, opcode, rst);
	
	input [31:0] A, B;
	input [6:0] opcode;
	input exception_flag, rst;
	
	output [1:0] PC_src;

	
`include "opcodes.v"


assign PC_src = (exception_flag) ? 2'b01 : 
(
	(opcode == hlt_inst) ? 2'b11 : 
(
((opcode == beq && A == B) || (opcode == bne && A != B) || 
(opcode == blt && $signed(A) < $signed(B)) || 
(opcode == bge && $signed(A) >= $signed(B)) || 
opcode == j || opcode == jal || opcode == jr) ? 2'b10 : 0
)
);

endmodule
