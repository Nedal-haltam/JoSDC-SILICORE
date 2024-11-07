
module Immed_Gen_unit(Inst, opcode, Immed);
	
	input [31:0] Inst;
	input [6:0] opcode;
	
	output reg [31:0] Immed;
	
	
	
`include "opcodes.v"

	
	
	
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
			
			else if (opcode == addi || opcode == lw || opcode == sw || opcode == beq || opcode == bne /*|| opcode == blt || opcode == bge*/)
				Immed <= {{32{Inst[15]}} , Inst[15:0]};
				
				
				
		end
		
		
	end
	
endmodule