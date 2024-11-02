

`define sim
`define timetowait 2 * (1000 + 1)

`include "programCounter.v"
`include "adder.v" 
`include "IM.v" 
`include "controlUnit.v" 
`include "mux2x1.v" 
`include "registerFile.v" 
`include "SignExtender.v" 
`include "ALU.v" 
`include "BranchController.v" 
`include "DM.v" 
`include "processor.v"

module testbench;

reg clk = 1, rst = 1;
wire [5:0] PC;
wire [31 : 0] cycles_consumed;
wire [31 : 0] regs0;
wire [31 : 0] regs1;
wire [31 : 0] regs2;
wire [31 : 0] regs3;
wire [31 : 0] regs4;
wire [31 : 0] regs5;


processor cpu(clk, rst, PC, regs0, regs1, regs2, regs3, regs4, regs5, cycles_consumed, clkout);


always #1 clk <= ~clk;
initial begin

$dumpfile("testoutdump.vcd");
$dumpvars;

rst = 0; #4 rst = 1;

#(`timetowait);

$display("Number of cycles consumed: %d", cycles_consumed);
$finish;

end
	
	
endmodule
