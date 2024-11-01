
module Branch_or_Jump_TargGen(PC , Immed , targ_addr);
parameter bit_width = 32;

input [bit_width-1:0] PC , Immed;


output [bit_width-1:0] targ_addr;

assign targ_addr = PC + Immed;

endmodule
