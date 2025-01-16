module RS
(
    input clk, rst,
    input [11:0] opcode,
    input [3:0] ALUOP, 
    input [4:0] ROBEN, ROBEN1, ROBEN2,
    input [31:0] ROBEN1_VAL, ROBEN2_VAL,
    input [31:0] Immediate,

    input [4:0] CDB_ROBEN1,
    input [31:0] CDB_ROBEN1_VAL,
    input [4:0] CDB_ROBEN2,
    input [31:0] CDB_ROBEN2_VAL,

    input VALID_Inst,
    input FU_Is_Free,
    input ROB_FLUSH_Flag,
    output FULL_FLAG,

    output reg [4:0] RS_FU_RS_ID, RS_FU_ROBEN,
    output reg [11:0] RS_FU_opcode,
    output reg [3:0] RS_FU_ALUOP,
    output reg [31:0] RS_FU_Val1, RS_FU_Val2,
    output reg [31:0] RS_FU_Immediate



    ,input [4:0] input_index_test,
    output [11:0] opcode_test,
    output [3:0] ALUOP_test, 
    output [4:0] ROBEN1_test, ROBEN2_test,
    output [31:0] ROBEN1_VAL_test, ROBEN2_VAL_test,
    output [31:0] Immediate_test,
    output [0:0] busy_test

);

`define BUFFER_SIZE_bits (3)
`define BUFFER_SIZE (1 << `BUFFER_SIZE_bits)
`define I(i) i[`BUFFER_SIZE_bits - 1:0]
`define RS_SIZE `BUFFER_SIZE

// the ROBEN of a an instruction is the index of that instruction in the buffer plus one to avoid ROBEN value of zero
// RS buffers to store an instruction
reg [11:0] Reg_opcode [(`RS_SIZE - 1):0];
reg [3:0] Reg_ALUOP [(`RS_SIZE - 1):0];
reg [4:0] Reg_ROBEN [(`RS_SIZE - 1):0];
reg [4:0] Reg_ROBEN1 [(`RS_SIZE - 1):0];
reg [4:0] Reg_ROBEN2 [(`RS_SIZE - 1):0];
reg [31:0] Reg_ROBEN1_VAL [(`RS_SIZE - 1):0];
reg [31:0] Reg_ROBEN2_VAL [(`RS_SIZE - 1):0];
reg [31:0] Reg_Immediate [(`RS_SIZE - 1):0];
reg Reg_Busy [(`RS_SIZE - 1):0];


assign opcode_test = Reg_opcode[`I(input_index_test)];
assign ALUOP_test = Reg_ALUOP[`I(input_index_test)]; 
assign ROBEN1_test = Reg_ROBEN1[`I(input_index_test)]; 
assign ROBEN2_test = Reg_ROBEN2[`I(input_index_test)];
assign ROBEN1_VAL_test = Reg_ROBEN1_VAL[`I(input_index_test)]; 
assign ROBEN2_VAL_test = Reg_ROBEN2_VAL[`I(input_index_test)];
assign Immediate_test = Reg_Immediate[`I(input_index_test)];
assign busy_test = Reg_Busy[`I(input_index_test)];

/*
this block is does the following:
    - resetting the Busy buffer to start with a clean RS
    - and if there is a new instruction is coming it enters it in the Next_Free index if there is and raise the full flag if there is no Next_Free index
*/
reg [4:0] i;
reg [4:0] j;
reg [4:0] Next_Free = 0;

wire [`RS_SIZE-1:0] and_result;

genvar gen_index;
generate
    for (gen_index = 0; gen_index < `RS_SIZE; gen_index = gen_index + 1) begin : generate_and
        if (gen_index == 0) begin
            assign and_result[gen_index] = Reg_Busy[gen_index];
        end else begin
            assign and_result[gen_index] = and_result[gen_index-1] & Reg_Busy[gen_index];
        end
    end
endgenerate

assign FULL_FLAG = ~(rst | ~and_result[`RS_SIZE-1]);

always@(negedge clk, posedge rst) begin
    if (rst) begin
        for (i = 0; i < `RS_SIZE; i = i + 1) begin
            Reg_Busy[i] <= 0;
            Reg_ROBEN[i] <= 0;
        end
        Next_Free <= 0;
    end
    else begin
        if (ROB_FLUSH_Flag) begin
            for (i = 0; i < `RS_SIZE; i = i + 1)
                Reg_Busy[`I(i)] <= 0;
        end
        else if (VALID_Inst) begin
            Next_Free = 0;
            for (i = 0; i < `RS_SIZE; i = i + 1)
                if (~Reg_Busy[`I(i)])
                    Next_Free = i + 1'b1;
            if (Next_Free != 0) begin
                // the new index to use to reserve for the instruction is (Next_Free - 1)
                Reg_ROBEN[`I(Next_Free) - 1'b1] <= ROBEN;
                Reg_opcode[`I(Next_Free) - 1'b1] <= opcode;
                Reg_ALUOP[`I(Next_Free) - 1'b1] <= ALUOP;
                Reg_Busy[`I(Next_Free) - 1'b1] <= 1'b1;
                Reg_ROBEN1 [`I(Next_Free) - 1'b1] <= ROBEN1;
                Reg_ROBEN2 [`I(Next_Free) - 1'b1] <= ROBEN2;
                Reg_ROBEN1_VAL [`I(Next_Free) - 1'b1] <= ROBEN1_VAL;
                Reg_ROBEN2_VAL [`I(Next_Free) - 1'b1] <= ROBEN2_VAL;
                Reg_Immediate [`I(Next_Free) - 1'b1] <= Immediate;
            end
        end
        if (RS_FU_RS_ID != 0) begin
            Reg_Busy[`I(RS_FU_RS_ID) - 1'b1] <= 0;
        end
        for (j = 0; j < `RS_SIZE; j = j + 1) begin
            if (Reg_Busy[`I(j)]) begin
                if (Reg_ROBEN1[`I(j)] == CDB_ROBEN1 && CDB_ROBEN1 != 0) begin
                    Reg_ROBEN1_VAL[`I(j)] <= CDB_ROBEN1_VAL;
                    Reg_ROBEN1[`I(j)] <= 0;
                end
                else if (Reg_ROBEN1[`I(j)] == CDB_ROBEN2 && CDB_ROBEN2 != 0) begin
                    Reg_ROBEN1_VAL[`I(j)] <= CDB_ROBEN2_VAL;
                    Reg_ROBEN1[`I(j)] <= 0;
                end
                if (Reg_ROBEN2[`I(j)] == CDB_ROBEN1 && CDB_ROBEN1 != 0) begin
                    Reg_ROBEN2_VAL[`I(j)] <= CDB_ROBEN1_VAL;
                    Reg_ROBEN2[`I(j)] <= 0;
                end
                else if (Reg_ROBEN2[`I(j)] == CDB_ROBEN2 && CDB_ROBEN2 != 0) begin
                    Reg_ROBEN2_VAL[`I(j)] <= CDB_ROBEN2_VAL;
                    Reg_ROBEN2[`I(j)] <= 0;
                end
            end
        end
    end
end



/*
this block does the following:
    - if the FU is free it picks a ready instruction to execute it and once finish it releases the reserved entry by resetting the busy bit
*/
reg [4:0] k;
always@(posedge clk, posedge rst) begin
    if (rst) begin
        RS_FU_RS_ID <= 0;
    end
    else begin
        RS_FU_opcode <= 0;
        RS_FU_RS_ID <= 0;
        RS_FU_ROBEN <= 0;
        RS_FU_ALUOP <= 0;
        RS_FU_Val1 <= 0;
        RS_FU_Val2 <= 0;
        RS_FU_Immediate <= 0;
        for (k = 0; k < `RS_SIZE; k = k + 1) begin
            if (Reg_Busy[`I(k)] && Reg_ROBEN1[`I(k)] == 0 && Reg_ROBEN2[`I(k)] == 0) begin
                
                RS_FU_opcode <= Reg_opcode[`I(k)];
                RS_FU_Val1 <= Reg_ROBEN1_VAL[`I(k)];
                RS_FU_RS_ID <= k + 1'b1;
                RS_FU_ROBEN <= Reg_ROBEN[`I(k)];
                RS_FU_ALUOP <= Reg_ALUOP[`I(k)];
                RS_FU_Val2 <= Reg_ROBEN2_VAL[`I(k)];
                RS_FU_Immediate <= Reg_Immediate[`I(k)];
            end
        end
    end
end


endmodule