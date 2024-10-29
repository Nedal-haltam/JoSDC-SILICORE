`include "RegFile.v"

module RegFile_tb;

parameter ROB_Entry_WIDTH = 5;

reg [ROB_Entry_WIDTH - 1:0] WP1_ROBEN;
reg [4:0]                   WP1_DRindex;
reg [31:0]                  WP1_Data;
reg [4:0]   RP1_index1, RP1_index2;
wire [31:0] RP1_Reg1, RP1_Reg2;

RegFile #(.ROB_Entry_WIDTH(ROB_Entry_WIDTH)) dut  
(

.WP1_ROBEN(WP1_ROBEN), 
.WP1_DRindex(WP1_DRindex), 
.WP1_Data(WP1_Data),
.RP1_index1(RP1_index1), 
.RP1_index2(RP1_index2),
.RP1_Reg1(RP1_Reg1),
.RP1_Reg2(RP1_Reg2)

);


endmodule