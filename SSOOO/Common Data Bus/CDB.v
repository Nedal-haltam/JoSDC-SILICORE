



/*
description:
    - four sources to broadcast from
        - three functional units
        - one memory unit
    - the things to broadcast are:
        - ROBEN
        - the data produced (Write_Data)
*/
`define MEMORY_SIZE 2048
`define MEMORY_BITS 11
`define ROB_SIZE_bits (4)
`define BUFFER_SIZE_bitslsbuffer (4)
`define BUFFER_SIZE_bitsRS (4)
`define ROB_SIZE ((1 << `ROB_SIZE_bits))

module CDB
(
    input [`ROB_SIZE_bits:0] ROBEN1,
    input [31:0] Write_Data1,
    input EXCEPTION1,

    input [`ROB_SIZE_bits:0] ROBEN2,
    input [31:0] Write_Data2,
    input EXCEPTION2,

    input [`ROB_SIZE_bits:0] ROBEN3,
    input [31:0] Write_Data3,
    input EXCEPTION3,

    input [`ROB_SIZE_bits:0] ROBEN4,
    input [31:0] Write_Data4,
    input EXCEPTION4,


    output [`ROB_SIZE_bits:0] out_ROBEN1,
    output [31:0] out_Write_Data1,
    output out_EXCEPTION1,

    output [`ROB_SIZE_bits:0] out_ROBEN2,
    output [31:0] out_Write_Data2,
    output out_EXCEPTION2,

    output [`ROB_SIZE_bits:0] out_ROBEN3,
    output [31:0] out_Write_Data3,
    output out_EXCEPTION3,

    output [`ROB_SIZE_bits:0] out_ROBEN4,
    output [31:0] out_Write_Data4,
    output out_EXCEPTION4
);


assign out_ROBEN1 = ROBEN1;
assign out_Write_Data1 = Write_Data1;
assign out_EXCEPTION1 = EXCEPTION1;

assign out_ROBEN2 = ROBEN2;
assign out_Write_Data2 = Write_Data2;
assign out_EXCEPTION2 = EXCEPTION2;

assign out_ROBEN3 = ROBEN3;
assign out_Write_Data3 = Write_Data3;
assign out_EXCEPTION3 = EXCEPTION3;

assign out_ROBEN4 = ROBEN4;
assign out_Write_Data4 = Write_Data4;
assign out_EXCEPTION4 = EXCEPTION4;



endmodule