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


`define I(i) i[3:0]

// the ROBEN of a an instruction is the index of that instruction in the buffer plus one to avoid ROBEN value of zero
// RS buffers to store an instruction
reg [11:0] Reg_opcode [15:0];
reg [3:0] Reg_ALUOP [15:0];
reg [4:0] Reg_ROBEN [15:0];
reg [4:0] Reg_ROBEN1 [15:0];
reg [4:0] Reg_ROBEN2 [15:0];
reg [31:0] Reg_ROBEN1_VAL [15:0];
reg [31:0] Reg_ROBEN2_VAL [15:0];
reg [31:0] Reg_Immediate [15:0];
reg Reg_Busy [15:0];


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
reg [4:0] i = 0;
reg [4:0] Next_Free = 0;
assign FULL_FLAG = ~(rst | 
                    ~(
                        Reg_Busy[0] & 
                        Reg_Busy[1] & 
                        Reg_Busy[2] & 
                        Reg_Busy[3] & 
                        Reg_Busy[4] & 
                        Reg_Busy[5] & 
                        Reg_Busy[6] & 
                        Reg_Busy[7] & 
                        Reg_Busy[8] & 
                        Reg_Busy[9] & 
                        Reg_Busy[10] & 
                        Reg_Busy[11] & 
                        Reg_Busy[12] & 
                        Reg_Busy[13] & 
                        Reg_Busy[14] & 
                        Reg_Busy[15]
                    ));
always@(negedge clk, posedge rst) begin

    if (rst) begin
        for (i = 0; i < 16; i = i + 1) begin
`ifdef vscode
            Reg_Busy[i] <= 0;
`endif
            Reg_ROBEN[i] <= 0;
        end
        i <= 0;
        Next_Free <= 0;
    end
    else if (ROB_FLUSH_Flag) begin
`ifdef vscode
        for (i = 0; i < 16; i = i + 1)
            Reg_Busy[`I(i)] <= 0;
`endif
    end
    else if (VALID_Inst) begin
        Next_Free = 0;
        for (i = 0; i < 16; i = i + 1)
            if (~Reg_Busy[`I(i)])
                Next_Free = i + 1'b1;
        if (Next_Free != 0) begin
            // TODO: should investigate in this wierd behaviour
            // making the following assignments as non-blocking increase the number of cycles consumed
            // but if blocking assignmnents is used it consumes less cycles relative the non-blocking, 
            // and it rarely consumes more and if it does it will be by very small number
            // to see the effect run the script in the benchmark folder in both cases and see the differece in the stats file in each benchmark
            Reg_ROBEN[`I(Next_Free) - 1'b1] = ROBEN;
            // the new index to use to reserve for the instruction is (Next_Free - 1)
            Reg_opcode[`I(Next_Free) - 1'b1] = opcode;
            Reg_ALUOP[`I(Next_Free) - 1'b1] = ALUOP;
`ifdef vscode
            Reg_Busy[`I(Next_Free) - 1'b1] = 1'b1;
            Reg_ROBEN1 [`I(Next_Free) - 1'b1] = ROBEN1;
            Reg_ROBEN2 [`I(Next_Free) - 1'b1] = ROBEN2;
            Reg_ROBEN1_VAL [`I(Next_Free) - 1'b1] = ROBEN1_VAL;
            Reg_ROBEN2_VAL [`I(Next_Free) - 1'b1] = ROBEN2_VAL;
`endif
            Reg_Immediate [`I(Next_Free) - 1'b1] = Immediate;
        end
    end
end

/*
this block does the following:
    - monitors the CDB to see if there is a match with RS ID that they are waiting for and take their value to be ready
*/
reg [4:0] j;
always@(posedge clk) begin

    for (j = 0; j < 16; j = j + 1) begin
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



/*
this block does the following:
    - if the FU is free it picks a ready instruction to execute it and once finish it releases the reserved entry by resetting the busy bit
*/
reg [4:0] k;
always@(negedge clk, posedge rst) begin
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
        for (k = 0; k < 16; k = k + 1) begin
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

always@(posedge clk) begin
    if (RS_FU_RS_ID != 0) begin
        Reg_Busy[`I(RS_FU_RS_ID) - 1'b1] <= 0;
    end
end



endmodule