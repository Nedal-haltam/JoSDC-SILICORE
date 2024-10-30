`include "RegFile.v"

`define DISPLAYVALS(msg, index, data, N) \
    for (i = 0; i < N; i++) begin \
        index = i; \
        $sformat(temp, msg, index, data); \
        $display("%-160s", temp); \
    end

module RegFile_tb;

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

reg [1024*8:0] temp = "";
reg [1024*8:0] msg_RP1_Reg1 = "RP1_index1 = %d , RP1_Reg1 = %d";
reg [1024*8:0] msg_ROB_read = "WP1_DRindex_IQ = %d , output_ROBEN_test = %d";
initial begin
rst = 1; #2 rst = 0;

`DISPLAYVALS(msg_RP1_Reg1, RP1_index1, RP1_Reg1, 10)
`DISPLAYVALS(msg_ROB_read, WP1_DRindex_IQ, output_ROBEN_test, 10)

WP1_Wen <= 1'b1;
WP1_Data <= 32'd123; 
WP1_DRindex <= 5'd1; 
WP1_ROBEN <= 2;
#2;
WP1_Wen_IQ <= 1'b1;
WP1_ROBEN_IQ <= 2;
WP1_DRindex_IQ <= 1;
#4;

`DISPLAYVALS(msg_RP1_Reg1, RP1_index1, RP1_Reg1, 10)
`DISPLAYVALS(msg_ROB_read, WP1_DRindex_IQ, output_ROBEN_test, 10)


// it is important to put $stop or $finish to terminate the simulation becase 
// the line: always #1 clk <= ~clk;, will force the simulation to cotinue and you should exit manually
$finish;
end


endmodule