


`define vscode
`define MAX_CLOCKS (2 * 100000)
`define reset 4

// `include "forward_unit.v"
`include "forwardA.v"
`include "forwardB.v"
`include "forwardC.v"
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
`include "MUX_8x1.v"
`include "ALU_OPER.v"
`include "ALU.v"
`include "REG_FILE.v"
`include "IM.v"
`include "DM.v"
`include "PC_register.v"
`include "BranchResolver.v"
`include "control_unit.v"
`include "exception_detect_unit.v"
`include "StallDetectionUnit.v"
`include "Immed_Gen_unit.v"
`include "CompareEqual.v"
`include "BranchDecision.v"
`include "BranchResolver_2Bit_Predictor.v"
`include "CPU5STAGE.v"



module PL_CPU_mod;

reg input_clk;
reg rst = 0;
wire [31:0] PC, cycles_consumed;
CPU5STAGE cpu(PC, input_clk, rst, cycles_consumed);

always #1 input_clk <= ~input_clk;
initial begin
`ifdef VCD_OUT
$dumpfile(`VCD_OUT);
$dumpvars;
`endif
input_clk <= 0;

rst <= 1; #(`reset) rst = 0;

#(`MAX_CLOCKS + 1);

// we add one to the consumed cycles because it will not count for the hlt instruction (the last instruction)
$display("Number of cycles consumed: %d", cycles_consumed + 1); 
$finish;

end
endmodule
