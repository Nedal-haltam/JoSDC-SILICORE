

module exception_detect_unit(PC, opcode, funct, excep_flag, clk, rst);
	
input clk, rst;
input [31:0] PC;
input [5:0] opcode, funct;

output excep_flag;

`include "opcodes.txt"


assign excep_flag = (~rst) ? 0 : 
(
    (opcode == 0) ? 
    (
        (funct == add || funct == sub || funct == addu || funct == subu || funct == and_ || funct == or_ || funct == xor_ ||
        funct == nor_ || funct == sll || funct == srl || funct == jr || funct == slt || funct == sgt) ? 0 : 1'b1
    ) : 
    (
        (opcode == addi || opcode == andi || opcode == ori || opcode == xori || opcode == lw || opcode == sw || 
         opcode == beq || opcode == bne || opcode == blt || opcode == ble || opcode == bgt || opcode == bge || 
         opcode == j || opcode == jal || opcode == slti || opcode == hlt_inst
         /*TODO: check for invalid PC address ...*/) ? 0 : 1'b1
    )
);

endmodule