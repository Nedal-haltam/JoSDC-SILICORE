
`define HALF_CYCLE 1
`define ONE_CLK (2 * `HALF_CYCLE)
`define ADVANCE_N_CYCLE(N) #(`ONE_CLK * N);

`define DISPLAYVALS \
$display("full = %b , valid = %b", FULL_FLAG, VALID_Inst); \
for (i = 0; i < 8; i = i + 1) begin \
    input_index_test = i[3:0]; \
    #`ONE_CLK $display("index %d: busy = %b , opcode = %d , ALUOP = %d , RS_ID1 = %d , RS_ID1_VAL = %d , RS_ID2 = %d , RS_ID2_VAL = %d , Immediate = %d", \
    input_index_test, busy_test, opcode_test, ALUOP_test, RS_ID1_test, RS_ID1_VAL_test, RS_ID2_test, RS_ID2_VAL_test, Immediate_test); \
end \
$display("FU_Is_Free = %b", FU_Is_Free); \
$display("FU_RS_ID = %d , FU_ALUOP = %d , FU_VAL1 = %d , FU_VAL2 = %d , FU_Immediate = %d\n", FU_RS_ID, FU_ALUOP, FU_Val1, FU_Val2, FU_Immediate);



`include "RS.v"

module RS_tb();


reg clk = 0, rst;
reg [11:0] opcode;
reg [3:0] ALUOP;
reg [2:0] RS_ID1, RS_ID2;
reg [31:0] RS_ID1_VAL, RS_ID2_VAL;
reg [31:0] Immediate;
reg [2:0] CDB_RS_ID;
reg [31:0] CDB_RS_ID_VAL;

reg VALID_Inst;
reg FU_Is_Free;

wire FULL_FLAG;
wire [3:0] FU_RS_ID;
wire [3:0] FU_ALUOP;
wire [31:0] FU_Val1, FU_Val2;
wire [31:0] FU_Immediate;


reg [3:0] input_index_test;
wire [11:0] opcode_test;
wire [3:0] ALUOP_test;
wire [2:0] RS_ID1_test, RS_ID2_test;
wire [31:0] RS_ID1_VAL_test, RS_ID2_VAL_test;
wire [31:0] Immediate_test;
wire busy_test;

RS dut
(
    .clk(clk), 
    .rst(rst),
    .opcode(opcode),
    .ALUOP(ALUOP), 
    .RS_ID1(RS_ID1), 
    .RS_ID2(RS_ID2),
    .RS_ID1_VAL(RS_ID1_VAL), 
    .RS_ID2_VAL(RS_ID2_VAL),
    .Immediate(Immediate),
    .CDB_RS_ID(CDB_RS_ID),
    .CDB_RS_ID_VAL(CDB_RS_ID_VAL),
    .VALID_Inst(VALID_Inst),
    .FU_Is_Free(FU_Is_Free),
    .FULL_FLAG(FULL_FLAG),
    .FU_RS_ID(FU_RS_ID),
    .FU_ALUOP(FU_ALUOP),
    .FU_Val1(FU_Val1), 
    .FU_Val2(FU_Val2),
    .FU_Immediate(FU_Immediate),

    .input_index_test(input_index_test),
    .opcode_test(opcode_test),
    .ALUOP_test(ALUOP_test), 
    .RS_ID1_test(RS_ID1_test), 
    .RS_ID2_test(RS_ID2_test),
    .RS_ID1_VAL_test(RS_ID1_VAL_test), 
    .RS_ID2_VAL_test(RS_ID2_VAL_test),
    .Immediate_test(Immediate_test),
    .busy_test(busy_test)

);


always #(`HALF_CYCLE) clk <= ~clk;
integer i;
initial begin
$dumpfile("testout.vcd");
$dumpvars;
FU_Is_Free = 0;
rst = 0; `ADVANCE_N_CYCLE(1); rst = 1; `ADVANCE_N_CYCLE(1); rst = 0;


opcode = 1;
ALUOP = 2;
RS_ID1 = 3;
RS_ID2 = 4;
RS_ID1_VAL = 5;
RS_ID2_VAL = 6;
Immediate = 77;
// adding an invalid instruction
VALID_Inst = 0;
`ADVANCE_N_CYCLE(1);
// `DISPLAYVALS
// adding a valid instruction
VALID_Inst = 1;
`ADVANCE_N_CYCLE(1);
VALID_Inst = 0;
// `DISPLAYVALS
opcode = 1 + 10;
ALUOP = 2 + 10;
RS_ID1 = 3 + 2;
RS_ID2 = 4 + 2;
RS_ID1_VAL = 5 + 10;
RS_ID2_VAL = 6 + 10;
Immediate = 77 + 10;
`ADVANCE_N_CYCLE(1);
// `DISPLAYVALS
// adding another instruction
VALID_Inst = 1;
`ADVANCE_N_CYCLE(1);
VALID_Inst = 0;
`DISPLAYVALS

// this is for testing the full flag, and it works
// opcode = 888;
// VALID_Inst = 1;
// `ADVANCE_N_CYCLE(6);
// VALID_Inst = 0;
// `DISPLAYVALS
// opcode = 999;
// VALID_Inst = 1;
// `ADVANCE_N_CYCLE(1);
// VALID_Inst = 0;
// `DISPLAYVALS
// $finish;

// here we have two instructions waiting for there operands
FU_Is_Free = 0;
`ADVANCE_N_CYCLE(1);
`DISPLAYVALS

FU_Is_Free = 1;
`ADVANCE_N_CYCLE(1);
`DISPLAYVALS

CDB_RS_ID = 5;
CDB_RS_ID_VAL = 123;
`ADVANCE_N_CYCLE(1);
CDB_RS_ID = 6;
CDB_RS_ID_VAL = 456;

FU_Is_Free = 0;
`ADVANCE_N_CYCLE(1);
`DISPLAYVALS

FU_Is_Free = 1;
`ADVANCE_N_CYCLE(1);
`DISPLAYVALS


FU_Is_Free = 0;
CDB_RS_ID = 3;
CDB_RS_ID_VAL = 789;
`ADVANCE_N_CYCLE(1);
`DISPLAYVALS

CDB_RS_ID = 4;
CDB_RS_ID_VAL = 999;
`ADVANCE_N_CYCLE(1);
`DISPLAYVALS


FU_Is_Free = 1;
`ADVANCE_N_CYCLE(1);
`DISPLAYVALS

FU_Is_Free = 0;
`ADVANCE_N_CYCLE(1);
`DISPLAYVALS

$display("Now we want to enter a new instruction after executing it---------------------------------------------------------------------");
opcode = 888;
RS_ID1 = 0;
RS_ID2 = 0;
`ADVANCE_N_CYCLE(1);
`DISPLAYVALS

VALID_Inst = 1;
`ADVANCE_N_CYCLE(1);
VALID_Inst = 0;
`DISPLAYVALS

FU_Is_Free = 1;
`ADVANCE_N_CYCLE(1);
`DISPLAYVALS


$finish;
end




endmodule


