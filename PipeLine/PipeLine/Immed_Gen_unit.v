
module Immed_Gen_unit(Inst, opcode, Immed);
	
	input [31:0] Inst;
	input [11:0] opcode;
	
	output reg [31:0] Immed;
	
`include "opcodes.txt"
	
	always@(*) begin
		
		// there are three types of immediates in our instruction format
		// the shamt : Inst[10:6] , 5  bits , in the R-format
		// the immed : Inst[15:0] , 16 bits , in the I-fromat
		// so depending on the instruction we will extexd these numbers
		
		// by default the output immed is zero
		{ Immed } = 0;
		
		if (opcode == sll || opcode == srl) // zero extend
			Immed <= {32'd0 , Inst[10:6]};
		else if (opcode == andi || opcode == ori || opcode == xori) // zero extend
			Immed <= {32'd0 , Inst[15:0]};
	
		else if (opcode == addi || opcode == lw || opcode == sw || opcode == beq || opcode == bne || opcode == slti)
			Immed <= {{32{Inst[15]}} , Inst[15:0]};
		
		
	end
	
endmodule