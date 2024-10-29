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

InstMem[0] <= 32'h20010064; 
InstMem[1] <= 32'hAC010001; 
InstMem[2] <= 32'h2020007B; 
InstMem[3] <= 32'h2002FFFE; 
InstMem[4] <= 32'hAC420002; 
InstMem[5] <= 32'h221820; 
InstMem[6] <= 32'hAC63FFA0; 
InstMem[7] <= 32'h220020; 
InstMem[8] <= 32'h622022; 
InstMem[9] <= 32'h822022; 
InstMem[10] <= 32'hAC040003; 
InstMem[11] <= 32'h622823; 
InstMem[12] <= 32'h223021; 
InstMem[13] <= 32'hC23022; 
InstMem[14] <= 32'h3407B676; 
InstMem[15] <= 32'hAC070004; 
InstMem[16] <= 32'hE34024; 
InstMem[17] <= 32'h31090020; 
InstMem[18] <= 32'h1095026; 
InstMem[19] <= 32'h394BFFFF; 
InstMem[20] <= 32'h356C0042; 
InstMem[21] <= 32'h396D0042; 
InstMem[22] <= 32'hA7040; 
InstMem[23] <= 32'hE7882; 
InstMem[24] <= 32'h22802A; 
InstMem[25] <= 32'h41882A; 
InstMem[26] <= 32'h109902A; 
InstMem[27] <= 32'h128982A; 
InstMem[28] <= 32'h252A027; 
InstMem[29] <= 32'h273A827; 
InstMem[30] <= 32'h20160016; 
InstMem[31] <= 32'h8C160004; 
InstMem[32] <= 32'h22D70000; 
InstMem[33] <= 32'h16F60004; 
InstMem[34] <= 32'h22F7FFF6; 
InstMem[35] <= 32'h42F60002; 
InstMem[36] <= 32'h22F7FFF6; 
InstMem[37] <= 32'hC000028; 
InstMem[38] <= 32'h23190001; 
InstMem[39] <= 32'h800002A; 
InstMem[40] <= 32'h20180018; 
InstMem[41] <= 32'h3E00008; 


end


endmodule
