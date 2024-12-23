

`define HALF_CYCLE 1
`define ONE_CLK (2 * `HALF_CYCLE)
`define ADVANCE_N_CYCLE(N) #(`ONE_CLK * N);


`include "AddressUnit.v"

module AddressUnit_tb();

reg clk_en = 0;
// always begin
//         #(`HALF_CYCLE) clk <= (~clk_en & clk) | (clk_en & ~clk);
// end
integer i;
initial begin
$dumpfile("testout.vcd");
$dumpvars;

clk_en = 1;
// rst = 0; `ADVANCE_N_CYCLE(1); rst = 1; `ADVANCE_N_CYCLE(1); rst = 0;


end


endmodule