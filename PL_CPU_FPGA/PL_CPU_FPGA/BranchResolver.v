
module BranchResolver(PC_src, exception_flag, opcode, predicted, Wrong_prediction, rst, clk);
	
	input [11:0] opcode;
	input exception_flag, rst, Wrong_prediction, clk;
	
	output [2:0] PC_src;
	output predicted;

	
`include "opcodes.txt"

// TODO: make the JR check if there is dependency
//		 	if there is : then we introduce a bubble and not forward it to the decode stage (because forwarding make the performace (clk) worse)
//			if there is no dependency : then we immediately jump without introducing bubbles


// assign predicted = (opcode == beq || opcode == bne || opcode == jr) ? 1'b1 : 0;
output [1:0] state;
BranchPredictor BPU(opcode, predicted, Wrong_prediction, rst, state, clk);

assign PC_src = (exception_flag) ? 3'b001 : 
(
	(Wrong_prediction) ? 3'b100 : 
		(
			(opcode == hlt_inst) ? 3'b011 : 
				(
					(predicted || opcode == j || opcode == jal) ? 3'b010 : 0
				)
		)
);

endmodule


