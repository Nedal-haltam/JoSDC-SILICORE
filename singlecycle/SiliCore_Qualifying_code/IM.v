
module IM(address, q);

input [31:0] address;

output [31 : 0] q;

reg [31 : 0] InstMem [1023 : 0];

assign q = InstMem[address[9:0]];

initial begin
// here we initialize the instruction memory
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
             


end


endmodule