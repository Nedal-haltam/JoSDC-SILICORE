



/*
inputs:
    - instruction from the InstQ
    - the effective address and the ROBEN to update the associated field
    - CDB ROBEN and ROBEN_VAL to udpate the destination value field and mark it as a finished one
outputs:
    - the head of the buffer to commit its result and go to the next one
*/
module ROB
(
    input clk, rst,
    input [11:0] Decoded_opcode,
    input [4:0] Decoded_Rd,
    input Decoded_prediction,

    input [4:0] Addr_Unit_ROBEN,
    input [31:0] Addr_Unit_Mem_Addr,

    input [4:0] CDB_ROBEN,
    input [31:0] CDB_ROBEN_Write_Data,
    input CDB_Branch_Decision,

    input VALID_Inst,
    output FULL_FLAG,
    output EXCEPTION_Flag,
    output FLUSH_Flag,

    output reg [11:0] Commit_opcode,
    output reg [4:0] Commit_Rd,
    output reg [31:0] Commit_Write_Data,
    output reg [31:0] Commit_Mem_Addr,
    output reg [2:0] Commit_Control_Signals,

    output reg [3:0] Start_Index,
    output reg [3:0] End_Index,

    input  [4:0] index_test,
    output [11:0] Reg_opcode_test,
    output [4:0]  Reg_Rd_test,
    output [31:0] Reg_Write_Data_test,
    output [31:0] Reg_Mem_Addr_test,
    output [0:0]  Reg_Busy_test,
    output [0:0]  Reg_Ready_test,
    output [1:0]  Reg_Speculation_test,
    output [0:0]  Reg_Exception_test,
    output [0:0]  Reg_Valid_test
);

`include "opcodes.txt"

reg [11:0] Reg_opcode [15:0];
reg [4:0] Reg_Rd [15:0];
reg [31:0] Reg_Write_Data [15:0];
reg [31:0] Reg_Mem_Addr [15:0];
reg Reg_Busy [15:0];
reg Reg_Ready [15:0];
reg [1:0] Reg_Speculation [15:0];
reg Reg_Exception [15:0];


wire Reg_Valid [15:0];
`define I(i) i[3:0]
`define validbit(i) assign Reg_Valid[i] = ~(Reg_Speculation[i][0] | Reg_Exception[i])
`validbit(0);
`validbit(1);
`validbit(2);
`validbit(3);
`validbit(4);
`validbit(5);
`validbit(6);
`validbit(7);
`validbit(8);
`validbit(9);
`validbit(10);
`validbit(11);
`validbit(12);
`validbit(13);
`validbit(14);
`validbit(15);


assign Reg_opcode_test = Reg_opcode[`I(index_test)];
assign Reg_Rd_test = Reg_Rd[`I(index_test)];
assign Reg_Write_Data_test = Reg_Write_Data[`I(index_test)];
assign Reg_Mem_Addr_test = Reg_Mem_Addr[`I(index_test)];
assign Reg_Busy_test = Reg_Busy[`I(index_test)];
assign Reg_Ready_test = Reg_Ready[`I(index_test)];
assign Reg_Speculation_test = Reg_Speculation[`I(index_test)];
assign Reg_Exception_test = Reg_Exception[`I(index_test)];
assign Reg_Valid_test = Reg_Valid[`I(index_test)];





/*
this block does the following:
    - it resets the necessary registers
    - inserts an entry to the ROB
*/
assign FULL_FLAG = ~(rst | ~(End_Index == Start_Index && (Reg_Busy[Start_Index])));
reg [4:0] i = 0;
always@(posedge clk, posedge rst) begin
    if (rst) begin
        for (i = 0; i < 16; i = i + 1) begin
            Reg_Busy[`I(i)] = 0;
            Reg_Ready[`I(i)] = 0;
            Reg_Speculation[`I(i)] = 0;
            Reg_Exception[`I(i)] = 0;
        end
        End_Index = 0;
    end
    else if (VALID_Inst && ~FULL_FLAG) begin
        Reg_opcode[End_Index] = Decoded_opcode;
        Reg_Rd[End_Index] = Decoded_Rd;
        Reg_Busy[End_Index] = 1'b1;
        Reg_Ready[End_Index] = 1'b0;
        Reg_Speculation[End_Index][0] = (Decoded_opcode == beq || Decoded_opcode == bne);
        Reg_Speculation[End_Index][1] = Decoded_prediction;
        Reg_Exception[End_Index] = 1'b0;
        End_Index = End_Index + 1'b1;
    end
end

always@(posedge clk) begin
    if (Reg_Busy[`I(CDB_ROBEN) - 1'b1] && CDB_ROBEN != 0) begin
        if (Reg_opcode[`I(CDB_ROBEN) - 1'b1] == sw) begin
            Reg_Write_Data[`I(CDB_ROBEN) - 1'b1] = CDB_ROBEN_Write_Data;
            Reg_Speculation[`I(CDB_ROBEN) - 1'b1][0] = Reg_Speculation[`I(CDB_ROBEN) - 1'b1][0] & 
                                                    CDB_Branch_Decision ^ Reg_Speculation[`I(CDB_ROBEN) - 1'b1][1];
            Reg_Ready[`I(CDB_ROBEN) - 1'b1] = Reg_Speculation[`I(CDB_ROBEN) - 1'b1][1];
            Reg_Speculation[`I(CDB_ROBEN) - 1'b1][1] = 1'b1;
        end
        else begin
            Reg_Write_Data[`I(CDB_ROBEN) - 1'b1] = CDB_ROBEN_Write_Data;
            Reg_Speculation[`I(CDB_ROBEN) - 1'b1][0] = Reg_Speculation[`I(CDB_ROBEN) - 1'b1][0] & 
                                                    CDB_Branch_Decision ^ Reg_Speculation[`I(CDB_ROBEN) - 1'b1][1];
            Reg_Ready[`I(CDB_ROBEN) - 1'b1] = 1'b1;
        end
    end
    
end
always@(posedge clk) begin
    if (Reg_opcode[`I(Addr_Unit_ROBEN) - 1'b1] == lw || Reg_opcode[`I(Addr_Unit_ROBEN) - 1'b1] == sw) begin 
        if (Reg_Busy[`I(Addr_Unit_ROBEN) - 1'b1] && Addr_Unit_ROBEN != 0) begin
            Reg_Mem_Addr[`I(Addr_Unit_ROBEN) - 1'b1] = Addr_Unit_Mem_Addr;
            // (ready when (address forwarded to the ROB entry and data to write on the memory is determined using the previous block))
            // (ready when (data read from the memory is broadcasted on the CDB (here the address is implicitly computed in the address unit in the load buffer)))
            Reg_Ready[`I(Addr_Unit_ROBEN) - 1'b1] = Reg_Speculation[`I(Addr_Unit_ROBEN) - 1'b1][1];
            Reg_Speculation[`I(Addr_Unit_ROBEN) - 1'b1][1] = 1'b1;
        end
    end
end


assign EXCEPTION_Flag = Reg_Busy[Start_Index] & Reg_Exception[Start_Index];
assign FLUSH_Flag = Reg_Busy[Start_Index] & Reg_Speculation[Start_Index][0] & Reg_Ready[Start_Index];
reg [4:0] k = 0;
always@(posedge clk, posedge rst) begin
    if (rst)
        Start_Index = 0;

    Commit_opcode = 0;
    Commit_Rd = 0;
    Commit_Write_Data = 0;
    Commit_Mem_Addr = 0;
    Commit_Control_Signals = 0;
    if (Reg_Busy[Start_Index]) begin
        if (Reg_Valid[Start_Index]) begin
            if (Reg_Ready[Start_Index]) begin
                Commit_opcode = Reg_opcode[Start_Index];
                Commit_Rd = Reg_Rd[Start_Index];
                Commit_Write_Data = Reg_Write_Data[Start_Index];
                Commit_Mem_Addr = Reg_Mem_Addr[Start_Index];
                Commit_Control_Signals = { (!(Reg_opcode[Start_Index] == jr || Reg_opcode[Start_Index] == sw || Reg_opcode[Start_Index] == beq || 
                                              Reg_opcode[Start_Index] == bne || Reg_opcode[Start_Index] == j))
                                           , Reg_opcode[Start_Index] == lw , Reg_opcode[Start_Index] == sw};
                Reg_Busy[Start_Index] = 0;
                Reg_Ready[Start_Index] = 0;
                Start_Index = Start_Index + 1'b1;
            end
        end
        else if (Reg_Speculation[Start_Index][0]) begin
            if (Reg_Ready[Start_Index]) begin
                for (k = {1'b0,Start_Index}; k < End_Index; k = k + 1) begin
                    Reg_Busy[`I(k)] = 1'b0;
                end
                Start_Index = End_Index;
            end
        end
    end
end


endmodule