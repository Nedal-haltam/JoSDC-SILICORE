
module forward_unit(if_id_opcode, if_id_rs1, if_id_rs2, id_ex_opcode, id_ex_rs1, id_ex_rs2, id_ex_rd, 
					id_ex_wr, ex_mem_rd, ex_mem_wr , mem_wb_rd, mem_wb_wr, 
					sel_target_address_adder_mux_InDecodeStage, 
					comparator_mux_selA, comparator_mux_selB, 
					forwardA, forwardB, store_rs2_forward
					);
parameter bit_width = 32;

parameter add = 7'h20, sub = 7'h22, addu = 7'h21, subu = 7'h23, addi = 7'h48, and_ = 7'h24, andi = 7'h4c, or_ = 7'h25, ori = 7'h4d, xor_ = 7'h26, 
		    xori = 7'h4e, nor_ = 7'h27, sll = 7'h00, srl = 7'h02, lw = 7'h63, sw = 7'h6b, beq = 7'h44, bne = 7'h45, blt = 7'h50, bge = 7'h51, 
			 j = 7'h42, jal = 7'h43, jr = 7'h08, slt = 7'h2a;

// these might containg the funct for the I-format but we will stick the opcode just for naming simplicity
input [6:0] if_id_opcode;
input [6:0] id_ex_opcode;

// forward to 2 places (aka stages)
input [4:0] if_id_rs1, if_id_rs2;
input [4:0] id_ex_rs1, id_ex_rs2;				

// forward from 3 places (aka stages)
input [4:0] id_ex_rd, ex_mem_rd, mem_wb_rd; 

input id_ex_wr, ex_mem_wr, mem_wb_wr;

output reg [1:0] forwardA; // the selection lines for the ALU oprands mux
output reg [2:0] forwardB; // the selection lines for the ALU oprands mux
output reg [1:0] store_rs2_forward; // the selection lines for the register that is going to be stored in the data memory
output reg [2:0] sel_target_address_adder_mux_InDecodeStage; // the selection lines for the register required in calculating the target address
output reg [1:0] comparator_mux_selA, comparator_mux_selB; // the selection lines for the comparator operands of the branch
	
	
	always@(*) begin
	//-----------------------------------------------------------------------------------------
	// in this section of the module we forward to the ALU oprands mux for the execution haz and mem hazard if needed
	
	// for the first ALU Operand:
	if (id_ex_opcode == jal) // if jal -> operand1 = PC
		forwardA <= 2'b00;
		
   else if (ex_mem_wr && ex_mem_rd != 5'd0 && ex_mem_rd == id_ex_rs1) // if EX haz 
		forwardA <= 2'b01;// but it will come from a mux whos sel line is EX_MEM_memread. 
						      // if EX_MEM_memread is zero then it will forward from the buffer that is from the aluout
						      // else then it will forward from the mem out (same thing with rs2)
								
   else if (mem_wb_wr && mem_wb_rd != 5'd0 && mem_wb_rd == id_ex_rs1) // else if MEM haz
		forwardA <= 2'b10;
		
	else // else normal operation -> rs1 from the register file
		forwardA <= 2'b11;
    
	 
	 
	
	// for the second ALU Operand:
	if (id_ex_opcode == addi || id_ex_opcode == andi  || id_ex_opcode == ori || 
		 id_ex_opcode == xori || id_ex_opcode == lw || id_ex_opcode == sw || id_ex_opcode == sll || id_ex_opcode == srl)// oper1 = immed, if the inst is I-format or lw, sw or sll, srl
		forwardB <= 3'b000;
		
	else if (id_ex_opcode == jal) // if jal -> operand2 = 1
		forwardB <= 3'b001;
		
   else if (ex_mem_wr && ex_mem_rd != 5'd0 && ex_mem_rd == id_ex_rs2) // else if EX haz
		forwardB <= 3'b010;
		
   else if (mem_wb_wr && mem_wb_rd != 5'd0 && mem_wb_rd == id_ex_rs2) // else if MEM haz
		forwardB <= 3'b011;
		
	else // else noraml operation -> rs2 from the register file
		forwardB <= 3'b100;
      
		
		
   // here we forward the rs2 value for storing the right value in the memory
   if (ex_mem_wr && ex_mem_rd != 5'd0 && ex_mem_rd == id_ex_rs2) // if EX haz
      store_rs2_forward <= 2'b01;
		
   else if (mem_wb_wr && mem_wb_rd != 5'd0 && mem_wb_rd == id_ex_rs2) // else if MEM haz
      store_rs2_forward <= 2'b10;
		
   else // else noraml operation -> rs2 from the register file
      store_rs2_forward <= 2'b00;
		

	end
	
	
	
	
	
	
	
	always@(*) begin
	
	//-----------------------------------------------------------------------------------------
	// in this section of the module we forward the wanted register to compute the address that we want to 
	// jump to for the jr instruction. we will forward it from the alu out or MEM stage or from the wb_mux in the write back stage
	 
	if (if_id_opcode == jr) begin // if the instruction is a jr in the decode stage then we will select where to forward from
	
		if (id_ex_wr && id_ex_rd != 5'd0 && if_id_rs1 == id_ex_rd) // from the ALU out
			sel_target_address_adder_mux_InDecodeStage <= 3'b000;
			
		else if (ex_mem_wr && ex_mem_rd != 5'd0 && if_id_rs1 == ex_mem_rd) // from the MEM stage
			sel_target_address_adder_mux_InDecodeStage <= 3'b001;
			
		else if (mem_wb_wr && mem_wb_rd != 5'd0 && if_id_rs1 == mem_wb_rd) // from the wb_mux
			sel_target_address_adder_mux_InDecodeStage <= 3'b010;
			
		else 
			sel_target_address_adder_mux_InDecodeStage <= 3'b011; // or from the register file it self if there is no dependencies
			
	end 
	
	else if (if_id_opcode == j || if_id_opcode == jal)
		sel_target_address_adder_mux_InDecodeStage <= 3'b101;
	
	else // any instruction other than jr (e.g. branch or jal). the first Operand of the adder that will calculate the target address will be the PC not a register
			sel_target_address_adder_mux_InDecodeStage <= 3'b100;
		
	end
	
	
	
	
	always@(*) begin
	
	//-----------------------------------------------------------------------------------------
	// 									BRANCH FORWARDING COMPARATOR
	// in this section of the module we decide whether we forward to the operands of the comparator
	// the places are : alu out , MEM stage , wb_mux
	// any branch instruction can use this section to decide whether to branch or not
	
	// for Operand1 of the comparator
	if (id_ex_wr && id_ex_rd != 5'd0 && if_id_rs1 == id_ex_rd) // ID haz
		comparator_mux_selA <= 2'b00;
		
	else if (ex_mem_wr && ex_mem_rd != 5'd0 && if_id_rs1 == ex_mem_rd) // EX haz
		comparator_mux_selA <= 2'b01;
		
	else if (mem_wb_wr && mem_wb_rd != 5'd0 && if_id_rs1 == mem_wb_rd) // MEM haz
		comparator_mux_selA <= 2'b10;
		
	else
		comparator_mux_selA <= 2'b11;
	
	
	
	// for Operand2 of the comparator
	if (id_ex_wr && id_ex_rd != 5'd0 && if_id_rs2 == id_ex_rd) // ID haz
		comparator_mux_selB <= 2'b00;
		
	else if (ex_mem_wr && ex_mem_rd != 5'd0 && if_id_rs2 == ex_mem_rd) // EX haz
		comparator_mux_selB <= 2'b01;
		
	else if (mem_wb_wr && mem_wb_rd != 5'd0 && if_id_rs2 == mem_wb_rd) // MEM haz
		comparator_mux_selB <= 2'b10;
		
	else
		comparator_mux_selB <= 2'b11;
	
	end
	
	
	
	endmodule
