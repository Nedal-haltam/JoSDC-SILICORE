module IM(addr , Data_Out);

parameter bit_width = 32;
input [bit_width - 1:0] addr;
output [bit_width - 1:0] Data_Out;

reg [bit_width - 1:0] InstMem [1023 : 0];

assign Data_Out = InstMem[addr[9:0]];

 
initial begin

InstMem[  0] <= 32'h2001000A; // addi x1 x0 10
InstMem[  1] <= 32'h10000002; // beq x0 x0 l
InstMem[  2] <= 32'h2002007B; // addi x2 x0 123
InstMem[  3] <= 32'hFC000000; // hlt


// TODO: for exception handling, we can do better things in terms of handling an exception 
// InstMem[254] <= 32'h201FFFFF; // addi x31 x0 -1
// InstMem[255] <= 32'hFC000000; // hlt

end

/*
addi x1, x1, 10
addi x2, x2, 1

l:

sw x1, x1, 0
sub x1, x1, x2
hlt
bne x1, x0, l
*/
      
endmodule