module IF_ID_buffer(IF_PC, IF_INST, IF_FLUSH, if_id_Write, clk,
					ID_opcode,
					ID_rs1_ind, ID_rs2_ind, ID_rd_ind, ID_PC, ID_INST, rst);

	input [31:0] IF_PC, IF_INST;
	input IF_FLUSH, if_id_Write, clk, rst;
	
	// in this buffer we want to break down the instruction into valid little pieces that can be used in the next stages
	output reg [11:0] ID_opcode;
	output reg [4:0] ID_rs1_ind, ID_rs2_ind, ID_rd_ind;
	output reg [31:0] ID_PC, ID_INST;

	
	`include "opcodes.txt"

always @ (posedge clk) begin
	
	if (rst || (if_id_Write && IF_FLUSH))
		{ID_opcode, ID_rs1_ind, ID_rs2_ind, ID_rd_ind, ID_INST, ID_PC} <= 0;
	else if (if_id_Write) begin
		
			ID_INST   <= IF_INST;
			ID_PC    <= IF_PC;
			ID_rs2_ind <= IF_INST[20:16]; // rt_ind

			ID_opcode <= {IF_INST[31:26], {6{IF_INST[31:26] == 6'd0}} & IF_INST[5:0]};
			ID_rs1_ind <= (({IF_INST[31:26], IF_INST[5:0]} == sll || {IF_INST[31:26], IF_INST[5:0]} == srl)) ? IF_INST[20:16] : IF_INST[25:21];
			// if the inst is a R-format
			if (IF_INST[31:26] == 6'd0) begin				
				ID_rd_ind  <= IF_INST[15:11];  // rd_ind				
			end

			else if ({IF_INST[31:26], 6'd0} == jal) // else it is an I-format or J-format
					ID_rd_ind <= 31;  // rd_ind = $ra
			else
				ID_rd_ind <= IF_INST[20:16];  // rd_ind = rt_ind
		end		
	end	

endmodule