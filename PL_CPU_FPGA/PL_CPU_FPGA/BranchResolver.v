
module BranchResolver(PC_src, exception_flag, opcode, predicted, Wrong_prediction, rst);
	
	input [6:0] opcode;
	input exception_flag, rst, Wrong_prediction;
	
	output [2:0] PC_src;
	output predicted;

	
`include "opcodes.v"

assign predicted = (opcode == beq || opcode == bne || opcode == jr) ? 1'b1 : 0;

assign PC_src = (exception_flag) ? 3'b001 : 
(
	(Wrong_prediction) ? 3'b100 : 
		(
			(opcode == hlt_inst) ? 3'b011 : 
				(
					(opcode == beq || opcode == bne || opcode == j || opcode == jal) ? 3'b010 : 0
				)

		)
);

endmodule
