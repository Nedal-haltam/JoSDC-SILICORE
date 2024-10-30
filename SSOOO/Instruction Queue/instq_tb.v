
// these includes will generate an error if you simulate using quartus
// but because i am using vscode (it's faster and simpler) i should include the module explicitly
`include "InstQ.v"

module InstQ_tb;

reg [31:0] PC;
wire [ 5:0] opcode, funct;
wire [ 4:0] rs, rt, rd, shamt;
wire [15:0] immediate;
wire [25:0] address;

InstQ dut
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

integer i, index;
initial begin
$dumpfile("testout.vcd");
$dumpvars;


`define N 14
for (i = 0; i < `N; i++) begin
    PC = i; 
    index = i + 1;
    #1;
$display(
    "Instruction: %d\nPC = %d\nopcode = %h\nfunct = %h\nrd = %d\nrs = %d\nrt = %d\nshamt = %d\nimmediate = %d\naddress = %d\n"
         ,index,PC, opcode, funct, rd, rs, rt, shamt, immediate, address);
end

end


endmodule