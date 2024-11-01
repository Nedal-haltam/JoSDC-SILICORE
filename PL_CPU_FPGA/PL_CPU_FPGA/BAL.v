// this module detects if there is a load instruction followed by a (branch or jr) instruction.
// and if it's the case then it inserts one nop starting from the execute stage (activate the ID_FLUSH). 
// because we can't forward the load result from the execute stage but we can from the memory stage

module BAL(id_ex_memrd, if_id_opcode, if_id_rs1, if_id_rs2, id_ex_rd, PC_Write, if_id_Write, id_ex_cntrl_mux_sel);
  
input [6:0] if_id_opcode; // to tell us if it is a branch instruction
input [4:0] if_id_rs1, if_id_rs2; // the required rs1, rs2 to be used to know if there is a dependencies or not

input id_ex_memrd; // Memread signal from the ID_EX buffer to detect if it is a load inst
input [4:0] id_ex_rd;


parameter add = 7'h20, sub = 7'h22, addu = 7'h21, subu = 7'h23, addi = 7'h48, and_ = 7'h24, andi = 7'h4c, or_ = 7'h25, ori = 7'h4d, xor_ = 7'h26, 
		    xori = 7'h4e, nor_ = 7'h27, sll = 7'h00, srl = 7'h02, lw = 7'h63, sw = 7'h6b, beq = 7'h44, bne = 7'h45, blt = 7'h50, bge = 7'h51, 
			 j = 7'h42, jal = 7'h43, jr = 7'h08, slt = 7'h2a;



output reg PC_Write, if_id_Write, id_ex_cntrl_mux_sel; // control signals to control the updation of the PC, IF_ID buffer
														   // , and the cntrl mux that passes the control signals to ID_EX buffer
  
    always@(*) begin
	 
    if (id_ex_memrd && (if_id_opcode == beq || if_id_opcode == bne || if_id_opcode == blt || if_id_opcode == bge || if_id_opcode == jr) && 
	     id_ex_rd != 0 && (if_id_rs1 == id_ex_rd || if_id_rs2 == id_ex_rd)) begin
		
		PC_Write <= 1'b0; // we hold the PC
		if_id_Write <= 1'b0; // we hold the IF_ID_Buffer
		id_ex_cntrl_mux_sel <= 1'b1; // and we insert a nop -> control signals are zeros
      
    end      
    else begin
		// otherwise we operate normally
		PC_Write <= 1'b1; // we update the PC
		if_id_Write <= 1'b1; // we update the IF_ID_Buffer
		id_ex_cntrl_mux_sel <= 1'b0; // and we bypass the current control signals to the next stage
      
    end
    
  end
endmodule