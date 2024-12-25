

`define HALF_CYCLE 1
`define ONE_CLK (2 * `HALF_CYCLE)
`define ADVANCE_N_CYCLE(N) #(`ONE_CLK * N);

`include "InstQ.v"

module InstQ_tb;

reg clk = 0, rst;
reg [31:0] PC;
wire [ 11:0] opcode;
wire [ 4:0] rs, rt, rd, shamt;
wire [15:0] immediate;
wire [25:0] address;

InstQ dut
(
    .clk(clk),
    .rst(rst),
    .PC(PC),
    .opcode(opcode),
    .rs(rs),
    .rt(rt),
    .rd(rd),
    .shamt(shamt),
    .immediate(immediate),
    .address(address)
);

always begin
        #(`HALF_CYCLE) clk <= ~clk;
end
integer i, index;
initial begin
$dumpfile("testout.vcd");
$dumpvars;


`define N 14
for (i = 0; i < `N; i++) begin
    PC = i; 
    index = i + 1;
    #`ONE_CLK $display("Instruction: %d\nPC = %d\nopcode = %h\nrd = %d\nrs = %d\nrt = %d\nshamt = %d\nimmediate = %d\naddress = %d\n"
         ,index,PC, opcode, rd, rs, rt, shamt, immediate, address);
end

$finish;
end


endmodule