// this module detects if there is a load instruction followed by a (branch or jr) instruction.
// and if it's the case then it inserts one nop starting from the execute stage (activate the ID_FLUSH). 
// because we can't forward the load result from the execute stage but we can from the memory stage

module StallDetectionUnit(id_ex_memrd, if_id_opcode, if_id_rs1, if_id_rs2, id_ex_rd, PC_Write, if_id_Write, id_ex_cntrl_mux_sel);
  
input [6:0] if_id_opcode; // to tell us if it is a branch instruction
input [4:0] if_id_rs1, if_id_rs2; // the required rs1, rs2 to be used to know if there is a dependencies or not

input id_ex_memrd; // Memread signal from the ID_EX buffer to detect if it is a load inst
input [4:0] id_ex_rd;


`include "opcodes.v"



output reg PC_Write, if_id_Write; // control signals to control the updation of the PC, IF_ID buffer
output reg id_ex_cntrl_mux_sel; // to select whether to pass the control signal or pass all zeros


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