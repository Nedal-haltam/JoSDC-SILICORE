module IM(addr , Data_Out);

parameter bit_width = 32;
input [bit_width - 1:0] addr;
output [bit_width - 1:0] Data_Out;

reg [bit_width - 1:0] InstMem [1023 : 0];

assign Data_Out = InstMem[addr[9:0]];

 
initial begin


InstMem[  0] <= 32'h2001000A; // addi x1 x0 10        
InstMem[  1] <= 32'h2002FFFE; // addi x2 x0 -2        
InstMem[  2] <= 32'h2003FFFF; // addi x3 x0 -1        
InstMem[  3] <= 32'hA8240002; // slti x4 x1 2         
InstMem[  4] <= 32'hA825001E; // slti x5 x1 30        
InstMem[  5] <= 32'hA826000A; // slti x6 x1 10        
InstMem[  6] <= 32'hA847FFFE; // slti x7 x2 -2        
InstMem[  7] <= 32'hA848FFFF; // slti x8 x2 -1        
InstMem[  8] <= 32'hA8490000; // slti x9 x2 0         
InstMem[  9] <= 32'hA84A000A; // slti x10 x2 10       
InstMem[ 10] <= 32'hA86BFFFE; // slti x11 x3 -2       
InstMem[ 11] <= 32'hA86CFFFF; // slti x12 x3 -1       
InstMem[ 12] <= 32'hA86D0000; // slti x13 x3 0        
InstMem[ 13] <= 32'hA86E000A; // slti x14 x3 10       
InstMem[ 14] <= 32'hFC000000; // hlt                  



// TODO: for exception handling, we can do better thigs in terms of handling an exception 
InstMem[254] <= 32'h201FFFFF; // addi x31 x0 -1
InstMem[255] <= 32'hFC000000; // hlt

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