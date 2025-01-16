module BranchPredictor
(
    input rst, clk, Wrong_prediction,
    input [11:0] Decoded_opcode, Commit_opcode,
    output reg [1:0] state,  // 2-bit state (00 NT | 01 NT | 10 T | 11 T)
    output predicted  // prediction (1 = taken, 0 = not taken)
);

	`include "opcodes.txt"

	always @ (posedge rst , posedge clk) begin
		// active high reset to 00
		if (rst) begin
			state <= 2'b0;
		end
		else if (Commit_opcode == beq || Commit_opcode == bne) begin
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


	assign predicted = ~(rst || ~((Decoded_opcode == beq || Decoded_opcode == bne) && (state == 2'b10 || state == 2'b11)));

endmodule
