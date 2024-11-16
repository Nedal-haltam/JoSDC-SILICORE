`ifdef vscode
module IM(address, q);

input [31:0] address;

output [31 : 0] q;

reg [31 : 0] InstMem [1023 : 0];

assign q = InstMem[address[9:0]];

initial begin
// here we initialize the instruction memory

// TODO: it will probably be changed to a MIF file in the modelsim simulation and FPGA prototyping
`include "IM_INIT.v"


end
endmodule
`endif