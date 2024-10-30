`include "RegFile.v"
`define CAP 100

`define N 6

module RegFile_tb;

task automatic DisplayRegVals(output [4:0] index, input [31:0] data);
// TODO: make it working to make it easier to display the current values, instead of for loops
integer i;
begin
    for (i = 0; i < `N; i++)
        index = i;
        $display("RP1_index1 = %d , RP1_Reg1 = %d", index, data);
end
endtask


parameter ROB_Entry_WIDTH = 5;

reg clk = 0, rst = 0;
reg WP1_Wen = 0, WP1_Wen_IQ = 0;
reg [ROB_Entry_WIDTH - 1:0] WP1_ROBEN = 0, WP1_ROBEN_IQ = 0;
reg [4:0]                   WP1_DRindex = 0, WP1_DRindex_IQ = 0;
reg [31:0]                  WP1_Data;
reg [4:0]   RP1_index1, RP1_index2;
wire [31:0] RP1_Reg1, RP1_Reg2;

wire [(1 << ROB_Entry_WIDTH) - 1 : 0] output_ROBEN_test;

RegFile #(.ROB_Entry_WIDTH(ROB_Entry_WIDTH)) dut  
(
.clk(clk),
.rst(rst),

.WP1_Wen(WP1_Wen),
.WP1_Wen_IQ(WP1_Wen_IQ),
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

always #1 clk <= ~clk;
integer i;
// it is more or less a string in verilog, just in case we need it
// reg [`CAP*8:0] msg = 0;
wire [31:0] data;
assign data = RP1_Reg1;

initial begin
rst = 1; #2 rst = 0;


for (i = 0; i < `N; i++) begin
    RP1_index1 = i;
    $display("RP1_index1 = %d , RP1_Reg1 = %d", RP1_index1, RP1_Reg1);
end

for (i = 0; i < `N; i++) begin
    WP1_DRindex_IQ = i;
    $display("WP1_DRindex_IQ = %d , output_ROBEN_test = %d", WP1_DRindex_IQ, output_ROBEN_test);
end

WP1_Wen <= 1'b1;
WP1_Data <= 32'd123; 
WP1_DRindex <= 5'd1; 
WP1_ROBEN <= 2;
#2;
WP1_Wen_IQ <= 1'b1;
WP1_ROBEN_IQ <= 2;
WP1_DRindex_IQ <= 1;
#4;

for (i = 0; i < `N; i++) begin
    RP1_index1 = i;
    $display("RP1_index1 = %d , RP1_Reg1 = %d", RP1_index1, RP1_Reg1);
end

for (i = 0; i < `N; i++) begin
    WP1_DRindex_IQ = i;
    $display("WP1_DRindex_IQ = %d , output_ROBEN_test = %d", WP1_DRindex_IQ, output_ROBEN_test);
end

// it is important to put $stop or $finish to terminate the simulation becase 
// the line: always #1 clk <= ~clk;, will force the simulation to cotinue and you should exit manually
$finish;
end


endmodule