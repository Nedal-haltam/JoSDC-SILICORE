
module ID_EX_buffer(ID_opcode, ID_rs1_ind, ID_rs2_ind, ID_rd_ind,
					ID_PC, ID_INST, ID_Immed, ID_rs1, ID_rs2, ID_regwrite,
					ID_memread, ID_memwrite, clk, ID_FLUSH,
					EX_opcode, EX_rs1_ind,
					EX_rs2_ind, EX_rd_ind, EX_PC,
					EX_INST, EX_Immed, EX_rs1,
					EX_rs2, EX_regwrite, EX_memread, EX_memwrite, rst);
					
parameter add = 7'h20, sub = 7'h22, addu = 7'h21, subu = 7'h23, addi = 7'h48, and_ = 7'h24, andi = 7'h4c, or_ = 7'h25, ori = 7'h4d, xor_ = 7'h26, 
		    xori = 7'h4e, nor_ = 7'h27, sll = 7'h00, srl = 7'h02, lw = 7'h63, sw = 7'h6b, beq = 7'h44, bne = 7'h45, blt = 7'h50, bge = 7'h51, 
			 j = 7'h42, jal = 7'h43, jr = 7'h08;

	
	input [6:0] ID_opcode;
	input [4:0] ID_rs1_ind, ID_rs2_ind, ID_rd_ind;
	input [31:0] ID_PC, ID_INST, ID_Immed, ID_rs1, ID_rs2;
	input ID_regwrite, ID_memread, ID_memwrite, clk;
	input ID_FLUSH, rst;
	
	output reg [6:0] EX_opcode;
	output reg [4:0] EX_rs1_ind, EX_rs2_ind, EX_rd_ind;
	output reg [31:0] EX_PC, EX_INST, EX_Immed, EX_rs1, EX_rs2;
	output reg EX_regwrite, EX_memread, EX_memwrite;
	
	always@(negedge clk, posedge rst) begin
		
	if (rst) begin
		{EX_opcode, EX_rs1_ind, EX_rs2_ind, EX_rd_ind, EX_PC, EX_INST, EX_Immed, EX_rs1, EX_rs2, EX_regwrite, EX_memread, EX_memwrite} <= 0;
	end
	else if (!ID_FLUSH) begin
		
		EX_opcode <= ID_opcode;
		EX_rs1_ind <= ID_rs1_ind;
		EX_rs2_ind <= ID_rs2_ind;
		EX_rd_ind <= ID_rd_ind;
		EX_PC <= ID_PC;
		EX_INST <= ID_INST;
		EX_Immed <= ID_Immed;
		EX_rs1 <= ID_rs1;
		EX_rs2 <= ID_rs2;
		EX_regwrite <= ID_regwrite;
		EX_memread <= ID_memread;
		EX_memwrite <= ID_memwrite;
		
			
		end 
		else
			{EX_opcode, EX_rs1_ind, EX_rs2_ind, EX_rd_ind, EX_PC, EX_INST, EX_Immed, EX_rs1, EX_rs2, EX_regwrite, EX_memread, EX_memwrite} <= 0;
		
	end
	
endmodule