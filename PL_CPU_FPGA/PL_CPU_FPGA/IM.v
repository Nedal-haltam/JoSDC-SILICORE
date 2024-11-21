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
`include "IM_INIT.INIT"


end      
endmodule
`else
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

InstMem[ 0] <= 32'h20140014;// addi x20 x0 20
InstMem[ 1] <= 32'h20010002;// addi x1 x0 2
InstMem[ 2] <= 32'h2016FFFF;// addi x22 x0 -1
InstMem[ 3] <= 32'h28340011;// bge x1 x20 exit
InstMem[ 4] <= 32'h8C280000;// lw x8 x1 0
InstMem[ 5] <= 32'h2022FFFF;// addi x2 x1 -1
InstMem[ 6] <= 32'h0056182B;// sgt x3 x2 x22
InstMem[ 7] <= 32'h10600009;// beq x3 x0 exit_while
InstMem[ 8] <= 32'h8C450000;// lw x5 x2 0
InstMem[ 9] <= 32'h00A8202B;// sgt x4 x5 x8
InstMem[10] <= 32'h00643824;// and x7 x3 x4
InstMem[11] <= 32'h10E00005;// beq x7 x0 exit_while
InstMem[12] <= 32'h20460001;// addi x6 x2 1
InstMem[13] <= 32'hACC50000;// sw x5 x6 0
InstMem[14] <= 32'h2042FFFF;// addi x2 x2 -1
InstMem[15] <= 32'h08000006;// j while_loop
InstMem[16] <= 32'h20420001;// addi x2 x2 1
InstMem[17] <= 32'hAC480000;// sw x8 x2 0
InstMem[18] <= 32'h20210001;// addi x1 x1 1
InstMem[19] <= 32'h08000003;// j for_loop
InstMem[20] <= 32'hFC000000;// hlt
InstMem[999] <= 32'hFC000000;// addi x20 x0 20
InstMem[1000] <= 32'h201FFFFF;// addi x1 x0 2
InstMem[1001] <= 32'hFC000000;// addi x22 x0 -1


end      
endmodule
`endif