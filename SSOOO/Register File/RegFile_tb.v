`include "RegFile.v"

module RegFile_tb;

parameter ROB_Entry_WIDTH = 5;

reg clk = 0, rst = 0;
reg WP1_WR = 0, WP1_WR_IQ = 0;
reg [ROB_Entry_WIDTH - 1:0] WP1_ROBEN, WP1_ROBEN_IQ;
reg [4:0]                   WP1_DRindex, WP1_DRindex_IQ;
reg [31:0]                  WP1_Data;
reg [4:0]   RP1_index1, RP1_index2;
wire [31:0] RP1_Reg1, RP1_Reg2;

wire [(1 << ROB_Entry_WIDTH) - 1 : 0] output_ROBEN_test;

RegFile #(.ROB_Entry_WIDTH(ROB_Entry_WIDTH)) dut  
(
.clk(clk),
.rst(rst),

.WP1_WR(WP1_WR),
.WP1_WR_IQ(WP1_WR_IQ),
.WP1_ROBEN(WP1_ROBEN), 
.WP1_DRindex(WP1_DRindex), 
.WP1_Data(WP1_Data),
.WP1_ROBEN_IQ(WP1_ROBEN_IQ),
.WP1_DRindex_IQ(WP1_DRindex_IQ),
.RP1_index1(RP1_index1), 
.RP1_index2(RP1_index2),
.RP1_Reg1(RP1_Reg1),
.RP1_Reg2(RP1_Reg2)

, .output_ROBEN_test(output_ROBEN_test)
);

// always #1 clk <= ~clk;
integer i, j;
initial begin
rst = 1; #2 rst = 0;

$monitor("RP1_index1 = %d , RP1_Reg1 = %d", RP1_index1, RP1_Reg1);
for (i = 0; i < 32; i++) begin
    RP1_index1 <= i; #1;
end

$monitor("WP1_DRindex_IQ = %d , output_ROBEN_test = %d", WP1_DRindex_IQ, output_ROBEN_test);
for (j = 0; j < 32; j++) begin
    WP1_DRindex_IQ <= j; #1; 
end

// it is important to put $stop or $finish to terminate the simulation becase 
// the line: always #1 clk <= ~clk;, will force the simulation to cotinue and you should exit manually
#1 $finish;
end


endmodule