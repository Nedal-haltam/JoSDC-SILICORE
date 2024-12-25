

`define DISPLAYVALS \
clk_en = 0; \
$display(""); \
for (i = 0; i < 16; i = i + 1) begin \
    index_test = i[4:0]; \
    #`ONE_CLK $display(""); \
end \
clk_en = 1; \
$display("\n\n");



`include "CDB.v"
module CDB_tb();

wire [4:0] ROBEN1;
wire [4:0] Rd1;
wire [31:0] Write_Data1;
wire [4:0] ROBEN2;
wire [4:0] Rd2;
wire [31:0] Write_Data2;
wire [4:0] ROBEN3;
wire [4:0] Rd3;
wire [31:0] Write_Data3;
wire [4:0] ROBEN4;
wire [4:0] Rd4;
wire [31:0] Write_Data4;

CDB dut
(
    .ROBEN1(ROBEN1),
    .Rd1(Rd1),
    .Write_Data1(Write_Data1),

    .ROBEN2(ROBEN2),
    .Rd2(Rd2),
    .Write_Data2(Write_Data2),

    .ROBEN3(ROBEN3),
    .Rd3(Rd3),
    .Write_Data3(Write_Data3),

    .ROBEN4(ROBEN4),
    .Rd4(Rd4),
    .Write_Data4(Write_Data4)
);

assign ROBEN1 = 25;
assign Rd1 = 25;
assign Write_Data1 = 25;
assign ROBEN2 = 25;
assign Rd2 = 25;
assign Write_Data2 = 25;
assign ROBEN3 = 25;
assign Rd3 = 25;
assign Write_Data3 = 25;
assign ROBEN4 = 25;
assign Rd4 = 25;
assign Write_Data4 = 25;

initial begin
$dumpfile("testout.vcd");
$dumpvars;



#1 $display("ROBEN1 = %d, Rd1 = %d, Write_Data1 = %d, ROBEN2 = %d, Rd2 = %d, Write_Data2 = %d, ROBEN3 = %d, Rd3 = %d, Write_Data3 = %d, ROBEN4 = %d, Rd4 = %d, Write_Data4 = %d",
        ROBEN1, Rd1, Write_Data1, ROBEN2, Rd2, Write_Data2, ROBEN3, Rd3, Write_Data3, ROBEN4, Rd4, Write_Data4);


$finish;
end
endmodule