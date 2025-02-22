
module IM(addr , Data_Out, clk);

input clk;
input [31:0] addr;

output [31:0] Data_Out;

reg [31:0] InstMem [0 : 2047];

assign Data_Out = InstMem[addr[10:0]];

integer i;
initial begin
// here we initialize the instruction memory

for (i = 0; i <= 2047; i = i + 1)
    InstMem[i] <= 0;
	 
`include "IM_INIT.INIT"

end

endmodule

