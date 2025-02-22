

`define MEMORY_SIZE 2048
`define MEMORY_BITS 11
`define ROB_SIZE_bits (4)
`define BUFFER_SIZE_bitslsbuffer (4)
`define BUFFER_SIZE_bitsRS (4)
`define ROB_SIZE ((1 << `ROB_SIZE_bits))

module RegFile
(
    input clk, rst,
    input WP1_Wen, Decoded_WP1_Wen,
    input [`ROB_SIZE_bits:0] WP1_ROBEN, Decoded_WP1_ROBEN, 
    input [4:0]                   WP1_DRindex, Decoded_WP1_DRindex, 
    input [31:0]                  WP1_Data,

    input ROB_FLUSH_Flag,

    input [4:0]   RP1_index1, RP1_index2,
    // output [31:0] RP1_Reg1, RP1_Reg2,
    output reg [31:0] RP1_Reg1, RP1_Reg2,
    output reg [`ROB_SIZE_bits:0] RP1_Reg1_ROBEN, RP1_Reg2_ROBEN

    // for testing purposes, 
    // it is important to separate the testing signal from any other signal in the module 
    // because it will effect the functionality in an unpredicted way even if the design is implemented correctly
    // , input [4:0] input_WP1_DRindex_test
    // , output [4:0] output_ROBEN_test
);


reg [31:0] Regs [31:0];
reg [`ROB_SIZE_bits:0] Reg_ROBEs [31:0];


// for testing purposes
//
// assign output_ROBEN_test = Reg_ROBEs[input_WP1_DRindex_test];
//

integer i;
always@(posedge clk , posedge rst) begin : Update_Registers_Block

    if (rst) begin
        for(i = 0; i < 32; i = i + 1) begin
            Regs[i] <= 0;
        end
    end
    else if (WP1_Wen && WP1_DRindex != 0 && WP1_ROBEN != 0)
        Regs[WP1_DRindex] <= WP1_Data;
end


integer j;
// always@(posedge clk , posedge rst) begin : Update_ROB_Entries_Block
always@(posedge clk) begin : Update_ROB_Entries_Block

    if (rst || ROB_FLUSH_Flag) begin
        for(j = 0; j < 32; j = j + 1) begin
            Reg_ROBEs[j] <= 0;
        end
    end
    else if (Decoded_WP1_DRindex == WP1_DRindex) begin
        if (Decoded_WP1_Wen && Decoded_WP1_DRindex != 0 && Decoded_WP1_ROBEN != 0) begin
            Reg_ROBEs[Decoded_WP1_DRindex] <= Decoded_WP1_ROBEN;
        end

        else if (WP1_Wen && WP1_DRindex != 0 && WP1_ROBEN != 0 && Reg_ROBEs[WP1_DRindex] == WP1_ROBEN) begin
            Reg_ROBEs[WP1_DRindex] <= 0;
        end
    end

    else begin
        if (Decoded_WP1_Wen && Decoded_WP1_DRindex != 0 && Decoded_WP1_ROBEN != 0) begin
            Reg_ROBEs[Decoded_WP1_DRindex] <= Decoded_WP1_ROBEN;
        end

        if (WP1_Wen && WP1_DRindex != 0 && WP1_ROBEN != 0 && Reg_ROBEs[WP1_DRindex] == WP1_ROBEN) begin
            Reg_ROBEs[WP1_DRindex] <= 0;
        end
    end
end



always@(posedge clk, posedge rst) begin : Read_First_ROBEN
    if (rst) begin
        RP1_Reg1_ROBEN <= 0;
    end
    else begin
        if (Decoded_WP1_Wen && Decoded_WP1_DRindex != 0 && Decoded_WP1_ROBEN != 0 && Decoded_WP1_DRindex == RP1_index1) begin
            RP1_Reg1_ROBEN <= Decoded_WP1_ROBEN;
        end
        else if (ROB_FLUSH_Flag || (WP1_Wen && WP1_DRindex != 0 && WP1_ROBEN != 0 && Reg_ROBEs[WP1_DRindex] == WP1_ROBEN && WP1_DRindex == RP1_index1)) begin
            RP1_Reg1_ROBEN <= 0;
        end
        else begin
            RP1_Reg1_ROBEN <= Reg_ROBEs[RP1_index1];
        end
    end
end
always@(posedge clk, posedge rst) begin : Read_Second_ROBEN
    if (rst) begin
        RP1_Reg2_ROBEN <= 0;
    end
    else begin
        if (Decoded_WP1_Wen && Decoded_WP1_DRindex != 0 && Decoded_WP1_ROBEN != 0 && Decoded_WP1_DRindex == RP1_index2) begin
            RP1_Reg2_ROBEN <= Decoded_WP1_ROBEN;
        end
        else if (ROB_FLUSH_Flag || (WP1_Wen && WP1_DRindex != 0 && WP1_ROBEN != 0 && Reg_ROBEs[WP1_DRindex] == WP1_ROBEN && WP1_DRindex == RP1_index2)) begin
            RP1_Reg2_ROBEN <= 0;
        end
        else begin
            RP1_Reg2_ROBEN <= Reg_ROBEs[RP1_index2];
        end
    end
end

always@(posedge clk, posedge rst) begin : Read_Data
    if (rst) begin
        RP1_Reg1 <= 0;
        RP1_Reg2 <= 0;
    end
    else begin
        RP1_Reg1 <= (RP1_index1 == WP1_DRindex && WP1_Wen && WP1_DRindex != 0 && WP1_ROBEN != 0) ? WP1_Data : Regs[RP1_index1];
        RP1_Reg2 <= (RP1_index2 == WP1_DRindex && WP1_Wen && WP1_DRindex != 0 && WP1_ROBEN != 0) ? WP1_Data : Regs[RP1_index2];
    end
end




`ifdef vscode
integer index;
initial begin
  #(`MAX_CLOCKS + `reset);
  $display("Register file content : ");
  for (index = 0; index <= 31; index = index + 1)
    $display("index = %d , reg_out : signed = %d , unsigned = %d",index[31:0], $signed(Regs[index]), $unsigned(Regs[index]));

end 
`endif

endmodule

