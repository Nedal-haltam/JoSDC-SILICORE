
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
  // 1001   -> if (A > B) then 1 else 0 (aka. sgt)
  // this module takes the opcode and based on it. it decides what operation the ALU should do.

module ALU_OPER(opcode, ALU_OP);
	
	input [11:0] opcode;
	
	output reg [3:0] ALU_OP;
	
`include "opcodes.txt"

	always@(*) begin

		case (opcode) 
			add, addu, addi, lw, sw, jal, jr, j: ALU_OP <= 4'b0000;
			sub, subu:    ALU_OP <= 4'b0001;
			and_, andi:   ALU_OP <= 4'b0010;
			or_, ori:     ALU_OP <= 4'b0011;
			xor_, xori:   ALU_OP <= 4'b0100;
			nor_:		  ALU_OP <= 4'b0101;
			sll:		  ALU_OP <= 4'b0110;
			srl:		  ALU_OP <= 4'b0111;
			slt, slti:    ALU_OP <= 4'b1000;
			sgt:          ALU_OP <= 4'b1001;
		endcase
		
	end
endmodule