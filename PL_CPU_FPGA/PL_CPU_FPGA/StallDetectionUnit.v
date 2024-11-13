// this module detects if there is a load instruction followed by a (branch or jr) instruction.
// and if it's the case then it inserts one nop starting from the execute stage (activate the ID_FLUSH). 
// because we can't forward the load result from the execute stage but we can from the memory stage

module StallDetectionUnit(Wrong_prediction, if_id_opcode, EX_memread, if_id_rs1, if_id_rs2, id_ex_rd, PC_Write, if_id_Write, if_id_flush, id_ex_flush);
  
input [6:0] if_id_opcode; // to tell us if it is a branch instruction
input [4:0] if_id_rs1, if_id_rs2; // the required rs1, rs2 to be used to know if there is a dependencies or not
input EX_memread;
input Wrong_prediction; // Memread signal from the ID_EX buffer to detect if it is a load inst
input [4:0] id_ex_rd;


`include "opcodes.v"



output reg PC_Write, if_id_Write, if_id_flush; // control signals to control the updation of the PC, IF_ID buffer
output reg id_ex_flush; // to select whether to pass the control signal or pass all zeros


always@(*) begin

	if (Wrong_prediction) begin

		PC_Write <= 1'b1;
		if_id_Write <= 1'b1;
		if_id_flush <= 0;
		id_ex_flush <= 1'b1;

	end

	if (EX_memread && (if_id_rs1 == id_ex_rd || if_id_rs2 == id_ex_rd)) begin

		PC_Write <= 0;
		if_id_Write <= 0;
		if_id_flush <= 0;
		id_ex_flush <= 1'b1;

		
	end

	else if (if_id_opcode == jr) begin

		PC_Write <= 0;
		if_id_Write <= 1'b1;
		if_id_flush <= 1'b1;
		id_ex_flush <= 0;

	end

    else if (if_id_opcode == beq || if_id_opcode == bne) begin
		
		PC_Write <= 1'b1;
		if_id_Write <= 1'b1;
		if_id_flush <= 0;
		id_ex_flush <= 0;

    end      
    else begin
		// otherwise we operate normally
		PC_Write <= 1'b1; // we update the PC
		if_id_Write <= 1'b1; // we update the IF_ID_Buffer
		if_id_flush <= 0;
		id_ex_flush <= 0; // and we bypass the current control signals to the next stage
      
    end

end
endmodule