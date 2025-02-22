

`define MEMORY_SIZE 2048
`define MEMORY_BITS 11
`define ROB_SIZE_bits (4)
`define BUFFER_SIZE_bitslsbuffer (4)
`define BUFFER_SIZE_bitsRS (4)
`define ROB_SIZE ((1 << `ROB_SIZE_bits))


/*
inputs:
    - instruction from the InstQ
    - the effective address and the ROBEN to update the associated field
    - CDB ROBEN and ROBEN_VAL to udpate the destination value field and mark it as a finished one
outputs:
    - the head of the buffer to commit its result and go to the next one
*/

module ROB
(
    input clk, rst,
    input [11:0] Decoded_opcode,
    input is_jal, is_hlt, is_beq, is_bne,
    input [31:0] Decoded_PC,
    input [4:0] Decoded_Rd,
    input Decoded_prediction,
    input [31:0] Branch_Target_Addr,
    input [31:0] init_Write_Data,

    input [`ROB_SIZE_bits:0] CDB_ROBEN1,
    input [31:0] CDB_ROBEN1_Write_Data,
    input CDB_Branch_Decision1,
    input CDB_EXCEPTION1,

    input [`ROB_SIZE_bits:0] CDB_ROBEN2,
    input [31:0] CDB_ROBEN2_Write_Data,
    input CDB_EXCEPTION2,

    input [`ROB_SIZE_bits:0] CDB_ROBEN3,
    input [31:0] CDB_ROBEN3_Write_Data,
    input CDB_Branch_Decision2,
    input CDB_EXCEPTION3,

    input [`ROB_SIZE_bits:0] CDB_ROBEN4,
    input [31:0] CDB_ROBEN4_Write_Data,
    input CDB_Branch_Decision3,
    input CDB_EXCEPTION4,

    input VALID_Inst,
    // output FULL_FLAG,
    output reg FULL_FLAG,
    output EXCEPTION_Flag,
    output reg FLUSH_Flag,
    output reg Wrong_prediction,

    output reg [11:0] Commit_opcode,
    output reg [31:0] commit_pc,
    output reg [4:0] Commit_Rd,
    output reg [31:0] Commit_Write_Data,
    output reg Commit_Wen,
    output reg [31:0] commit_BTA,

    input [`ROB_SIZE_bits:0] RP1_ROBEN1, RP1_ROBEN2,

    output reg [31:0] RP1_Write_Data1, RP1_Write_Data2,
    output reg RP1_Ready1, RP1_Ready2,

    output reg [`ROB_SIZE_bits:0] Start_Index,
    output reg [`ROB_SIZE_bits:0] End_Index

//    ,input  [4:0] index_test,
//    output [11:0] Reg_opcode_test,
//    output [4:0]  Reg_Rd_test,
//    output [31:0] Reg_Write_Data_test,
//    output [0:0]  Reg_Busy_test,
//    output [0:0]  Reg_Ready_test,
//    output [1:0]  Reg_Speculation_test,
//    output [0:0]  Reg_Exception_test,
//    output [0:0]  Reg_Valid_test
);

`include "opcodes.txt"

`define I(i) i[`ROB_SIZE_bits - 1:0]


`define Imone(i) `I(i) - 1'b1
`define validbit(i) assign Reg_Valid[i] = ~(Reg_Speculation[i][0] | Reg_Exception[i]) // ~speculative && ~excepted

reg [11:0] Reg_opcode [(`ROB_SIZE - 1):0];
reg [31:0] Reg_PC [(`ROB_SIZE - 1):0];
reg [4:0] Reg_Rd [(`ROB_SIZE - 1):0];
reg [1:0] Reg_Speculation [(`ROB_SIZE - 1):0];
reg Reg_Busy [(`ROB_SIZE - 1):0];
reg Reg_Ready [(`ROB_SIZE - 1):0];
reg Reg_Exception [(`ROB_SIZE - 1):0];
reg [31:0] Reg_Write_Data [(`ROB_SIZE - 1):0];
reg [31:0] Reg_BTA[(`ROB_SIZE - 1):0];


wire Reg_Valid [(`ROB_SIZE - 1):0];
generate
genvar gen_index;
for (gen_index = 0; gen_index < `ROB_SIZE; gen_index = gen_index + 1) begin : required_block_name
`validbit(gen_index);
end
endgenerate


//assign Reg_opcode_test = Reg_opcode[`I(index_test)];
//assign Reg_Rd_test = Reg_Rd[`I(index_test)];
//assign Reg_Write_Data_test = Reg_Write_Data[`I(index_test)];
//assign Reg_Busy_test = Reg_Busy[`I(index_test)];
//assign Reg_Ready_test = Reg_Ready[`I(index_test)];
//assign Reg_Speculation_test = Reg_Speculation[`I(index_test)];
//assign Reg_Exception_test = Reg_Exception[`I(index_test)];
//assign Reg_Valid_test = Reg_Valid[`I(index_test)];


always@(posedge clk) begin
/*
forward that data coming from:
    - the commit port
    - the CDB, the four sources
*/
if ((RP1_ROBEN1 == Start_Index) && (Commit_Wen && Commit_Rd != 0)) begin
RP1_Ready1 <= 1'b1;
RP1_Write_Data1 <= Commit_Write_Data;
end
else if (RP1_ROBEN1 == CDB_ROBEN1) begin
RP1_Ready1 <= 1'b1;
RP1_Write_Data1 <= CDB_ROBEN1_Write_Data;
end
else if (RP1_ROBEN1 == CDB_ROBEN2) begin
RP1_Ready1 <= 1'b1;
RP1_Write_Data1 <= CDB_ROBEN2_Write_Data;
end
else if (RP1_ROBEN1 == CDB_ROBEN3) begin
RP1_Ready1 <= 1'b1;
RP1_Write_Data1 <= CDB_ROBEN3_Write_Data;
end
else if (RP1_ROBEN1 == CDB_ROBEN4) begin
RP1_Ready1 <= 1'b1;
RP1_Write_Data1 <= CDB_ROBEN4_Write_Data;
end
else begin
RP1_Ready1 <= Reg_Ready[`Imone(RP1_ROBEN1)];
RP1_Write_Data1 <= Reg_Write_Data[`Imone(RP1_ROBEN1)];
end


if ((RP1_ROBEN2 == Start_Index) && (Commit_Wen && Commit_Rd != 0)) begin
RP1_Ready2 <= 1'b1;
RP1_Write_Data2 <= Commit_Write_Data;
end
else if (RP1_ROBEN2 == CDB_ROBEN1) begin
RP1_Ready2 <= 1'b1;
RP1_Write_Data2 <= CDB_ROBEN1_Write_Data;
end
else if (RP1_ROBEN2 == CDB_ROBEN2) begin
RP1_Ready2 <= 1'b1;
RP1_Write_Data2 <= CDB_ROBEN2_Write_Data;
end
else if (RP1_ROBEN2 == CDB_ROBEN3) begin
RP1_Ready2 <= 1'b1;
RP1_Write_Data2 <= CDB_ROBEN3_Write_Data;
end
else if (RP1_ROBEN2 == CDB_ROBEN4) begin
RP1_Ready2 <= 1'b1;
RP1_Write_Data2 <= CDB_ROBEN4_Write_Data;
end
else begin
RP1_Ready2 <= Reg_Ready[`Imone(RP1_ROBEN2)];
RP1_Write_Data2 <= Reg_Write_Data[`Imone(RP1_ROBEN2)];
end

end

always@(negedge clk)
    FULL_FLAG <= ~(rst | ~(End_Index == Start_Index && (Reg_Busy[`Imone(Start_Index)])));

assign EXCEPTION_Flag = Reg_Busy[`Imone(Start_Index)] & Reg_Exception[`Imone(Start_Index)];



reg [`ROB_SIZE_bits:0] i = 0;
reg [`ROB_SIZE_bits:0] k = 0;
always@(posedge clk, posedge rst) begin

    if (rst) begin
        End_Index <= 1;
    end
    else if (FLUSH_Flag) begin
        End_Index <= 1;
    end
    else if (VALID_Inst) begin
        if (End_Index + 1'b1 == (`ROB_SIZE + 1'b1))
            End_Index <= 1;
        else 
            End_Index <= End_Index + 1'b1;
    end
end

always@(posedge clk, posedge rst) begin
    if (rst) begin
        for (i = 0; i < `ROB_SIZE; i = i + 1) begin
            Reg_Busy[`I(i)] <= 0;
            Reg_Ready[`I(i)] <= 0;
            Reg_Speculation[`I(i)] <= 0;
            Reg_Exception[`I(i)] <= 0;
            Reg_opcode[`I(i)] <= 0;
        end
        Start_Index <= 1;
    end
    else begin
        if (VALID_Inst) begin
            Reg_opcode[`Imone(End_Index)] <= Decoded_opcode;
            Reg_PC[`Imone(End_Index)] <= Decoded_PC;
            Reg_Rd[`Imone(End_Index)] <= Decoded_Rd;
            Reg_Busy[`Imone(End_Index)] <= 1'b1;
            Reg_Ready[`Imone(End_Index)] <= is_hlt || is_jal;
            Reg_Speculation[`Imone(End_Index)][0] <= is_beq || is_bne;
            Reg_Speculation[`Imone(End_Index)][1] <= Decoded_prediction;
            Reg_BTA[`Imone(End_Index)] <= Branch_Target_Addr;
            Reg_Write_Data[`Imone(End_Index)] <= init_Write_Data;
            Reg_Exception[`Imone(End_Index)] <= 1'b0;
        end
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        if (|CDB_ROBEN1) begin
            Reg_Write_Data[`Imone(CDB_ROBEN1)] <= CDB_ROBEN1_Write_Data;
            Reg_Speculation[`Imone(CDB_ROBEN1)][0] <= Reg_Speculation[`Imone(CDB_ROBEN1)][0] & (CDB_Branch_Decision1 ^ Reg_Speculation[`Imone(CDB_ROBEN1)][1]);
            Reg_Ready[`Imone(CDB_ROBEN1)] <= 1'b1;
            Reg_Exception[`Imone(CDB_ROBEN1)] <= CDB_EXCEPTION1;
        end
        if (|CDB_ROBEN2) begin
            Reg_Write_Data[`Imone(CDB_ROBEN2)] <= CDB_ROBEN2_Write_Data;
            Reg_Speculation[`Imone(CDB_ROBEN2)] <= 2'b0;
            Reg_Ready[`Imone(CDB_ROBEN2)] <= 1'b1;
            Reg_Exception[`Imone(CDB_ROBEN2)] <= CDB_EXCEPTION2;
        end
        if (|CDB_ROBEN3) begin
            Reg_Write_Data[`Imone(CDB_ROBEN3)] <= CDB_ROBEN3_Write_Data;
            Reg_Speculation[`Imone(CDB_ROBEN3)][0] <= Reg_Speculation[`Imone(CDB_ROBEN3)][0] & (CDB_Branch_Decision2 ^ Reg_Speculation[`Imone(CDB_ROBEN3)][1]);
            Reg_Ready[`Imone(CDB_ROBEN3)] <= 1'b1;
            Reg_Exception[`Imone(CDB_ROBEN3)] <= CDB_EXCEPTION3;
        end
        if (|CDB_ROBEN4) begin
            Reg_Write_Data[`Imone(CDB_ROBEN4)] <= CDB_ROBEN4_Write_Data;
            Reg_Speculation[`Imone(CDB_ROBEN4)][0] <= Reg_Speculation[`Imone(CDB_ROBEN4)][0] & (CDB_Branch_Decision3 ^ Reg_Speculation[`Imone(CDB_ROBEN4)][1]);
            Reg_Ready[`Imone(CDB_ROBEN4)] <= 1'b1;
            Reg_Exception[`Imone(CDB_ROBEN4)] <= CDB_EXCEPTION3;
        end

        if (Reg_Busy[`Imone(Start_Index)]) begin
            if (Reg_Valid[`Imone(Start_Index)]) begin // handle ALU, lw, sw that are ready to commit (sw: do nothing, ALU/lw: write on the RegFile)
                if (Reg_Ready[`Imone(Start_Index)]) begin
                    Reg_Busy[`Imone(Start_Index)] <= 0;
                    if (Start_Index + 1'b1 == (`ROB_SIZE + 1'b1))
                        Start_Index <= 1;
                    else 
                        Start_Index <= Start_Index + 1'b1;
                end
            end
            else if (Reg_Speculation[`Imone(Start_Index)][0]) begin // handle branch insts
                if (Reg_Ready[`Imone(Start_Index)]) begin // if speculative and ready then prediction was wrong
                    for (k = 0; k < `ROB_SIZE; k = k + 1) begin // flush all insts
                        Reg_Busy[k] <= 0;
                    end
                    Start_Index <= 1;
                end
            end
            else if (Reg_Exception[`Imone(Start_Index)]) begin // handle branch insts
                for (k = 0; k < `ROB_SIZE; k = k + 1) begin // flush all insts
                    Reg_Busy[k] <= 0;
                end
                Start_Index <= 1;
            end
        end
    end
end



always@(negedge clk, posedge rst) begin
    if (rst) begin
        Commit_opcode <= 0;
        commit_pc <= 0;
        Commit_Rd <= 0;
        Commit_Write_Data <= 0;
        Commit_Wen <= 0;
        FLUSH_Flag <= 0;
        Wrong_prediction <= 0;
    end
    else begin
        Commit_opcode <= 0;
        commit_pc <= 0;
        Commit_Rd <= 0;
        Commit_Write_Data <= 0;
        Commit_Wen <= 0;
        FLUSH_Flag <= 0;
        Wrong_prediction <= 0;
        if (Reg_Busy[`Imone(Start_Index)]) begin
            if (Reg_Exception[`Imone(Start_Index)]) begin
                FLUSH_Flag <= 1'b1;
                Commit_opcode <= Reg_opcode[`Imone(Start_Index)];
                commit_pc <= Reg_PC[`Imone(Start_Index)];
            end
            else if (Reg_Ready[`Imone(Start_Index)]) begin
                FLUSH_Flag <= Reg_Speculation[`Imone(Start_Index)][0];
                Wrong_prediction <= Reg_Speculation[`Imone(Start_Index)][0];
                commit_BTA <= Reg_BTA[`Imone(Start_Index)];
                Commit_opcode <= Reg_opcode[`Imone(Start_Index)];
                commit_pc <= Reg_PC[`Imone(Start_Index)];
                Commit_Rd <= Reg_Rd[`Imone(Start_Index)];
                Commit_Write_Data <= Reg_Write_Data[`Imone(Start_Index)];
                Commit_Wen <= (!(Reg_opcode[`Imone(Start_Index)] == sw || Reg_opcode[`Imone(Start_Index)] == beq || 
                                Reg_opcode[`Imone(Start_Index)] == bne));
            end
        end
    end
end


endmodule





