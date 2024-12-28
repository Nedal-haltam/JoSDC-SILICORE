
`define HALF_CYCLE 1
`define ONE_CLK (2 * `HALF_CYCLE)
`define ADVANCE_N_CYCLE(N) #(`ONE_CLK * N);

`define MAX_CLOCKS (2 * 100)
`define reset 2 * `ONE_CLK

`ifndef vscode
`timescale 1ns/1ps
`endif

`ifdef vscode

`include "./AddressUnit&ld_st buffer/AddressUnit.v"
`include "./AddressUnit&ld_st buffer/LdStBuffer.v"
`include "./Common Data Bus/CDB.v"
`include "./Instruction Queue/InstQ.v"
`include "./Memory Unit/DM.v"
`include "./Register File/RegFile.v"
`include "./Reorder Buffer/ROB.v"
`include "./Reservation Station/RS.v"
`include "ALU_OPER.v"
`include "ALU.v"
`include "PC_register.v"

`include "OOO_CPU.v"

`endif

module OOO_CPU_Sim();

reg clk = 0, rst = 0;
wire [31:0] PC;
wire [31 : 0] cycles_consumed;

OOO_CPU cpu(clk, rst, cycles_consumed);


always #(`HALF_CYCLE) clk <= ~clk;
initial begin

`ifdef VCD_OUT

$dumpfile(`VCD_OUT);
$dumpvars;

`else

$dumpfile("OOO_Waveform.vcd");
$dumpvars;

`endif

rst = 1; `ADVANCE_N_CYCLE(2); rst = 0;

#(`MAX_CLOCKS + 1);
$display("Number of cycles consumed: %d", cycles_consumed);
$finish;

end
	
	
endmodule
