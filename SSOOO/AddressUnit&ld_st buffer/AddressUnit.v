


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

`define MEMORY_SIZE 2048
`define MEMORY_BITS 11
`define ROB_SIZE_bits (4)
`define BUFFER_SIZE_bitslsbuffer (4)
`define BUFFER_SIZE_bitsRS (4)
`define ROB_SIZE ((1 << `ROB_SIZE_bits))


module AddressUnit
(
    input [`ROB_SIZE_bits:0]  Decoded_ROBEN,
    input [4:0] Decoded_Rd,
    input [11:0] Decoded_opcode,
    input [`ROB_SIZE_bits:0]  ROBEN1, ROBEN2,
    input [31:0] ROBEN1_VAL, ROBEN2_VAL,
    input [31:0] Immediate,
    input InstQ_VALID_Inst,


    output AU_LdStB_VALID_Inst,
    output [`ROB_SIZE_bits:0]  AU_LdStB_ROBEN,
    output [4:0]  AU_LdStB_Rd,
    output [11:0] AU_LdStB_opcode,
    output [`ROB_SIZE_bits:0]  AU_LdStB_ROBEN1, AU_LdStB_ROBEN2,
    output [31:0] AU_LdStB_ROBEN1_VAL, AU_LdStB_ROBEN2_VAL,
    output [31:0] AU_LdStB_Immediate
);



assign AU_LdStB_VALID_Inst = (Decoded_opcode == `lw || Decoded_opcode == `sw) && InstQ_VALID_Inst;
assign AU_LdStB_ROBEN = Decoded_ROBEN;
assign AU_LdStB_Rd = Decoded_Rd;
assign AU_LdStB_opcode = Decoded_opcode;
assign AU_LdStB_ROBEN1 = ROBEN1;
assign AU_LdStB_ROBEN2 = ROBEN2;
assign AU_LdStB_ROBEN1_VAL = ROBEN1_VAL;
assign AU_LdStB_ROBEN2_VAL = ROBEN2_VAL;
assign AU_LdStB_Immediate = Immediate;

endmodule
