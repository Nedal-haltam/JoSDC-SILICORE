
  // ALUOP -> OP 
  // 0000   -> add
  // 0001   -> sub
  // 0010   -> and
  // 0011   -> or
  // 0100   -> xor
  // 0101   -> nor
  // 0110   -> shift left here we shift A, B times
  // 0111   -> shift right 
  // 1000   -> if (A < B) then 1 else 0 (aka. slt)
  // this module takes the opcode and based on it. it decides what operation the ALU should do.

module ALU_OPER(opcode, ALU_OP);
	
	input [6:0] opcode;
	
	output reg [3:0] ALU_OP;
	
parameter add = 7'h20, sub = 7'h22, addu = 7'h21, subu = 7'h23, addi = 7'h48, and_ = 7'h24, andi = 7'h4c, or_ = 7'h25, ori = 7'h4d, xor_ = 7'h26, 
		    xori = 7'h4e, nor_ = 7'h27, sll = 7'h00, srl = 7'h02, lw = 7'h63, sw = 7'h6b, beq = 7'h44, bne = 7'h45, blt = 7'h50, bge = 7'h51, 
			 j = 7'h42, jal = 7'h43, jr = 7'h08, slt = 7'h2a;

	always@(*) begin

		case (opcode) 
			add, addu, addi, lw, sw, beq, bne, blt, bge, jal, jr, j: ALU_OP <= 4'b0000;
			sub, subu: ALU_OP <= 4'b0001;
			and_, andi:ALU_OP <= 4'b0010;
			or_, ori:  ALU_OP <= 4'b0011;
			xor_, xori:ALU_OP <= 4'b0100;
			nor_:		  ALU_OP <= 4'b0101;
			sll:		  ALU_OP <= 4'b0110;
			srl:		  ALU_OP <= 4'b0111;
			slt:          ALU_OP <= 4'b1000;
		endcase
		
	end
endmodule