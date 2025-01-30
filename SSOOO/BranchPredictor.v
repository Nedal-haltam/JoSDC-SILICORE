

`define N 3
`define MAX_VALUE (1 << `N)

module BranchPredictor
(
    input rst, clk, Wrong_prediction,
    input [11:0] Decoded_opcode, Commit_opcode,
    output reg [`N - 1:0] state,  // 2-bit state (00 NT | 01 NT | 10 T | 11 T)
    output predicted  // prediction (1 = taken, 0 = not taken)
);

	`include "opcodes.txt"

	always @ (posedge rst , posedge clk) begin
		// active high reset to 00
		if (rst) begin
			state <= {`N{1'b0}};
			// state <= {`N{1'b1}};
		end
		else if (Commit_opcode == beq || Commit_opcode == bne) begin
			if (Wrong_prediction) begin
				if (state >= (`MAX_VALUE >> 1)) begin
					state <= state - 1'b1;
				end
				else if (state < (`MAX_VALUE >> 1)) begin
					state <= state + 1'b1;
				end
			end
			else begin
				if (~(state == 0 || state == (`MAX_VALUE - 1))) begin
					if (state >= (`MAX_VALUE >> 1)) begin
						state <= state + 1'b1;
					end
					else if (state < (`MAX_VALUE >> 1)) begin
						state <= state - 1'b1;
					end
				end
			end
		end
	end


	assign predicted = ~(rst || 
	~(
		(Decoded_opcode == beq || Decoded_opcode == bne) &&
		(
			state >= (1 << (`N - 1))
		)
	));

endmodule
