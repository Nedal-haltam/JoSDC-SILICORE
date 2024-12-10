
module BranchResolver(PC_src, ID_opcode, EX1_opcode, EX2_opcode, predicted, predicted_to_EX, Wrong_prediction, rst, clk);
	
	input [11:0] ID_opcode, EX1_opcode, EX2_opcode;
	input rst, Wrong_prediction, clk;
	
	output [2:0] PC_src;
	output predicted, predicted_to_EX;

	
`include "opcodes.txt"

// just to refer to the mux
// MUX_8x1 PC_src_mux(

// 0- inst_mem_in + 1'b1
// 1- ID_PFC
// 2- inst_mem_in
// 3- EX1_PFC
// 4- EX2_PFC
// MUX_8x1 PC_src_mux(inst_mem_in + 1'b1, ID_PFC, inst_mem_in, EX1_PFC, EX2_PFC, 0, 0, 0, PC_src, pc_reg_in);

wire [1:0] state;
BranchPredictor BPU(ID_opcode, EX2_opcode, predicted, predicted_to_EX, Wrong_prediction, rst, state, clk);

assign PC_src =	(Wrong_prediction) ? 3'b100 : 
(
	(ID_opcode == hlt_inst) ? 3'b010 : 
		(
			(EX1_opcode == jr) ? 3'b011 : 
			(
				(predicted || ID_opcode == j || ID_opcode == jal) ? 3'b001 : 0
			)
		)
);

endmodule