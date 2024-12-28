



/*
description:
    - four sources to broadcast from
        - three functional units
        - one memory unit
    - the things to broadcast are:
        - ROBEN
        - the data produced (Write_Data)
*/

module CDB
(
    input [4:0] ROBEN1,
    input [31:0] Write_Data1,

    input [4:0] ROBEN2,
    input [31:0] Write_Data2,

    input [4:0] ROBEN3,
    input [31:0] Write_Data3,

    input [4:0] ROBEN4,
    input [31:0] Write_Data4,


    output [4:0] out_ROBEN1,
    output [31:0] out_Write_Data1,

    output [4:0] out_ROBEN2,
    output [31:0] out_Write_Data2,

    output [4:0] out_ROBEN3,
    output [31:0] out_Write_Data3,

    output [4:0] out_ROBEN4,
    output [31:0] out_Write_Data4
);


assign out_ROBEN1 = ROBEN1;
assign out_Write_Data1 = Write_Data1;

assign out_ROBEN2 = ROBEN2;
assign out_Write_Data2 = Write_Data2;

assign out_ROBEN3 = ROBEN3;
assign out_Write_Data3 = Write_Data3;

assign out_ROBEN4 = ROBEN4;
assign out_Write_Data4 = Write_Data4;



endmodule