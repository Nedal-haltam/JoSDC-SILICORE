



		  // R-Format
parameter add = 7'h20, addu = 7'h21, sub = 7'h22,  subu = 7'h23, and_ = 7'h24, or_ = 7'h25, 
		  xor_ = 7'h26, nor_ = 7'h27, sll = 7'h00, srl = 7'h02, 
		  slt = 7'h2a, sgt = 7'h2b, jr = 7'h08,
		  // I-Format
		  addi = 7'h48, andi = 7'h4c, ori = 7'h4d, xori = 7'h4e, lw = 7'h63, sw = 7'h6b, beq = 7'h44, bne = 7'h45, slti = 7'h6a,
          // J-Format
		  j = 7'h42, jal = 7'h43,
		  // other
		  hlt_inst = 7'b1111111;
