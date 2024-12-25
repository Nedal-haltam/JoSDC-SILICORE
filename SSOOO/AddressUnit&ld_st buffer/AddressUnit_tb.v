

`define DISPLAYVALS \
$display("VALID_Inst = %d, out_ROBEN = %d, out_Rd = %d, out_opcode = %h, out_ROBEN1 = %d, out_ROBEN2 = %d, out_ROBEN1_VAL = %d, out_ROBEN2_VAL = %d, out_Immediate = %d, out_EA = %d, out_Write_Data = %d", \
        VALID_Inst, out_ROBEN, out_Rd, out_opcode, out_ROBEN1, out_ROBEN2, out_ROBEN1_VAL, out_ROBEN2_VAL, out_Immediate, out_EA, out_Write_Data); \
$display("\n\n");

`include "AddressUnit.v"

module AddressUnit_tb();


reg [4:0]  Decoded_ROBEN; 
reg [4:0]  Decoded_Rd;
reg [11:0] Decoded_opcode; 
reg [4:0]  ROBEN1, ROBEN2; 
reg [31:0] ROBEN1_VAL, ROBEN2_VAL; 
reg [31:0] Immediate; 

wire VALID_Inst; 
wire [4:0]  out_ROBEN;
wire [4:0] out_Rd; 
wire [11:0] out_opcode; 
wire [4:0]  out_ROBEN1, out_ROBEN2; 
wire [31:0] out_ROBEN1_VAL, out_ROBEN2_VAL; 
wire [31:0] out_Immediate; 
wire [31:0] out_EA, out_Write_Data; 


AddressUnit dut
(
    .Decoded_ROBEN(Decoded_ROBEN),
    .Decoded_Rd(Decoded_Rd),
    .Decoded_opcode(Decoded_opcode),
    .ROBEN1(ROBEN1), 
    .ROBEN2(ROBEN2),
    .ROBEN1_VAL(ROBEN1_VAL), 
    .ROBEN2_VAL(ROBEN2_VAL),
    .Immediate(Immediate),



    .VALID_Inst(VALID_Inst),
    .out_ROBEN(out_ROBEN),
    .out_Rd(out_Rd),
    .out_opcode(out_opcode),
    .out_ROBEN1(out_ROBEN1), 
    .out_ROBEN2(out_ROBEN2),
    .out_ROBEN1_VAL(out_ROBEN1_VAL), 
    .out_ROBEN2_VAL(out_ROBEN2_VAL),
    .out_Immediate(out_Immediate),
    .out_EA(out_EA), 
    .out_Write_Data(out_Write_Data)
);

integer i;
initial begin
$dumpfile("testout_AddressUnit.vcd");
$dumpvars;

// Decoded_ROBEN
// ROBEN1
// ROBEN2
// ROBEN1_VAL
// ROBEN2_VAL
// Immediate



Decoded_opcode = 0;
ROBEN1_VAL = 10;
ROBEN2_VAL = 20;
Immediate = 30;
#1 `DISPLAYVALS

Decoded_opcode = `lw;
#1 `DISPLAYVALS

Decoded_opcode = 12'h020;
#1 `DISPLAYVALS

Decoded_opcode = `sw;
ROBEN1_VAL = 40;
ROBEN2_VAL = 50;
Immediate = 60;
#1 `DISPLAYVALS


end


endmodule