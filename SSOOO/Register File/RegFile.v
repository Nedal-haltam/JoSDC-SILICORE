
module RegFile
#(
    parameter ROB_Entry_WIDTH = 5
 )
(
    input [ROB_Entry_WIDTH - 1:0] WP1_ROBEN, 
    input [4:0]                   WP1_DRindex, 
    input [31:0]                  WP1_Data,

    input [4:0]   RP1_index1, RP1_index2,
    output [31:0] RP1_Reg1, RP1_Reg2
);



reg [31:0] Regs [31:0];
reg [(2 ** ROB_Entry_WIDTH) - 1 : 0] Reg_ROBEN [31:0];


assign RP1_Reg1 = Regs[RP1_index1];
assign RP1_Reg2 = Regs[RP1_index2];



endmodule

