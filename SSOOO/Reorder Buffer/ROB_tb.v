

`define HALF_CYCLE 1
`define ONE_CLK (2 * `HALF_CYCLE)
`define ADVANCE_N_CYCLE(N) #(`ONE_CLK * N);


`define DISPLAYVALS \
clk_en = 0; \
$display("Start_Index = %d, End_Index = %d", Start_Index, End_Index); \
#`ONE_CLK $display("RP1_ROBEN1 = %d, RP1_ROBEN2 = %d, RP1_Write_Data1 = %d, RP1_Write_Data2 = %d", \
        RP1_ROBEN1, RP1_ROBEN2, RP1_Write_Data1, RP1_Write_Data2); \
$display("FULL_FLAG = %d , EXCEPTION_Flag = %d , FLUSH_Flag = %d , Commit_opcode = %h , Commit_Rd = %d , Commit_Write_Data = %d , Commit_Control_Signals = %b", \
        FULL_FLAG, EXCEPTION_Flag, FLUSH_Flag, Commit_opcode, Commit_Rd, Commit_Write_Data, Commit_Control_Signals); \
for (i = 0; i < 16; i = i + 1) begin \
    index_test = i[4:0]; \
    #`ONE_CLK $display("index_test = %d, Reg_Busy_test = %d, Reg_opcode_test = %h, Reg_Rd_test = %d, Reg_Write_Data_test = %d, Reg_Ready_test = %d, Reg_Speculation_test = %b, Reg_Exception_test = %d, Reg_Valid_test = %d", \
        index_test, Reg_Busy_test, Reg_opcode_test, Reg_Rd_test, Reg_Write_Data_test, Reg_Ready_test, Reg_Speculation_test, Reg_Exception_test, Reg_Valid_test); \
end \
clk_en = 1; \
$display("\n\n");



`include "ROB.v"
module ROB_tb();

`include "opcodes.txt"

reg clk = 0, rst = 0;
reg [11:0] Decoded_opcode;
reg [4:0] Decoded_Rd;
reg Decoded_prediction;

reg [4:0] CDB_ROBEN;
reg [31:0] CDB_ROBEN_Write_Data;
reg CDB_Branch_Decision;

reg VALID_Inst;
wire FULL_FLAG;
wire EXCEPTION_Flag;
wire FLUSH_Flag;

wire [11:0] Commit_opcode;
wire [4:0] Commit_Rd;
wire [31:0] Commit_Write_Data;
wire [2:0] Commit_Control_Signals;

reg [4:0] RP1_ROBEN1, RP1_ROBEN2;
wire [31:0] RP1_Write_Data1, RP1_Write_Data2;
wire RP1_Ready1, RP1_Ready2;

wire [3:0] Start_Index, End_Index;

reg  [4:0] index_test;
wire [11:0] Reg_opcode_test;
wire [4:0]  Reg_Rd_test;
wire [31:0] Reg_Write_Data_test;
wire [0:0]  Reg_Busy_test;
wire [0:0]  Reg_Ready_test;
wire [1:0]  Reg_Speculation_test;
wire [0:0]  Reg_Exception_test;
wire [0:0]  Reg_Valid_test;


ROB dut
(
    .clk(clk), 
    .rst(rst),
    .Decoded_opcode(Decoded_opcode),
    .Decoded_Rd(Decoded_Rd),
    .Decoded_prediction(Decoded_prediction),

    .CDB_ROBEN(CDB_ROBEN),
    .CDB_ROBEN_Write_Data(CDB_ROBEN_Write_Data),
    .CDB_Branch_Decision(CDB_Branch_Decision),

    .VALID_Inst(VALID_Inst),
    .FULL_FLAG(FULL_FLAG),
    .EXCEPTION_Flag(EXCEPTION_Flag),
    .FLUSH_Flag(FLUSH_Flag),

    .Commit_opcode(Commit_opcode),
    .Commit_Rd(Commit_Rd),
    .Commit_Write_Data(Commit_Write_Data),
    .Commit_Control_Signals(Commit_Control_Signals),

    .RP1_ROBEN1(RP1_ROBEN1), 
    .RP1_ROBEN2(RP1_ROBEN2),
    .RP1_Write_Data1(RP1_Write_Data1), 
    .RP1_Write_Data2(RP1_Write_Data2),
    .RP1_Ready1(RP1_Ready1), 
    .RP1_Ready2(RP1_Ready2),

    .Start_Index(Start_Index),
    .End_Index(End_Index),

    .index_test(index_test),
    .Reg_opcode_test(Reg_opcode_test),
    .Reg_Rd_test(Reg_Rd_test),
    .Reg_Write_Data_test(Reg_Write_Data_test),
    .Reg_Busy_test(Reg_Busy_test),
    .Reg_Ready_test(Reg_Ready_test),
    .Reg_Speculation_test(Reg_Speculation_test),
    .Reg_Exception_test(Reg_Exception_test),
    .Reg_Valid_test(Reg_Valid_test)
);

reg clk_en = 0;
always begin
        #(`HALF_CYCLE) clk <= (~clk_en & clk) | (clk_en & ~clk);
end
integer i;
initial begin
$dumpfile("testout.vcd");
$dumpvars;

clk_en = 1;
rst = 0; `ADVANCE_N_CYCLE(1); rst = 1; `ADVANCE_N_CYCLE(1); rst = 0;
RP1_ROBEN1 = 1;
RP1_ROBEN2 = 2;

`DISPLAYVALS
Decoded_opcode = add;
Decoded_Rd = 10;
Decoded_prediction = 0;

VALID_Inst = 0;
`ADVANCE_N_CYCLE(1);
`DISPLAYVALS

VALID_Inst = 1;
`ADVANCE_N_CYCLE(1);
Decoded_Rd = 15;
`ADVANCE_N_CYCLE(1);
VALID_Inst = 0;
`DISPLAYVALS


Decoded_opcode = beq;
Decoded_Rd = 11;
Decoded_prediction = 0;

VALID_Inst = 1;
`ADVANCE_N_CYCLE(1);
VALID_Inst = 0;
`DISPLAYVALS

Decoded_opcode = bne;
Decoded_Rd = 12;
Decoded_prediction = 1;

VALID_Inst = 1;
`ADVANCE_N_CYCLE(1);
VALID_Inst = 0;
`DISPLAYVALS

// until here we have four instructions (two alu, two branches)

CDB_ROBEN = 5;
CDB_ROBEN_Write_Data = 123;
`ADVANCE_N_CYCLE(2);
`DISPLAYVALS


CDB_ROBEN = 1;
CDB_ROBEN_Write_Data = 123;
`ADVANCE_N_CYCLE(1);
`DISPLAYVALS


CDB_ROBEN = 2;
CDB_ROBEN_Write_Data = 456;
`ADVANCE_N_CYCLE(1);
CDB_ROBEN = 0;
`DISPLAYVALS


`ADVANCE_N_CYCLE(1);
`DISPLAYVALS
// at this point we have the two branches in the ROB before proceeding, lets add couple of shift instructions


Decoded_opcode = sll;
Decoded_Rd = 20;
Decoded_prediction = 0;

VALID_Inst = 1;
`ADVANCE_N_CYCLE(1);
Decoded_opcode = srl;
Decoded_Rd = 22;
`ADVANCE_N_CYCLE(1);
VALID_Inst = 0;
`DISPLAYVALS

// lets make one of them ready

CDB_ROBEN = 5;
CDB_ROBEN_Write_Data = 999;
`ADVANCE_N_CYCLE(1);
`DISPLAYVALS


// we will predict true in the first one and in the next one we will do both
CDB_ROBEN = 3;
CDB_ROBEN_Write_Data = 0;
CDB_Branch_Decision = 0; // same as the prediction, see the output
`ADVANCE_N_CYCLE(1);
CDB_ROBEN = 0;
`DISPLAYVALS

`ADVANCE_N_CYCLE(1);
`DISPLAYVALS

`ADVANCE_N_CYCLE(1);
`DISPLAYVALS


// `define flush

`ifdef flush

CDB_ROBEN = 4;
CDB_ROBEN_Write_Data = 111;
CDB_Branch_Decision = 0; // opposite of what predicted
`ADVANCE_N_CYCLE(1);
`DISPLAYVALS

`else 

CDB_ROBEN = 4;
CDB_ROBEN_Write_Data = 111;
CDB_Branch_Decision = 1;
`ADVANCE_N_CYCLE(1);
CDB_ROBEN = 0;
`DISPLAYVALS

`ADVANCE_N_CYCLE(1);
`DISPLAYVALS

CDB_ROBEN = 6;
CDB_ROBEN_Write_Data = 222; // here we make this instruction ready during the execution of the ROB
`ADVANCE_N_CYCLE(1);
CDB_ROBEN = 0;

`DISPLAYVALS


`ADVANCE_N_CYCLE(1);
`DISPLAYVALS

`ADVANCE_N_CYCLE(1);
`DISPLAYVALS


`endif


Decoded_opcode = add;
Decoded_Rd = 10;
Decoded_prediction = 0;
VALID_Inst = 1;
`ADVANCE_N_CYCLE(14);
`DISPLAYVALS

`ADVANCE_N_CYCLE(1);
`DISPLAYVALS

`ADVANCE_N_CYCLE(1);
Decoded_Rd = 13;
`DISPLAYVALS
`ADVANCE_N_CYCLE(1);
VALID_Inst = 0;
`DISPLAYVALS

for (i = 0; i < 16; i = i + 1) begin
    CDB_ROBEN = i[4:0] + 1;
    `ADVANCE_N_CYCLE(1);
end
`DISPLAYVALS

`ADVANCE_N_CYCLE(5);
`DISPLAYVALS

`ADVANCE_N_CYCLE(1);
`DISPLAYVALS

`ADVANCE_N_CYCLE(1);
`DISPLAYVALS


/*
TODO: trace the life time of the following instruction types:
    - ALU: forwarding while in the RS, getting its results while in the ROB through the CDB, committing when in at the head of the ROB
    - branch: forwarding while in the RS, deciding whether to branch or not after comparison(while in the CDB), flush decision when committing when in at the head of the ROB
    - lw : go to the address unit calculate EA and pass it to the ld/st buffer, when its ready it reads from the memory and broadcast the result on the CDB
    - sw : go to the address unit calculate EA and pass it to the ld/st buffer, when its ready it writes the value on the memory and broadcast on the CDB that it finished
    - jr : after executing in the FU, it broadcast the target address on the CDB and effects the PC_src
    - j  : it effects the PC_src in the decoding stage
    - jal: it effects the PC_src in the decoding stage, and continue the road to write the return address on $ra ($31)
    - hlt: it effects the PC_src in the decoding stage, and do nothing, when it reaches the head of the ROB it raises the hlt flag to hold the clk
*/

$finish;
end
endmodule