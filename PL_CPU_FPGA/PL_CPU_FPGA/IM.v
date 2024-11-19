`ifdef vscode
module IM(addr , Data_Out);

parameter bit_width = 32;
input [bit_width - 1:0] addr;
output [bit_width - 1:0] Data_Out;

reg [bit_width - 1:0] InstMem [1023 : 0];

assign Data_Out = InstMem[addr[9:0]];



integer i;
initial begin
// here we initialize the instruction memory

for (i = 0; i < 1024; i = i + 1)
    InstMem[i] <= 0;

// TODO: it will probably be changed to a MIF file in the modelsim simulation and FPGA prototyping
`include "IM_INIT.v"


end      
endmodule
`endif