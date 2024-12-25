


`define lw 12'h8C0
`define sw 12'hAC0

/*
inputs:
    - ROBEN of the ld/st inst
    - ROBEN for the registers we need in order to continue (maximum 2 registers)
    - value of these registers
    - immediate field for EA calculation
    - if the register needed for EA calculation is available we calculate and pass the info to the ld/st buffer else we 
outputs:
    - ROBEN of the ld/st inst
    - ROBENs for the registers (non-zero if not available else zero)
    - value of these registers if available
    - immediate field for EA calculation
    - busy bit and ready bit is needed in the ld/st buffer
*/
module AddressUnit
(
    input [4:0]  Decoded_ROBEN,
    input [4:0] Decoded_Rd,
    input [11:0] Decoded_opcode,
    input [4:0]  ROBEN1, ROBEN2,
    input [31:0] ROBEN1_VAL, ROBEN2_VAL,
    input [31:0] Immediate,



    output VALID_Inst,
    output [4:0]  out_ROBEN,
    output [4:0]  out_Rd,
    output [11:0] out_opcode,
    output [4:0]  out_ROBEN1, out_ROBEN2,
    output [31:0] out_ROBEN1_VAL, out_ROBEN2_VAL,
    output [31:0] out_Immediate,
    output [31:0] out_EA, out_Write_Data
);



assign VALID_Inst = Decoded_opcode == `lw || Decoded_opcode == `sw;

assign out_EA = ROBEN1_VAL + Immediate;
assign out_Write_Data = ROBEN2_VAL;            

assign out_ROBEN = Decoded_ROBEN;
assign out_Rd = Decoded_Rd;
assign out_opcode = Decoded_opcode;
assign out_ROBEN1 = ROBEN1;
assign out_ROBEN2 = ROBEN2;
assign out_ROBEN1_VAL = ROBEN1_VAL;
assign out_ROBEN2_VAL = ROBEN2_VAL;
assign out_Immediate = Immediate;



endmodule