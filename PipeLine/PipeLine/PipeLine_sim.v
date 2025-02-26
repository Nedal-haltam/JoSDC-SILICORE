

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

`include "forwardA.v"
`include "forwardB.v"
`include "forwardC.v"
`include "FORWARDING_stage.v"
`include "IF_stage.v"
`include "ID_stage.v"
`include "EX_stage.v"
`include "MEM_stage.v"
`include "WB_stage.v"
`include "IF_ID_buffer.v"
`include "ID_EX_buffer.v"
`include "EX_MEM_buffer.v"
`include "MEM_WB_buffer.v"
`include "MUX_4x1.v"
`include "PC_src_mux.v"
`include "ALU_OPER.v"
`include "ALU.v"
`include "REG_FILE.v"
`include "IM.v"
`include "DM.v"
`include "PC_register.v"
`include "BranchResolver.v"
`include "control_unit.v"
`include "StallDetectionUnit.v"
`include "Immed_Gen_unit.v"
`include "CompareEqual.v"
`include "BranchDecision.v"
`include "BranchPredictor.v"
`include "PL_CPU.v"

`endif


module PipeLine_sim;

reg input_clk = 0;
reg rst = 0;
wire [31:0] PC, cycles_consumed, StallCount;
`ifdef vscode
wire real BranchPredictionCount, BranchPredictionMissCount;
`else
wire [31:0] BranchPredictionCount, BranchPredictionMissCount;
`endif
PL_CPU cpu
(
	.input_clk(input_clk), 
    .rst(rst), 
	.PC(PC),
	.cycles_consumed(cycles_consumed),
    .StallCount(StallCount),
    .BranchPredictionCount(BranchPredictionCount),
    .BranchPredictionMissCount(BranchPredictionMissCount)
);

always #1 input_clk <= ~input_clk;
initial begin
`ifdef VCD_OUT

$dumpfile(`VCD_OUT);
$dumpvars;

`else

$dumpfile("PipeLine_Waveform.vcd");
$dumpvars;

`endif

rst = 1; #(`reset) rst = 0;

#(`MAX_CLOCKS + 1);

// we add one to the consumed cycles because it will not count for the hlt instruction (the last instruction)
$display("\t\tNumber of cycles consumed: %d", cycles_consumed + 1); 
$display("\t\tStallCount: %d", StallCount);
$display("\t\tExecuted Instruction   Count: %d", cycles_consumed - StallCount);
$display("\t\tBranch Prediction      Count: %d", BranchPredictionCount);
$display("\t\tBranch Prediction HIT  Count: %d", BranchPredictionCount - BranchPredictionMissCount);
$display("\t\tBranch Prediction HIT  Rate : %.3f%%", ((BranchPredictionCount - BranchPredictionMissCount) / BranchPredictionCount) * 100);
$display("\t\tBranch Prediction Miss Count: %d", BranchPredictionMissCount);
$display("\t\tBranch Prediction Miss Rate : %.3f%%", (BranchPredictionMissCount / BranchPredictionCount) * 100);

$finish;

end
endmodule
