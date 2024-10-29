
// these includes will generate an error if you simulate using quartus
// but because i am using vscode (it's faster and simpler) i should include the module explicitly
`include "instq.v"

module instq_tb;

reg [31:0] PC;
wire [ 5:0] opcode, funct;
wire [ 4:0] rs, rt, rd, shamt;
wire [15:0] immediate;
wire [25:0] address;

instq dut
(
    .PC(PC),
    .opcode(opcode),
    .funct(funct),
    .rs(rs),
    .rt(rt),
    .rd(rd),
    .shamt(shamt),
    .immediate(immediate),
    .address(address)
);

integer i;
initial begin

$monitor("PC = %h\nopcode = %h\nfunct = %h\nrs = %h\nrt = %h\nrd = %h\nshamt = %h\nimmediate = %h\address = %h\n");

`define N 42 
for (i = 0; i < N; i++) begin
    PC = i;
end

end


endmodule