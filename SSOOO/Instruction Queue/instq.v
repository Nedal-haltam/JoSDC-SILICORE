module instq
(
    input  [31:0] PC,
    output [ 5:0] opcode, funct,
    output [ 4:0] rs, rt, rd, shamt,
    output [15:0] immediate,
    output [25:0] address
);


reg [31:0] InstMem [63:0];

wire [31:0] inst;

assign inst = InstMem[PC];

assign opcode    = inst[31:26];
assign funct     = inst[5:0];
assign rs        = inst[25:21];
assign rt        = inst[20:16];
assign rd        = inst[15:11];
assign shamt     = inst[10:6];
assign immediate = inst[15:0];
assign address   = inst[25:0];



// here we initialze the instruction Memory using the Real time CAS
initial begin

InstMem[  0] <= 32'h20010064; // addi x1 x0 100       
InstMem[  1] <= 32'hAC010001; // sw x1 x0 1           
InstMem[  2] <= 32'h2020007B; // addi x0 x1 123       
InstMem[  3] <= 32'h2002FFFE; // addi x2 x0 -2        
InstMem[  4] <= 32'hAC420002; // sw x2 x2 2           
InstMem[  5] <= 32'h00221820; // add x3 x1 x2         
InstMem[  6] <= 32'hAC63FFA0; // sw x3 x3 -96         
InstMem[  7] <= 32'h00220020; // add x0 x1 x2         
InstMem[  8] <= 32'h00622022; // sub x4 x3 x2         
InstMem[  9] <= 32'h00822022; // sub x4 x4 x2         
InstMem[ 10] <= 32'hAC040003; // sw x4 x0 3           
InstMem[ 11] <= 32'h00622823; // subu x5 x3 x2        
InstMem[ 12] <= 32'h00223021; // addu x6 x1 x2        
InstMem[ 13] <= 32'h00C23022; // sub x6 x6 x2         

end


endmodule
