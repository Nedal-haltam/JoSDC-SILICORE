


/*
inputs:
    - all of the AddressUnit outputs
internal registers:
    - busy bit and ready bit is needed
*/

`define MEMORY_SIZE 2048
`define MEMORY_BITS 12
`define ROB_SIZE_bits (4)
`define BUFFER_SIZE_bitslsbuffer (4)
`define BUFFER_SIZE_bitsRS (4)
`define ROB_SIZE ((1 << `ROB_SIZE_bits))

module LSBuffer
(
    input clk, rst,
    input VALID_Inst,
    input [`ROB_SIZE_bits:0]  ROBEN,
    input [4:0]  Rd,
    input [11:0] opcode,
    input [`ROB_SIZE_bits:0]  ROBEN1, ROBEN2,
    input [31:0] ROBEN1_VAL, ROBEN2_VAL,
    input [31:0] Immediate,
    input [31:0] EA,

    input [`ROB_SIZE_bits:0] ROB_Start_Index,
    input ROB_FLUSH_Flag,
    input [`ROB_SIZE_bits:0] CDB_ROBEN1,
    input [31:0] CDB_ROBEN1_VAL,
    input [`ROB_SIZE_bits:0] CDB_ROBEN2,
    input [31:0] CDB_ROBEN2_VAL,
    input [`ROB_SIZE_bits:0] CDB_ROBEN3,
    input [31:0] CDB_ROBEN3_VAL,
    input [`ROB_SIZE_bits:0] CDB_ROBEN4,
    input [31:0] CDB_ROBEN4_VAL,

    output reg FULL_FLAG,
    // output FULL_FLAG,
    
    output reg out_VALID_Inst,
    output reg [`ROB_SIZE_bits:0]  out_ROBEN,
    output reg [4:0]  out_Rd,
    output reg [11:0] out_opcode,
    output reg [`ROB_SIZE_bits:0]  out_ROBEN1, out_ROBEN2,
    output reg [31:0] out_ROBEN1_VAL, out_ROBEN2_VAL,
    output reg [31:0] out_Immediate,
    output reg [31:0] out_EA,

    output reg [`BUFFER_SIZE_bitslsbuffer-1:0] Start_Index,
    output reg [`BUFFER_SIZE_bitslsbuffer-1:0] End_Index



    // ,input  [4:0] index_test,    
    // output Reg_Busy_test,
    // output Reg_Ready_test,
    // output [11:0] Reg_opcode_test,
    // output [4:0] Reg_Rd_test,
    // output [31:0] Reg_Write_Data_test,
    // output [31:0] Reg_EA_test,
    // output [4:0] Reg_ROBEN_test,
    // output [4:0] Reg_ROBEN1_test,
    // output [4:0] Reg_ROBEN2_test,
    // output [31:0] Reg_ROBEN1_VAL_test,
    // output [31:0] Reg_ROBEN2_VAL_test,
    // output [31:0] Reg_Immediate_test
);


`ifdef vscode
`include "opcodes.txt"
`else
`include "../opcodes.txt"
`endif  

`define BUFFER_SIZE (1 << `BUFFER_SIZE_bitslsbuffer)
`define I(i) i[`BUFFER_SIZE_bitslsbuffer - 1:0]
`define LDST_SIZE (`BUFFER_SIZE)

`define readybit(i) assign Reg_Ready[i] = Reg_ROBEN1[i] == 0 && Reg_ROBEN2[i] == 0

reg Reg_Busy [(`LDST_SIZE - 1):0];
wire Reg_Ready [(`LDST_SIZE - 1):0];

reg [11:0] Reg_opcode [(`LDST_SIZE - 1):0];
reg [4:0] Reg_Rd [(`LDST_SIZE - 1):0];
reg [31:0] Reg_EA [(`LDST_SIZE - 1):0];
reg [`ROB_SIZE_bits:0] Reg_ROBEN [(`LDST_SIZE - 1):0];
reg [`ROB_SIZE_bits:0] Reg_ROBEN1 [(`LDST_SIZE - 1):0];
reg [`ROB_SIZE_bits:0] Reg_ROBEN2 [(`LDST_SIZE - 1):0];
reg [31:0] Reg_ROBEN1_VAL [(`LDST_SIZE - 1):0];
reg [31:0] Reg_ROBEN2_VAL [(`LDST_SIZE - 1):0];
reg [31:0] Reg_Immediate [(`LDST_SIZE - 1):0];

generate
genvar gen_index;
for (gen_index = 0; gen_index < `LDST_SIZE; gen_index = gen_index + 1) begin : required_block_name
`readybit(gen_index);
end
endgenerate

// assign Reg_Busy_test = Reg_Busy[`I(index_test)];
// assign Reg_Ready_test = Reg_Ready[`I(index_test)];
// assign Reg_opcode_test = Reg_opcode[`I(index_test)];
// assign Reg_Rd_test = Reg_Rd[`I(index_test)];
// assign Reg_EA_test = Reg_EA[`I(index_test)];
// assign Reg_ROBEN_test = Reg_ROBEN[`I(index_test)];
// assign Reg_ROBEN1_test = Reg_ROBEN1[`I(index_test)];
// assign Reg_ROBEN2_test = Reg_ROBEN2[`I(index_test)];
// assign Reg_ROBEN1_VAL_test = Reg_ROBEN1_VAL[`I(index_test)];
// assign Reg_ROBEN2_VAL_test = Reg_ROBEN2_VAL[`I(index_test)];
// assign Reg_Immediate_test = Reg_Immediate[`I(index_test)];

reg [`BUFFER_SIZE_bitslsbuffer:0] i;
reg [`BUFFER_SIZE_bitslsbuffer:0] ji;

always@(posedge clk)
    FULL_FLAG <= ~(rst | ~(End_Index + 1'b1 == Start_Index && (Reg_Busy[Start_Index])));
// assign FULL_FLAG = ~(rst | ~(End_Index == Start_Index && (Reg_Busy[Start_Index])));

wire [`ROB_SIZE_bits:0] out_ROBEN_test = Reg_ROBEN[Start_Index];

always@(negedge clk) begin
    if (rst || ROB_FLUSH_Flag) begin
        for (i = 0; i < `LDST_SIZE; i = i + 1) begin
            Reg_Busy[`I(i)] <= 0;
        end
        Start_Index <= 0;
        End_Index <= 0;
        out_ROBEN <= 0;
        out_VALID_Inst <= 0;
    end
    else begin
        if (VALID_Inst) begin
            Reg_Busy[End_Index] <= 1'b1;

            Reg_opcode[End_Index] <= opcode;
            Reg_Rd[End_Index] <= Rd;
            Reg_EA[End_Index][(`MEMORY_BITS-1):0] <= ROBEN1_VAL[(`MEMORY_BITS-1):0] + Immediate[(`MEMORY_BITS-1):0];
            Reg_ROBEN1[End_Index] <= ROBEN1;
            Reg_ROBEN2[End_Index] <= ROBEN2;
            Reg_ROBEN1_VAL[End_Index] <= ROBEN1_VAL;
            Reg_ROBEN2_VAL[End_Index] <= ROBEN2_VAL;
            Reg_ROBEN[End_Index] <= ROBEN;
            Reg_Immediate[End_Index] <= Immediate;

            End_Index <= End_Index + 1'b1;
        end

        if (Reg_Busy[Start_Index] && Reg_Ready[Start_Index] && ~(Reg_opcode[Start_Index] == sw && Reg_ROBEN[Start_Index] != ROB_Start_Index)) begin
            out_VALID_Inst <= 1'b1;
            out_ROBEN <= Reg_ROBEN[Start_Index];
            out_Rd <= Reg_Rd[Start_Index];
            out_opcode <= Reg_opcode[Start_Index];
            out_ROBEN1 <= Reg_ROBEN1[Start_Index]; 
            out_ROBEN2 <= Reg_ROBEN2[Start_Index];
            out_ROBEN1_VAL <= Reg_ROBEN1_VAL[Start_Index]; 
            out_ROBEN2_VAL <= Reg_ROBEN2_VAL[Start_Index];
            out_Immediate <= Reg_Immediate[Start_Index];

            out_EA <= Reg_EA[Start_Index];

            Reg_Busy[Start_Index] <= 0;
            Start_Index <= Start_Index + 1'b1;
        end
        else begin
            out_VALID_Inst <= 1'b0;
        end





        for (ji = 0; ji < `LDST_SIZE; ji = ji + 1) begin
            if (Reg_Busy[`I(ji)]) begin
                if (Reg_ROBEN1[`I(ji)] == CDB_ROBEN1 && CDB_ROBEN1 != 0) begin
                    Reg_ROBEN1_VAL[`I(ji)] <= CDB_ROBEN1_VAL;
                    Reg_EA[`I(ji)][(`MEMORY_BITS-1):0] <= CDB_ROBEN1_VAL[(`MEMORY_BITS-1):0] + Reg_Immediate[`I(ji)][(`MEMORY_BITS-1):0];
                    Reg_ROBEN1[`I(ji)] <= 0;
                end
                else if (Reg_ROBEN1[`I(ji)] == CDB_ROBEN2 && CDB_ROBEN2 != 0) begin
                    Reg_ROBEN1_VAL[`I(ji)] <= CDB_ROBEN2_VAL;
                    Reg_EA[`I(ji)][(`MEMORY_BITS-1):0] <= CDB_ROBEN2_VAL[(`MEMORY_BITS-1):0] + Reg_Immediate[`I(ji)][(`MEMORY_BITS-1):0];
                    Reg_ROBEN1[`I(ji)] <= 0;
                end
                else if (Reg_ROBEN1[`I(ji)] == CDB_ROBEN3 && CDB_ROBEN3 != 0) begin
                    Reg_ROBEN1_VAL[`I(ji)] <= CDB_ROBEN3_VAL;
                    Reg_EA[`I(ji)][(`MEMORY_BITS-1):0] <= CDB_ROBEN3_VAL[(`MEMORY_BITS-1):0] + Reg_Immediate[`I(ji)][(`MEMORY_BITS-1):0];
                    Reg_ROBEN1[`I(ji)] <= 0;
                end
                else if (Reg_ROBEN1[`I(ji)] == CDB_ROBEN4 && CDB_ROBEN4 != 0) begin
                    Reg_ROBEN1_VAL[`I(ji)] <= CDB_ROBEN4_VAL;
                    Reg_EA[`I(ji)][(`MEMORY_BITS-1):0] <= CDB_ROBEN4_VAL[(`MEMORY_BITS-1):0] + Reg_Immediate[`I(ji)][(`MEMORY_BITS-1):0];
                    Reg_ROBEN1[`I(ji)] <= 0;
                end

                if (Reg_ROBEN2[`I(ji)] == CDB_ROBEN1 && CDB_ROBEN1 != 0) begin
                    Reg_ROBEN2_VAL[`I(ji)] <= CDB_ROBEN1_VAL;
                    Reg_ROBEN2[`I(ji)] <= 0;
                end
                else if (Reg_ROBEN2[`I(ji)] == CDB_ROBEN2 && CDB_ROBEN2 != 0) begin
                    Reg_ROBEN2_VAL[`I(ji)] <= CDB_ROBEN2_VAL;
                    Reg_ROBEN2[`I(ji)] <= 0;
                end
                else if (Reg_ROBEN2[`I(ji)] == CDB_ROBEN3 && CDB_ROBEN3 != 0) begin
                    Reg_ROBEN2_VAL[`I(ji)] <= CDB_ROBEN3_VAL;
                    Reg_ROBEN2[`I(ji)] <= 0;
                end
                else if (Reg_ROBEN2[`I(ji)] == CDB_ROBEN4 && CDB_ROBEN4 != 0) begin
                    Reg_ROBEN2_VAL[`I(ji)] <= CDB_ROBEN4_VAL;
                    Reg_ROBEN2[`I(ji)] <= 0;
                end
            end
        end
    end
end

endmodule

