
module comparator(A, B, PC_src, exception_flag, opcode);
	
	input [31:0] A, B;
	input [6:0] opcode;
	input exception_flag;
	
	output reg [1:0] PC_src;

	
parameter add = 7'h20, sub = 7'h22, addu = 7'h21, subu = 7'h23, addi = 7'h48, and_ = 7'h24, andi = 7'h4c, or_ = 7'h25, ori = 7'h4d, xor_ = 7'h26, 
		    xori = 7'h4e, nor_ = 7'h27, sll = 7'h00, srl = 7'h02, lw = 7'h63, sw = 7'h6b, beq = 7'h44, bne = 7'h45, blt = 7'h50, bge = 7'h51, 
			 j = 7'h42, jal = 7'h43, jr = 7'h08;

	always@(*) begin
		
		if (exception_flag) // this flag is from the exception_detect_unit
			PC_src <= 2'b01;
		
		else begin
			
			if (opcode == beq && A == B)
				PC_src <= 2'b10;
				
			else if (opcode == bne && A != B) 
				PC_src <= 2'b10;
				
			else if (opcode == blt && $signed(A) < $signed(B)) 
				PC_src <= 2'b10;
				
			else if (opcode == bge && $signed(A) >= $signed(B)) 
				PC_src <= 2'b10;
				
         else if (opcode == j || opcode == jal || opcode == jr)
				PC_src <= 2'b10;
			
         else // else if it is not branch instruction we continue with normal flow (PC + 4) / or PC + 1 (Depends on the memory organization)
				PC_src <= 2'b00;
			
		end
		
	end
	
endmodule
