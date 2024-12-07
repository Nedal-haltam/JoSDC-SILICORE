module StallDetectionUnit(Wrong_prediction, ID_opcode, EX_memread, ID_rs1_ind, ID_rs2_ind, EX_rd, 
						  PC_Write, IF_ID_Write, IF_ID_flush, ID_EX_flush);

`include "opcodes.txt"

input [11:0] ID_opcode; // to tell us if it is a branch instruction
input [4:0] ID_rs1_ind, ID_rs2_ind; // the required rs1, rs2 to be used to know if there is a dependencies or not
input EX_memread;
input Wrong_prediction; // Memread signal from the ID_EX buffer to detect if it is a load inst
input [4:0] EX_rd;

output reg PC_Write, IF_ID_Write, IF_ID_flush; // control signals to control the updation of the PC, ID buffer
output reg ID_EX_flush; // to select whether to pass the control signal or pass all zeros


always@(*) begin

	if (Wrong_prediction) begin // wrong prediction

		PC_Write <= 1'b1;
		IF_ID_Write <= 1'b1;
		IF_ID_flush <= 0;
		ID_EX_flush <= 1'b1;

	end

	else if (EX_memread && EX_rd != 0 && (ID_rs1_ind == EX_rd || ID_rs2_ind == EX_rd)) begin // load use

		PC_Write <= 0;
		IF_ID_Write <= 0;
		IF_ID_flush <= 0;
		ID_EX_flush <= 1'b1;
		
	end

	else if (ID_opcode == jr) begin // jr in decode

		PC_Write <= 0;
		IF_ID_Write <= 1'b1;
		IF_ID_flush <= 1'b1;
		ID_EX_flush <= 0;

	end

    else begin
		// otherwise we operate normally
		PC_Write <= 1'b1; // we update the PC
		IF_ID_Write <= 1'b1; // we update the ID_Buffer
		IF_ID_flush <= 0;
		ID_EX_flush <= 0; // and we bypass the current control signals to the next stage
      
    end

end
endmodule