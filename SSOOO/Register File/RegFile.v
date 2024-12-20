
module RegFile#
(
    parameter ROB_EN_WIDTH = 5
)
(
    input clk, rst,
    input WP1_Wen, WP1_Wen_IQ,
    input [ROB_EN_WIDTH - 1:0] WP1_ROBEN, WP1_ROBEN_IQ, 
    input [4:0]                   WP1_DRindex, WP1_DRindex_IQ, 
    input [31:0]                  WP1_Data,



    input [4:0]   RP1_index1, RP1_index2,
    output [31:0] RP1_Reg1, RP1_Reg2,
    output [(1 << ROB_EN_WIDTH) - 1 : 0] RP1_Reg1_ROBEN, RP1_Reg2_ROBEN

    // for testing purposes, 
    // it is important to separate the testing signal from any other signal in the module 
    // because it will effect the functionality in an unpredicted way even if the design is implemented correctly
    , input [4:0] input_WP1_DRindex_test
    , output [(1 << ROB_EN_WIDTH) - 1 : 0] output_ROBEN_test
);



reg [31:0] Regs [31:0];
reg [(1 << ROB_EN_WIDTH) - 1 : 0] Reg_ROBEs [31:0];

// for testing purposes
assign output_ROBEN_test = Reg_ROBEs[input_WP1_DRindex_test];

assign RP1_Reg1 = Regs[RP1_index1];
assign RP1_Reg2 = Regs[RP1_index2];

assign RP1_Reg1_ROBEN = Reg_ROBEs[RP1_index1];
assign RP1_Reg2_ROBEN = Reg_ROBEs[RP1_index2];


integer i;
always@(posedge clk , posedge rst) begin : Update_Registers_Block

    if (rst) begin
        for(i = 0; i < 32; i++) begin
            Regs[i] <= 0;
        end
    end
    // TODO: here we decided to allow only the latest instruction to modify on its destination register (checking the last condition)
    // it may change. because we may want the register file to constantly update its values according to every instruction
    // that wants to udpate the register file. either way it will not effect the functionality of the system
    else if (WP1_Wen && WP1_DRindex != 5'd0 && WP1_ROBEN != 0 && Reg_ROBEs[WP1_DRindex] == WP1_ROBEN)
        Regs[WP1_DRindex] <= WP1_Data;
end


integer j;
always@(posedge clk , posedge rst) begin : Update_ROB_Entries_Block

    if (rst) begin
        for(j = 0; j < 32; j++) begin
            Reg_ROBEs[j] <= 0;
        end
    end

    else if (WP1_Wen_IQ && WP1_DRindex_IQ != 5'd0 && WP1_ROBEN_IQ != 0)
        Reg_ROBEs[WP1_DRindex_IQ] <= WP1_ROBEN_IQ;
end



endmodule

