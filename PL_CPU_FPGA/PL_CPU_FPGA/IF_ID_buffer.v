module IF_ID_buffer(IF_PC, IF_INST, IF_FLUSH, if_id_Write, clk,
					ID_opcode,
					ID_rs1_ind, ID_rs2_ind, ID_rd_ind, ID_PC, ID_INST, rst);

	input [31:0] IF_PC, IF_INST;
	input IF_FLUSH, if_id_Write, clk, rst;
	
	// in this buffer we want to break down the instruction into valid little pieces that can be used in the next stages
	output reg [6:0] ID_opcode;
	output reg [4:0] ID_rs1_ind, ID_rs2_ind, ID_rd_ind;
	output reg [31:0] ID_PC, ID_INST;
	
parameter add = 7'h20, sub = 7'h22, addu = 7'h21, subu = 7'h23, addi = 7'h48, and_ = 7'h24, andi = 7'h4c, or_ = 7'h25, ori = 7'h4d, xor_ = 7'h26, 
		    xori = 7'h4e, nor_ = 7'h27, sll = 7'h00, srl = 7'h02, lw = 7'h63, sw = 7'h6b, beq = 7'h44, bne = 7'h45, blt = 7'h50, bge = 7'h51, 
			 j = 7'h42, jal = 7'h43, jr = 7'h08, slt = 7'h2a, hlt_inst = 7'b1111111;

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