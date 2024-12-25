



/*
description:
    - four sources to broadcast from
        - three functional units
        - one memory unit
    - the things to broadcast are:
        - ROBEN
        - the destination register (Rd)
        - the data produced (Write_Data)
*/

module CDB
(
    inout [4:0] ROBEN1,
    inout [4:0] Rd1,
    inout [31:0] Write_Data1,

    inout [4:0] ROBEN2,
    inout [4:0] Rd2,
    inout [31:0] Write_Data2,

    inout [4:0] ROBEN3,
    inout [4:0] Rd3,
    inout [31:0] Write_Data3,

    inout [4:0] ROBEN4,
    inout [4:0] Rd4,
    inout [31:0] Write_Data4
);


endmodule