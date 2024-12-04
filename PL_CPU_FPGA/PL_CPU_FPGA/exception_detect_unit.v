

module exception_detect_unit(ID_PC, ID_opcode, excep_flag, id_flush, EX_FLUSH, MEM_FLUSH, clk, rst);
	
input clk, rst;
input [31:0] ID_PC;
input [11:0] ID_opcode;

output excep_flag, id_flush, EX_FLUSH, MEM_FLUSH;

`include "opcodes.txt"

// TODO: proper exception handling
//(TODO: check for invalid PC from fetch stage (IF_PC) and check ID_address ...)


assign excep_flag = 0;
assign id_flush = excep_flag;
assign EX_FLUSH = 0;
assign MEM_FLUSH = 0;
endmodule