
module forward_unit(id_ex_opcode, id_ex_rs1, id_ex_rs2, 
					ex_mem_rd, ex_mem_wr , mem_wb_rd, mem_wb_wr, 
					forwardA, forwardB, store_rs2_forward
					);
parameter bit_width = 32;

`include "opcodes.v"

// these might containg the funct for the I-format but we will stick the opcode just for naming simplicity
input [6:0] id_ex_opcode;

// forward to 2 places (aka stages)
input [4:0] id_ex_rs1, id_ex_rs2;				

// forward from 3 places (aka stages)
input [4:0] ex_mem_rd, mem_wb_rd; 

input ex_mem_wr, mem_wb_wr;

output reg [1:0] forwardA; // the selection lines for the ALU oprands mux
output reg [2:0] forwardB; // the selection lines for the ALU oprands mux
output reg [1:0] store_rs2_forward; // the selection lines for the register that is going to be stored in the data memory
// output reg [2:0] sel_target_address_adder_mux_InDecodeStage; // the selection lines for the register required in calculating the target address
// output reg [1:0] comparator_mux_selA, comparator_mux_selB; // the selection lines for the comparator operands of the branch
	
	


always@(*) begin
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
end


always@(*) begin
	// for the second ALU Operand:
	if (id_ex_opcode == addi || id_ex_opcode == andi  || id_ex_opcode == ori || 
		 id_ex_opcode == xori || id_ex_opcode == lw || id_ex_opcode == sw || 
		 id_ex_opcode == sll || id_ex_opcode == srl || id_ex_opcode == slti)// oper1 = immed, if the inst is I-format or lw, sw or sll, srl
		forwardB <= 3'b000;
		
	else if (id_ex_opcode == jal) // if jal -> operand2 = 1
		forwardB <= 3'b001;
		
   else if (ex_mem_wr && ex_mem_rd != 5'd0 && ex_mem_rd == id_ex_rs2) // else if EX haz
		forwardB <= 3'b010;
		
   else if (mem_wb_wr && mem_wb_rd != 5'd0 && mem_wb_rd == id_ex_rs2) // else if MEM haz
		forwardB <= 3'b011;
		
	else // else noraml operation -> rs2 from the register file
		forwardB <= 3'b100;
end


always@(*) begin
   // here we forward the rs2 value for storing the right value in the memory
   if (ex_mem_wr && ex_mem_rd != 5'd0 && ex_mem_rd == id_ex_rs2) // if EX haz
      store_rs2_forward <= 2'b01;
		
   else if (mem_wb_wr && mem_wb_rd != 5'd0 && mem_wb_rd == id_ex_rs2) // else if MEM haz
      store_rs2_forward <= 2'b10;
		
   else // else noraml operation -> rs2 from the register file
      store_rs2_forward <= 2'b00;
		

end
	
	
endmodule
