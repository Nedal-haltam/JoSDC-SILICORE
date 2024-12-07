module IM(addr , Data_Out, clk);

input clk;
input [31:0] addr;

output [31:0] Data_Out;

reg [31:0] InstMem [1023 : 0];

assign Data_Out = InstMem[addr[9:0]];

integer i;
initial begin
// here we initialize the instruction memory

for (i = 0; i < 1024; i = i + 1)
    InstMem[i] <= 0;
	 
`include "IM_INIT.INIT"

end

endmodule

