module IF_ID_buffer(IF_PC, IF_INST, IF_FLUSH, if_id_Write, clk,
					ID_opcode,
					ID_rs1_ind, ID_rs2_ind, ID_rd_ind, ID_PC, ID_INST, rst);

	input [31:0] IF_PC, IF_INST;
	input IF_FLUSH, if_id_Write, clk, rst;
	
	// in this buffer we want to break down the instruction into valid little pieces that can be used in the next stages
	output reg [6:0] ID_opcode;
	output reg [4:0] ID_rs1_ind, ID_rs2_ind, ID_rd_ind;
	output reg [31:0] ID_PC, ID_INST;
	
`include "opcodes.v"


always @ (negedge clk, posedge rst) begin
	if (rst) begin
		ID_opcode     <= 0;
		ID_rs1_ind   <= 0;
		ID_rs2_ind  <= 0;
		ID_rd_ind  <= 0;
		ID_INST   <= 0;
		ID_PC    <= 0;
	end
	else if (if_id_Write) begin
		
		// we flush only whenever there is an exception
		if (!IF_FLUSH) begin
			
			ID_INST   <= IF_INST;
			ID_PC    <= IF_PC;
			// if the inst is a R-format
			if (IF_INST[31:26] == 6'd0) begin
				
				ID_opcode <= {1'b0 , IF_INST[5:0]}; // the new opcode
				ID_rs2_ind <= IF_INST[20:16]; // rt_ind
				ID_rd_ind  <= IF_INST[15:11];  // rd_ind
				
				if ({1'b0 , IF_INST[5:0]} == sll || {1'b0 , IF_INST[5:0]} == srl)
					ID_rs1_ind <= IF_INST[20:16]; // rt_ind
				else
					ID_rs1_ind <= IF_INST[25:21]; // rs_ind
	
			end
				

				else begin// else it is an I-format or J-format
				
				ID_opcode <= {1'b1 , IF_INST[31:26]};
				ID_rs1_ind <= IF_INST[25:21]; // rs_ind
				ID_rs2_ind <= IF_INST[20:16]; // rt_ind
				if ({1'b1 , IF_INST[31:26]} == jal)
					ID_rd_ind <= 31;  // rd_ind = rt_ind
				else
					ID_rd_ind <= IF_INST[20:16];  // rd_ind = rt_ind
			end

			
		end
			
		else begin
		
			ID_opcode     <= 0;
			ID_rs1_ind   <= 0;
			ID_rs2_ind  <= 0;
			ID_rd_ind  <= 0;
			ID_INST   <= 0;
			ID_PC    <= 0;
			
		end
		
	end	

	
end

endmodule