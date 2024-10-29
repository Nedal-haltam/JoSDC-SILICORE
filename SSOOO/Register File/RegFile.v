
module RegFile
#(
    parameter ROB_Entry_WIDTH = 5
 )
(
    input clk, rst,
    input WP1_WR, WP1_WR_IQ,
    input [ROB_Entry_WIDTH - 1:0] WP1_ROBEN, WP1_ROBEN_IQ, 
    input [4:0]                   WP1_DRindex, WP1_DRindex_IQ, 
    input [31:0]                  WP1_Data,



    input [4:0]   RP1_index1, RP1_index2,
    output [31:0] RP1_Reg1, RP1_Reg2
    // for testing purposes
    , output [(1 << ROB_Entry_WIDTH) - 1 : 0] output_ROBEN_test
);



reg [31:0] Regs [31:0];
reg [(1 << ROB_Entry_WIDTH) - 1 : 0] Reg_ROBEs [31:0];

assign output_ROBEN_test = Reg_ROBEs[WP1_DRindex_IQ];

assign RP1_Reg1 = Regs[RP1_index1];
assign RP1_Reg2 = Regs[RP1_index2];


integer i;
always@(posedge clk , posedge rst) begin

if (rst) begin
for(i = 0; i < 32; i++) begin
    Regs[i] <= 0;
end
end

else if (WP1_WR && WP1_DRindex != 5'd0 && Reg_ROBEs[WP1_DRindex] == WP1_ROBEN)
    Regs[WP1_DRindex] <= WP1_Data;
end

integer j;
always@(negedge clk , posedge rst) begin

if (rst) begin
for(j = 0; j < 32; j++) begin
    Reg_ROBEs[j] <= 0;
end
end

else if (WP1_DRindex_IQ != 5'd0 && WP1_WR_IQ)
    Reg_ROBEs[WP1_DRindex_IQ] <= WP1_ROBEN_IQ;
end



endmodule

