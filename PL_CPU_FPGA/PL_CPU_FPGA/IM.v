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
InstMem[  3] <= 32'h0022202B; // sgt x4 x1 x2         
InstMem[  4] <= 32'h0023282B; // sgt x5 x1 x3         
InstMem[  5] <= 32'h0041302B; // sgt x6 x2 x1         
InstMem[  6] <= 32'h0043382B; // sgt x7 x2 x3         
InstMem[  7] <= 32'h0061402B; // sgt x8 x3 x1         
InstMem[  8] <= 32'h0062482B; // sgt x9 x3 x2         
InstMem[  9] <= 32'hFC000000; // hlt                  
   



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