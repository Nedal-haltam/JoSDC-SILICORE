

module BranchPredictor
(
    input rst, clk, Wrong_prediction,
	input [31:0] PC,
    input [11:0] Decoded_opcode, Commit_opcode,
    output predicted
);

N_BIT_BranchPredictor #(.N(3)) N_BIT_BPU
(
    .rst(rst), 
    .clk(clk), 
    .Wrong_prediction(Wrong_prediction), 
    .Decoded_opcode(Decoded_opcode),
    .Commit_opcode(Commit_opcode),
    .predicted(predicted)
);

endmodule

module N_BIT_BranchPredictor#
(
parameter N = 3
)
(
    input rst, clk, Wrong_prediction,
	input [31:0] PC,
    input [11:0] Decoded_opcode, Commit_opcode,
    output predicted
);

	`include "opcodes.txt"


	parameter [N:0] MAX_VALUE = (1 << N);

    reg [N - 1:0] state;

	always @ (posedge rst , posedge clk) begin
		// active high reset to 00
		if (rst) begin
			state <= 0; // minimum
			// state <= MAX_VALUE - 1'b1; // maximum
			// state <= (MAX_VALUE >> 1) - 1; // middle value
		end
		else if (Commit_opcode == beq || Commit_opcode == bne) begin
			if (Wrong_prediction) begin
				if (state >= (MAX_VALUE >> 1)) begin
					state <= state - 1'b1;
				end
				else if (state < (MAX_VALUE >> 1)) begin
					state <= state + 1'b1;
				end
			end
			else begin
				if (~(state == 0 || state == (MAX_VALUE - 1))) begin
					if (state >= (MAX_VALUE >> 1)) begin
						state <= state + 1'b1;
					end
					else if (state < (MAX_VALUE >> 1)) begin
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
			state >= (1 << (N - 1))
		)
	));

endmodule


