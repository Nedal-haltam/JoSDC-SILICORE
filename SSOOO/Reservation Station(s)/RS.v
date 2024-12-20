module RS
(
    input clk, rst,
    input [11:0] opcode,
    input [3:0] ALUOP, 
    input [2:0] RS_ID1, RS_ID2,
    input [31:0] RS_ID1_VAL, RS_ID2_VAL,
    input [31:0] Immediate,

    input [2:0] CDB_RS_ID,
    input [31:0] CDB_RS_ID_VAL,

    input VALID_Inst,
    input FU_Is_Free,

    output reg FULL_FLAG,

    output reg [3:0] FU_RS_ID,
    output reg [3:0] FU_ALUOP,
    output reg [31:0] FU_Val1, FU_Val2,
    output reg [31:0] FU_Immediate,

    input [3:0] input_index_test,
    output [11:0] opcode_test,
    output [3:0] ALUOP_test, 
    output [2:0] RS_ID1_test, RS_ID2_test,
    output [31:0] RS_ID1_VAL_test, RS_ID2_VAL_test,
    output [31:0] Immediate_test,
    output [0:0] busy_test

);


`define I(i) i[2:0]

// the RS_ID of a an instruction is the index of that instruction in the buffer plus one to avoid RS_ID value of zero
// RS buffers to store an instruction
reg [11:0] Reg_opcodes [7:0];
reg [3:0] Reg_ALUOPs [7:0];
reg [2:0] Reg_RS_ID1 [7:0];
reg [2:0] Reg_RS_ID2 [7:0];
reg [32:0] Reg_RS_ID1_VAL [7:0];
reg [32:0] Reg_RS_ID2_VAL [7:0];
reg [32:0] Reg_Immediate [7:0];
reg Reg_Busy [7:0];


assign opcode_test = Reg_opcodes[`I(input_index_test)];
assign ALUOP_test = Reg_ALUOPs[`I(input_index_test)]; 
assign RS_ID1_test = Reg_RS_ID1[`I(input_index_test)]; 
assign RS_ID2_test = Reg_RS_ID2[`I(input_index_test)];
assign RS_ID1_VAL_test = Reg_RS_ID1_VAL[`I(input_index_test)]; 
assign RS_ID2_VAL_test = Reg_RS_ID2_VAL[`I(input_index_test)];
assign Immediate_test = Reg_Immediate[`I(input_index_test)];
assign busy_test = Reg_Busy[`I(input_index_test)];

/*
this block is do the following:
    - resetting the Busy buffer to start with a clean RS
    - and if there is a new instruction is coming it enters it in the Next_Free index if there is and raise the full flag if there is no Next_Free index
*/
reg [3:0] i = 0;
reg [3:0] Next_Free = 0;
always@(posedge clk, posedge rst) begin

    if (rst) begin
        for (i = 0; i < 8; i = i + 1)
            Reg_Busy[i] = 0;
        i = 0;
        Next_Free = 0;
        FULL_FLAG = 0;
    end
    else if (VALID_Inst) begin
        Next_Free = 0;
        for (i = 0; i < 8; i = i + 1)
            if (~Reg_Busy[`I(i)])
                Next_Free = i + 1'b1;
        if (Next_Free != 0) begin
            // the new index to use to reserve for the instruction is (Next_Free - 1)
            Reg_Busy[`I(Next_Free) - 1'b1] = 1'b1;
            Reg_opcodes[`I(Next_Free) - 1'b1] = opcode;
            Reg_ALUOPs[`I(Next_Free) - 1'b1] = ALUOP;
            Reg_RS_ID1 [`I(Next_Free) - 1'b1] = RS_ID1;
            Reg_RS_ID2 [`I(Next_Free) - 1'b1] = RS_ID2;
            Reg_RS_ID1_VAL [`I(Next_Free) - 1'b1] = RS_ID1_VAL;
            Reg_RS_ID2_VAL [`I(Next_Free) - 1'b1] = RS_ID2_VAL;
            Reg_Immediate [`I(Next_Free) - 1'b1] = Immediate;
            FULL_FLAG = 1'b0;
        end
        else begin
            FULL_FLAG = 1'b1;
        end
    end
end

/*
this block do the following:
    - monitors the CDB to see if there is a match with RS ID that they are waiting for and take their value to be ready
*/
reg [3:0] j;
always@(posedge clk, posedge rst) begin
    for (j = 0; j < 8; j = j + 1) begin
        if (Reg_Busy[`I(j)]) begin
            if (Reg_RS_ID1[`I(j)] == CDB_RS_ID) begin
                Reg_RS_ID1_VAL[`I(j)] = CDB_RS_ID_VAL;
                Reg_RS_ID1[`I(j)] = 0;
            end
            if (Reg_RS_ID2[`I(j)] == CDB_RS_ID) begin
                Reg_RS_ID2_VAL[`I(j)] = CDB_RS_ID_VAL;
                Reg_RS_ID2[`I(j)] = 0;
            end
        end
    end
end




reg [3:0] k;
always@(posedge clk, posedge rst) begin
    if (FU_Is_Free) begin
        for (k = 0; k < 8; k = k + 1) begin
            // TODO: modify on the way of picking the ready instruction
            if (Reg_Busy[`I(k)] && Reg_RS_ID1[`I(k)] == 0 && Reg_RS_ID2[`I(k)] == 0) begin
                FU_RS_ID = k + 1'b1;
                FU_ALUOP = Reg_ALUOPs[`I(k)];
                FU_Val1 = Reg_RS_ID1_VAL[`I(k)];
                FU_Val2 = Reg_RS_ID2_VAL[`I(k)];
                FU_Immediate = Reg_Immediate[`I(k)];
            end
        end
    end
end

always@(posedge FU_Is_Free) begin
    Reg_Busy[`I(FU_RS_ID) - 1'b1] = 1'b0;
end



endmodule