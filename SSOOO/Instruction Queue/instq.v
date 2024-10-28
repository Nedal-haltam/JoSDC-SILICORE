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




endmodule
