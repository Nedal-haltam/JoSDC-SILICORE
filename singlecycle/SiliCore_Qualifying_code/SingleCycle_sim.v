


`define MAX_CLOCKS (2 * 100 * 1000)
`define reset 4


`ifndef MEMORY_SIZE
`define MEMORY_SIZE 4096
`define MEMORY_BITS 12
`endif


`ifndef vscode
`timescale 1ns/1ps
`endif

`ifdef vscode

`include "programCounter.v"
`include "IM.v" 
`include "controlUnit.v" 
`include "mux2x1.v" 
`include "registerFile.v" 
`include "ALU.v" 
`include "BranchController.v" 
`include "DM.v" 
`include "SC_CPU.v"

`endif

module SingleCycle_sim;

reg clk = 1, rst = 1;
wire [31:0] PC;
wire [31 : 0] cycles_consumed;

SC_CPU cpu(clk, rst, PC, cycles_consumed, clkout);


always #1 clk <= ~clk;
initial begin

`ifdef VCD_OUT

$dumpfile(`VCD_OUT);
$dumpvars;

`else

$dumpfile("SingleCycle_Waveform.vcd");
$dumpvars;

`endif

rst = 0; #(`reset) rst = 1;

#(`MAX_CLOCKS + 1);

$display("Number of cycles consumed: %d", cycles_consumed);
$finish;

end
	
	
endmodule
