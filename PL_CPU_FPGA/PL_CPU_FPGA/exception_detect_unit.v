

`define IS_VALID_PC(PC) (0 <= (PC) && (PC) <= 32'd1023)

module exception_detect_unit(is_branch_and_taken, ID_is_j, ID_is_jal, ID_PFC_to_IF, EX_PFC_to_IF, excep_flag, IF_FLUSH, ID_flush, EX_FLUSH, MEM_FLUSH, clk, rst);
	
input clk, rst;
input ID_is_j, ID_is_jal, is_branch_and_taken;
input [31:0] ID_PFC_to_IF, EX_PFC_to_IF;

output excep_flag, IF_FLUSH, ID_flush, EX_FLUSH, MEM_FLUSH;

`include "opcodes.txt"


assign excep_flag = ~rst && (((is_branch_and_taken) || ID_is_j || ID_is_jal) && ~`IS_VALID_PC(ID_PFC_to_IF));

assign IF_FLUSH = 0;
assign ID_flush = excep_flag;
assign EX_FLUSH = 0;
assign MEM_FLUSH = 0;


endmodule