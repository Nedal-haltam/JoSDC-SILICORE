
module Immed_Gen_unit(Inst, opcode, Immed);
	
	input [31:0] Inst;
	input [6:0] opcode;
	
	output reg [31:0] Immed;
	
	
	
parameter add = 7'h20, sub = 7'h22, addu = 7'h21, subu = 7'h23, addi = 7'h48, and_ = 7'h24, andi = 7'h4c, or_ = 7'h25, ori = 7'h4d, xor_ = 7'h26, 
		    xori = 7'h4e, nor_ = 7'h27, sll = 7'h00, srl = 7'h02, lw = 7'h63, sw = 7'h6b, beq = 7'h44, bne = 7'h45, blt = 7'h50, bge = 7'h51, 
			 j = 7'h42, jal = 7'h43, jr = 7'h08;

	
	
	
	always@(*) begin
		
		// there are three types of immediates in our instruction format
		// the shamt : Inst[10:6] , 5  bits , in the R-format
		// the immed : Inst[15:0] , 16 bits , in the I-fromat
		// the immed (aka the target address) : Inst[25:0] , 26 bits , in the J-format
		// so depending on the instruction we will extexd these numbers
		
		// by default the output immed is zero
		{ Immed } = 0;
		
		if (opcode == sll || opcode == srl) // zero extend
			Immed <= {32'd0 , Inst[10:6]};
		
		else if (opcode[6] == 1'b1) begin // if it is an I-fromat or J-format
		
			if (opcode == andi || opcode == ori || opcode == xori) // zero extend
				Immed <= {32'd0 , Inst[15:0]};
		
	   		else if (opcode == j || opcode == jal) // zero extend
				Immed <= {32'd0 , Inst[25:0]};
			
			else if (opcode == addi || opcode == lw || opcode == sw || opcode == beq || opcode == bne || opcode == blt || opcode == bge)
				Immed <= {{32{Inst[15]}} , Inst[15:0]};
				
				
				
		end
		
		
	end
	
endmodule