`include "opcodes.txt"
module BranchResolver_2Bit_Predictor(PC_src, exception_flag, opcode, predicted, Wrong_prediction, rst);
	
	input [6:0] opcode;
	input exception_flag, rst, Wrong_prediction;
	
	output [2:0] PC_src; // PC mux input
	output predicted; // prediction (1 = taken, 0 = not taken)

	wire [1:0] state; // 2-bit state (00 NT | 01 NT | 10 T | 11 T)

	always @ (opcode or rst or Wrong_prediction) begin
		// active high reset to 00
		if (rst) 
			state <= 2'b0;
		else if (opcode == beq || opcode == bne || opcode == blt || opcode == ble || opcode == bgt || opcode == bge || opcode == jr) begin
			case ({state, Wrong_prediction}) 
				{2'b00, 1'b0}: begin
					predicted <= 1'b0;
				end
				{2'b00, 1'b1}: begin
					predicted <= 1'b0;
					state <= 2'b01;
				end
				{2'b01, 1'b0}: begin
					predicted <= 1'b0;
					state <= 2'b00;
				end
				{2'b01, 1'b1}: begin
					predicted <= 1'b0;
					state <= 2'b10;
				end 
				{2'b10, 1'b0}: begin
					predicted <= 1'b1;
					state <= 2'b11;
				end
				{2'b10, 1'b1}: begin
					predicted <= 1'b1;
					state <= 2'b01;
				end
				{2'b11, 1'b0}: begin
					predicted <= 1'b1;
				end
				{2'b11, 1'b1}: begin
					predicted <= 1'b1;
					state <= 2'b10;
				end
			endcase
		end
		else 
			predicted = 1'b0;
	end

	assign PC_src = (exception_flag) ? 3'b001 : 
	(
		(Wrong_prediction) ? 3'b100 : 
			(
				(opcode == hlt_inst) ? 3'b011 : 
					(
						(opcode == beq || opcode == bne || opcode == blt || opcode == ble || opcode == bgt || opcode == bge || opcode == j || opcode == jal) ? 3'b010 : 0
					)

			)
	);

endmodule
