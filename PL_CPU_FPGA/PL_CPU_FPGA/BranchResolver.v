
module BranchResolver(PC_src, exception_flag, opcode, Wrong_prediction, rst);
	
	input [6:0] opcode;
	input exception_flag, rst, Wrong_prediction;
	
	output [2:0] PC_src;

	
`include "opcodes.v"


assign PC_src = (exception_flag) ? 3'b001 : 
(
	(Wrong_prediction) ? 3'b100 : 
		(
			(opcode == hlt_inst) ? 3'b011 : 
				(
					((opcode == beq) || (opcode == bne) || opcode == j || opcode == jal || opcode == jr) ? 3'b010 : 0
				)

		)
	
);

endmodule
