
`define HALF_CYCLE 1
`define ONE_CLK (2 * `HALF_CYCLE)
`define ADVANCE_N_CYCLE(N) #(`ONE_CLK * N);

`define DISPLAYVALS \
$display("full = %b , valid = %b", FULL_FLAG, VALID_Inst); \
clk_en = 0; \
for (i = 0; i < 16; i = i + 1) begin \
    input_index_test = i[4:0]; \
    #`ONE_CLK $display("index %d: busy = %b , opcode = %d , ALUOP = %d , ROBEN1 = %d , ROBEN1_VAL = %d , ROBEN2 = %d , ROBEN2_VAL = %d , Immediate = %d", \
    input_index_test, busy_test, opcode_test, ALUOP_test, ROBEN1_test, ROBEN1_VAL_test, ROBEN2_test, ROBEN2_VAL_test, Immediate_test); \
end \
$display("FU_Is_Free = %b", FU_Is_Free); \
$display("FU_RS_ID = %d , FU_ALUOP = %d , FU_VAL1 = %d , FU_VAL2 = %d , FU_Immediate = %d\n", FU_RS_ID, FU_ALUOP, FU_Val1, FU_Val2, FU_Immediate); \
clk_en = 1;



`include "RS.v"

module RS_tb();


reg clk = 0, rst;
reg [11:0] opcode;
reg [3:0] ALUOP;
reg [4:0] ROBEN1, ROBEN2;
reg [31:0] ROBEN1_VAL, ROBEN2_VAL;
reg [31:0] Immediate;
reg [4:0] CDB_ROBEN;
reg [31:0] CDB_ROBEN_VAL;

reg VALID_Inst;
reg FU_Is_Free;

wire FULL_FLAG;
wire [4:0] FU_RS_ID;
wire [3:0] FU_ALUOP;
wire [31:0] FU_Val1, FU_Val2;
wire [31:0] FU_Immediate;


reg  [4:0] input_index_test;
wire [11:0] opcode_test;
wire [3:0] ALUOP_test;
wire [4:0] ROBEN1_test, ROBEN2_test;
wire [31:0] ROBEN1_VAL_test, ROBEN2_VAL_test;
wire [31:0] Immediate_test;
wire busy_test;

RS dut
(
    .clk(clk), 
    .rst(rst),
    .opcode(opcode),
    .ALUOP(ALUOP), 
    .ROBEN1(ROBEN1), 
    .ROBEN2(ROBEN2),
    .ROBEN1_VAL(ROBEN1_VAL), 
    .ROBEN2_VAL(ROBEN2_VAL),
    .Immediate(Immediate),
    .CDB_ROBEN(CDB_ROBEN),
    .CDB_ROBEN_VAL(CDB_ROBEN_VAL),
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
    .ROBEN1_test(ROBEN1_test), 
    .ROBEN2_test(ROBEN2_test),
    .ROBEN1_VAL_test(ROBEN1_VAL_test), 
    .ROBEN2_VAL_test(ROBEN2_VAL_test),
    .Immediate_test(Immediate_test),
    .busy_test(busy_test)

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
FU_Is_Free = 0;
rst = 0; `ADVANCE_N_CYCLE(1); rst = 1; `ADVANCE_N_CYCLE(1); rst = 0;


opcode = 1;
ALUOP = 2;
ROBEN1 = 3;
ROBEN2 = 4;
ROBEN1_VAL = 5;
ROBEN2_VAL = 6;
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
ROBEN1 = 3 + 2;
ROBEN2 = 4 + 2;
ROBEN1_VAL = 5 + 10;
ROBEN2_VAL = 6 + 10;
Immediate = 77 + 10;
`ADVANCE_N_CYCLE(1);
// `DISPLAYVALS
// adding another instruction
VALID_Inst = 1;
`ADVANCE_N_CYCLE(1);
VALID_Inst = 0;
// `DISPLAYVALS

// // this is for testing the full flag, and it works
// opcode = 888;
// VALID_Inst = 1;
// `ADVANCE_N_CYCLE(14);
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

CDB_ROBEN = 5;
CDB_ROBEN_VAL = 123;
`ADVANCE_N_CYCLE(1);
CDB_ROBEN = 6;
CDB_ROBEN_VAL = 456;

FU_Is_Free = 0;
`ADVANCE_N_CYCLE(1);
`DISPLAYVALS

FU_Is_Free = 1;
`ADVANCE_N_CYCLE(1);
`DISPLAYVALS


FU_Is_Free = 0;
CDB_ROBEN = 3;
CDB_ROBEN_VAL = 789;
`ADVANCE_N_CYCLE(1);
`DISPLAYVALS

CDB_ROBEN = 4;
CDB_ROBEN_VAL = 999;
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
ROBEN1 = 0;
ROBEN2 = 0;
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


