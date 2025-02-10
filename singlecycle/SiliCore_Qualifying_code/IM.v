module IM(addr , Data_Out);

parameter bit_width = 32;
input [bit_width - 1:0] addr;
output [bit_width - 1:0] Data_Out;

reg [bit_width - 1:0] InstMem [0 : (`MEMORY_SIZE-1)];

assign Data_Out = InstMem[addr[(`MEMORY_BITS-1):0]];



integer i;
initial begin
// here we initialize the instruction memory

for (i = 0; i <= (`MEMORY_SIZE-1); i = i + 1)
    InstMem[i] <= 0;

`include "IM_INIT.INIT"

end      
endmodule

