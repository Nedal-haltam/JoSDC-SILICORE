

module exception_detect_unit(excep_flag, IF_FLUSH, ID_flush, EX_FLUSH, MEM_FLUSH, clk, rst);
	
input clk, rst;

output excep_flag, IF_FLUSH, ID_flush, EX_FLUSH, MEM_FLUSH;

`include "opcodes.txt"

// TODO: proper exception handling
//(TODO: check for invalid PC from fetch stage (IF_PC) and check ID_address ...)



assign excep_flag = 0;

assign IF_FLUSH = 0;
assign ID_flush = 0;
assign EX_FLUSH = 0;
assign MEM_FLUSH = 0;


endmodule