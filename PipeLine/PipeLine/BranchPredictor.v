module BranchPredictor(ID_opcode, EX_opcode, predicted, predicted_to_EX, Wrong_prediction, rst, state, clk);
	input [11:0] ID_opcode, EX_opcode;
	input rst, Wrong_prediction, clk;
	
	output predicted; // prediction (1 = taken, 0 = not taken)
	output reg predicted_to_EX;
	output reg [1:0] state; // 2-bit state (00 NT | 01 NT | 10 T | 11 T)

	`include "opcodes.txt"


	always @ (posedge rst , posedge clk) begin
		// active high reset to 00
		if (rst) begin
			state <= 2'b0;
		end
		else if (EX_opcode == beq || EX_opcode == bne) begin
			case ({state, Wrong_prediction}) 
				{2'b00, 1'b0}: begin
				end
				{2'b00, 1'b1}: begin
					state <= 2'b01;
				end
				{2'b01, 1'b0}: begin
					state <= 2'b00;
				end
				{2'b01, 1'b1}: begin
					state <= 2'b10;
				end 
				{2'b10, 1'b0}: begin
					state <= 2'b11;
				end
				{2'b10, 1'b1}: begin
					state <= 2'b01;
				end
				{2'b11, 1'b0}: begin
				end
				{2'b11, 1'b1}: begin
					state <= 2'b10;
				end
			endcase
		end
	end


	assign predicted = ~(rst || ~((ID_opcode == beq || ID_opcode == bne) && (state == 2'b10 || state == 2'b11)));

	always@(posedge rst, posedge clk)
		if (rst)
			predicted_to_EX <= 0;
		else
			predicted_to_EX <= predicted;


	// always @ (rst , posedge clk) begin
	// 	// active high reset to 00
	// 	if (rst) begin
	// 		state <= 2'b0;
	// 		predicted <= 1'b0;
	// 	end
	// 	else if (opcode == beq || opcode == bne) begin
	// 		case ({state, Wrong_prediction}) 
	// 			{2'b00, 1'b0}: begin
	// 				predicted <= 1'b0;
	// 			end
	// 			{2'b00, 1'b1}: begin
	// 				predicted <= 1'b0;
	// 				state <= 2'b01;
	// 			end
	// 			{2'b01, 1'b0}: begin
	// 				predicted <= 1'b0;
	// 				state <= 2'b00;
	// 			end
	// 			{2'b01, 1'b1}: begin
	// 				predicted <= 1'b0;
	// 				state <= 2'b10;
	// 			end 
	// 			{2'b10, 1'b0}: begin
	// 				predicted <= 1'b1;
	// 				state <= 2'b11;
	// 			end
	// 			{2'b10, 1'b1}: begin
	// 				predicted <= 1'b1;
	// 				state <= 2'b01;
	// 			end
	// 			{2'b11, 1'b0}: begin
	// 				predicted <= 1'b1;
	// 			end
	// 			{2'b11, 1'b1}: begin
	// 				predicted <= 1'b1;
	// 				state <= 2'b10;
	// 			end
	// 		endcase
	// 	end
	// 	else 
	// 		predicted = 1'b0;
	// end
endmodule
