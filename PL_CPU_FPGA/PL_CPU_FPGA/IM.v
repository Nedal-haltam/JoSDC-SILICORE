`ifdef vscode
module IM(addr , Data_Out);

parameter bit_width = 32;
input [bit_width - 1:0] addr;
output [bit_width - 1:0] Data_Out;

reg [bit_width - 1:0] InstMem [1023 : 0];

assign Data_Out = InstMem[addr[9:0]];


initial begin
// here we initialize the instruction memory

// TODO: it will probably be changed to a MIF file in the modelsim simulation and FPGA prototyping
`include "IM_INIT.v"

// TODO: for exception handling, we can do better things in terms of handling an exception 
// InstMem[254] <= 32'h201FFFFF; // addi x31 x0 -1
// InstMem[255] <= 32'hFC000000; // hlt

end      
endmodule
`endif