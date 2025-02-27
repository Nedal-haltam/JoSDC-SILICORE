
module IM(addr_from_assign, addr , Data_Out, clk);

input clk;
input [31:0] addr, addr_from_assign;
output [31:0] Data_Out;



// `ifdef vscode
reg [31:0] InstMem [0 : 2047];
assign Data_Out = InstMem[addr[10:0]];
    integer i;
    initial begin
    // here we initialize the instruction memory
    for (i = 0; i <= 2047; i = i + 1)
        InstMem[i] <= 0;	 
    `include "IM_INIT.INIT"
    end
// `else
// InstMem instructionmemory
// (
// 	.address(addr_from_assign[10:0]),
// 	.clock(clk),
// 	.q(Data_Out)
// );
// `endif


endmodule

