

`define HALF_CYCLE 1
`define ONE_CLK (2 * `HALF_CYCLE)
`define ADVANCE_N_CYCLE(N) #(`ONE_CLK * N);


`define DISPLAYVALS \
clk_en = 0; \
$display("Start_Index = %d, End_Index = %d", Start_Index, End_Index); \
$display("out_VALID_Inst = %d, out_ROBEN = %d, out_Rd = %d, out_opcode = %d, out_ROBEN1 = %d,  out_ROBEN2 = %d, out_ROBEN1_VAL = %d,  out_ROBEN2_VAL = %d, out_Immediate = %d, out_EA = %d,\nout_Write_Data = %d\n", \
        out_VALID_Inst, out_ROBEN, out_Rd, out_opcode, out_ROBEN1,  out_ROBEN2, out_ROBEN1_VAL,  out_ROBEN2_VAL, out_Immediate, out_EA, out_Write_Data); \
for (i = 0; i < 16; i = i + 1) begin \
    index_test = i[4:0]; \
    #`ONE_CLK $display("%-20s = %-4d\n%-20s = %-4d, %-20s = %-4d, %-20s = %-4h, %-20s = %-4d, %-20s = %-4d, %-20s = %-4d, \n%-20s = %-4d, %-20s = %-4d, %-20s = %-4d, %-20s = %-4d, %-20s = %-4d, %-20s = %-4d\n", \
    "index_test", index_test, "Reg_Busy_test", Reg_Busy_test, "Reg_Ready_test", Reg_Ready_test, "Reg_opcode_test", Reg_opcode_test, "Reg_Rd_test", Reg_Rd_test, "Reg_Write_Data_test", Reg_Write_Data_test, \
    "Reg_EA_test", Reg_EA_test, "Reg_ROBEN_test", Reg_ROBEN_test, "Reg_ROBEN1_test", Reg_ROBEN1_test, "Reg_ROBEN2_test", Reg_ROBEN2_test, "Reg_ROBEN1_VAL_test", Reg_ROBEN1_VAL_test, \
    "Reg_ROBEN2_VAL_test", Reg_ROBEN2_VAL_test, "Reg_Immediate_test", Reg_Immediate_test); \
end \
clk_en = 1; \
$display("\n\n");


`include "LdStBuffer.v"

module LoadBuffer_tb();



reg clk = 0, rst;
reg VALID_Inst;
reg [4:0]  ROBEN;
reg [4:0]  Rd;
reg [11:0] opcode;
reg [4:0]  ROBEN1, ROBEN2;
reg [31:0] ROBEN1_VAL, ROBEN2_VAL;
reg [31:0] Immediate;
reg [31:0] EA, Write_Data;
reg [4:0] CDB_ROBEN;
reg [31:0] CDB_ROBEN_VAL;


wire out_VALID_Inst;
wire [4:0]  out_ROBEN;
wire [4:0]  out_Rd;
wire [11:0] out_opcode;
wire [4:0]  out_ROBEN1, out_ROBEN2;
wire [31:0] out_ROBEN1_VAL, out_ROBEN2_VAL;
wire [31:0] out_Immediate;
wire [31:0] out_EA, out_Write_Data;

wire [3:0] Start_Index;
wire [3:0] End_Index;

reg  [4:0] index_test;
wire Reg_Busy_test;
wire Reg_Ready_test;
wire [11:0] Reg_opcode_test;
wire [4:0] Reg_Rd_test;
wire [31:0] Reg_Write_Data_test;
wire [31:0] Reg_EA_test;
wire [4:0] Reg_ROBEN_test;
wire [4:0] Reg_ROBEN1_test;
wire [4:0] Reg_ROBEN2_test;
wire [31:0] Reg_ROBEN1_VAL_test;
wire [31:0] Reg_ROBEN2_VAL_test;
wire [31:0] Reg_Immediate_test;




LdStBuffer dut
(
        .clk(clk), 
        .rst(rst),
        .VALID_Inst(VALID_Inst),
        .ROBEN(ROBEN),
        .Rd(Rd),
        .opcode(opcode),
        .ROBEN1(ROBEN1), 
        .ROBEN2(ROBEN2),
        .ROBEN1_VAL(ROBEN1_VAL), 
        .ROBEN2_VAL(ROBEN2_VAL),
        .Immediate(Immediate),
        .EA(EA), 
        .Write_Data(Write_Data),

        .CDB_ROBEN(CDB_ROBEN),
        .CDB_ROBEN_VAL(CDB_ROBEN_VAL),

        .out_VALID_Inst(out_VALID_Inst),
        .out_ROBEN(out_ROBEN),
        .out_Rd(out_Rd),
        .out_opcode(out_opcode),
        .out_ROBEN1(out_ROBEN1), 
        .out_ROBEN2(out_ROBEN2),
        .out_ROBEN1_VAL(out_ROBEN1_VAL), 
        .out_ROBEN2_VAL(out_ROBEN2_VAL),
        .out_Immediate(out_Immediate),
        .out_EA(out_EA), 
        .out_Write_Data(out_Write_Data),

        .Start_Index(Start_Index),
        .End_Index(End_Index),

        .index_test(index_test),    
        .Reg_Busy_test(Reg_Busy_test),
        .Reg_Ready_test(Reg_Ready_test),
        .Reg_opcode_test(Reg_opcode_test),
        .Reg_Rd_test(Reg_Rd_test),
        .Reg_Write_Data_test(Reg_Write_Data_test),
        .Reg_EA_test(Reg_EA_test),
        .Reg_ROBEN_test(Reg_ROBEN_test),
        .Reg_ROBEN1_test(Reg_ROBEN1_test),
        .Reg_ROBEN2_test(Reg_ROBEN2_test),
        .Reg_ROBEN1_VAL_test(Reg_ROBEN1_VAL_test),
        .Reg_ROBEN2_VAL_test(Reg_ROBEN2_VAL_test),
        .Reg_Immediate_test(Reg_Immediate_test)
);


reg clk_en = 0;
always begin
        #(`HALF_CYCLE) clk <= (~clk_en & clk) | (clk_en & ~clk);
end
integer i;
initial begin
$dumpfile("testout_LdStBuffer.vcd");
$dumpvars;

clk_en = 1;
rst = 0; `ADVANCE_N_CYCLE(1); rst = 1; `ADVANCE_N_CYCLE(1); rst = 0;

`DISPLAYVALS
// TODO: test it

$finish;

end


endmodule