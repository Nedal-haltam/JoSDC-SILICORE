


module SSOOO_CPU
(
    input input_clk, rst,
    output reg [31:0] cycles_consumed
);

`include "opcodes.txt"

wire [31:0] PC, PC_out, Branch_Target_Addr;
wire PC_src, clk;
// InstQ
wire [ 11:0] InstQ_opcode;
wire [3:0] InstQ_ALUOP;
wire [ 4:0] InstQ_rs, InstQ_rt, InstQ_rd, InstQ_shamt;
wire [15:0] InstQ_immediate;
wire [25:0] InstQ_address;
wire [31:0] InstQ_PC;
wire InstQ_VALID_Inst;
wire InstQ_FLUSH_Flag;


// RegFile
wire [31:0] RegFile_RP1_Reg1, RegFile_RP1_Reg2;
wire [4:0] RegFile_RP1_Reg1_ROBEN, RegFile_RP1_Reg2_ROBEN;

// BPU
wire [11:0] Decoded_opcode, Commit_opcode;
wire [1:0] state;  // 2-bit state (00 NT | 01 NT | 10 T | 11 T)
wire predicted; // prediction (1 = taken, 0 = not taken)

// ROB
wire ROB_FULL_FLAG;
wire ROB_EXCEPTION_Flag;
wire ROB_FLUSH_Flag;
wire ROB_Wrong_prediction;
wire [11:0] ROB_Commit_opcode;
wire [31:0] ROB_Commit_pc;
wire [4:0] ROB_Commit_Rd;
wire [31:0] ROB_Commit_Write_Data;
wire [2:0] ROB_Commit_Control_Signals;
wire [4:0] ROB_Start_Index;
wire [4:0] ROB_End_Index;
wire [31:0] ROB_RP1_Write_Data1, ROB_RP1_Write_Data2;
wire ROB_RP1_Ready1, ROB_RP1_Ready2;

// RS
wire RS_FULL_FLAG;
wire [4:0] RS_FU_RS_ID1, RS_FU_ROBEN1;
wire [11:0] RS_FU_opcode1;
wire [3:0] RS_FU_ALUOP1;
wire [31:0] RS_FU_Val11, RS_FU_Val21;
wire [31:0] RS_FU_Immediate1;

wire [4:0] RS_FU_RS_ID2, RS_FU_ROBEN2;
wire [11:0] RS_FU_opcode2;
wire [3:0] RS_FU_ALUOP2;
wire [31:0] RS_FU_Val12, RS_FU_Val22;
wire [31:0] RS_FU_Immediate2;

wire [4:0] RS_FU_RS_ID3, RS_FU_ROBEN3;
wire [11:0] RS_FU_opcode3;
wire [3:0] RS_FU_ALUOP3;
wire [31:0] RS_FU_Val13, RS_FU_Val23;
wire [31:0] RS_FU_Immediate3;

// FU
wire [31:0] FU_Result1;
wire [4:0] FU_ROBEN1;
wire [11:0] FU_opcode1;
wire FU_Branch_Decision1;

wire [31:0] FU_Result2;
wire [4:0] FU_ROBEN2;
wire [11:0] FU_opcode2;
wire FU_Branch_Decision2;

wire [31:0] FU_Result3;
wire [4:0] FU_ROBEN3;
wire [11:0] FU_opcode3;
wire FU_Branch_Decision3;


wire FU_Is_Free;

// Address Unit
wire AU_LdStB_VALID_Inst;
wire [4:0]  AU_LdStB_ROBEN;
wire [4:0]  AU_LdStB_Rd;
wire [11:0] AU_LdStB_opcode;
wire [4:0]  AU_LdStB_ROBEN1, AU_LdStB_ROBEN2;
wire [31:0] AU_LdStB_ROBEN1_VAL, AU_LdStB_ROBEN2_VAL;
wire [31:0] AU_LdStB_Immediate;
wire [31:0] AU_LdStB_EA, AU_LdStB_Write_Data;

// Load Store Buffer
wire LdStB_MEMU_VALID_Inst;
wire LdStB_FULL_FLAG;
wire [4:0]  LdStB_MEMU_ROBEN;
wire [4:0]  LdStB_MEMU_Rd;
wire [11:0] LdStB_MEMU_opcode;
wire [4:0]  LdStB_MEMU_ROBEN1, LdStB_MEMU_ROBEN2;
wire [31:0] LdStB_MEMU_ROBEN1_VAL, LdStB_MEMU_ROBEN2_VAL;
wire [31:0] LdStB_MEMU_Immediate;
wire [31:0] LdStB_MEMU_EA, LdStB_MEMU_Write_Data;
wire [2:0] LdStB_Start_Index;
wire [2:0] LdStB_End_Index;

// Memory Unit
wire [4:0] MEMU_ROBEN;
wire [31:0] MEMU_Result;
wire MEMU_invalid_address;

// CDB
wire [4:0] CDB_ROBEN1;
wire [31:0] CDB_Write_Data1;
wire CDB_EXCEPTION1;
wire [4:0] CDB_ROBEN2;
wire [31:0] CDB_Write_Data2;
wire CDB_EXCEPTION2;
wire [4:0] CDB_ROBEN3;
wire [31:0] CDB_Write_Data3;
wire CDB_EXCEPTION3;
wire [4:0] CDB_ROBEN4;
wire [31:0] CDB_Write_Data4;
wire CDB_EXCEPTION4;

// misc
`define exception_handler 32'd1000
wire hlt;
reg isjr;
reg [31:0] EXCEPTION_EPC, EXCEPTION_CAUSE;
parameter EXCEPTION_CAUSE_INVALID_IM_ADDR = 1,
          EXCEPTION_CAUSE_INVALID_DM_ADDR = 2;


assign hlt = ROB_Commit_opcode == hlt_inst;

nor hlt_logic(clk, input_clk, hlt);

always@(negedge clk , posedge rst) begin
	if (rst)
		cycles_consumed <= 32'd0;
	else
		cycles_consumed <= cycles_consumed + 32'd1;
end


/*
    - the jr dependency is solved but we can do better in terms of forwarding it from the ROB or the CDB, but it works

TODO:
    - better branch predictor
    - make it SS
    - MultiCore (dualcore is enough)
    - check on epsilon in the priority TODO
    - priority encoder in RS

    - GOL: open Quartus, and work on it interfacing and using the RAM2PORT
        - you have two sources of image: the static image, and the run time modification from the proc_interface
        - for speed: adjust the clock of the CPU through the switches
	- use the FPGA to emulate on and display the head of the ROB information through 
	the VGA interface
*/

always@(negedge clk, posedge rst) begin
    isjr <= (rst) ? 1'b0 : ((isjr) ? 1'b0 : InstQ_opcode == jr);
end

always@(posedge clk) begin
    if (~rst) begin
        if (ROB_FLUSH_Flag && ~ROB_Wrong_prediction) begin
            EXCEPTION_EPC <= ROB_Commit_pc;
            EXCEPTION_CAUSE <= EXCEPTION_CAUSE_INVALID_DM_ADDR;
        end
        else if (InstQ_FLUSH_Flag) begin
            EXCEPTION_EPC <= PC_out;
            EXCEPTION_CAUSE <= EXCEPTION_CAUSE_INVALID_IM_ADDR;
        end

    end
end

assign PC = (ROB_FLUSH_Flag == 1'b1) ? ((ROB_Wrong_prediction) ? ROB_Commit_Write_Data : `exception_handler) : 
(
    (InstQ_opcode == j || InstQ_opcode == jal) ? {6'd0,InstQ_address} : 
    (
        (InstQ_opcode == jr) ? ((~isjr) ? PC_out : ((RegFile_RP1_Reg1_ROBEN == 0) ? RegFile_RP1_Reg1 : PC_out)) : 
        (
            (InstQ_opcode == hlt_inst) ? PC_out : 
            (
                ((InstQ_opcode == beq || InstQ_opcode == bne) && predicted) ? PC_out + {{16{InstQ_immediate[15]}},InstQ_immediate} : PC_out + 1'b1
            )
        )
    )
);

// assign InstQ_FLUSH_Flag = ~(rst | (0 <= PC && PC <= 1023));
assign InstQ_FLUSH_Flag = ~(rst | ~(|(PC[31:10])));

PC_register pcreg((InstQ_FLUSH_Flag) ? `exception_handler : PC, PC_out, ~(ROB_FULL_FLAG || LdStB_FULL_FLAG) || ROB_FLUSH_Flag , clk, rst);

InstQ instq
(
    .clk(clk), 
    .rst(rst),
    .PC(PC_out),
    
    .opcode(InstQ_opcode),
    .rs(InstQ_rs), 
    .rt(InstQ_rt), 
    .rd(InstQ_rd), 
    .shamt(InstQ_shamt),
    .immediate(InstQ_immediate),
    .address(InstQ_address),
    .pc(InstQ_PC),
    .VALID_Inst(InstQ_VALID_Inst)
);


RegFile regfile
(
    .clk(clk),
    .rst(rst),

    .WP1_Wen(ROB_Commit_Control_Signals[2]), 
    .Decoded_WP1_Wen((!(InstQ_opcode == jr || InstQ_opcode == sw || InstQ_opcode == beq || 
                        InstQ_opcode == bne || InstQ_opcode == j))),
    .WP1_ROBEN
    (
        ROB_Start_Index
    ), 
    .Decoded_WP1_ROBEN
    (
        ((ROB_FULL_FLAG || LdStB_FULL_FLAG) || ROB_FLUSH_Flag) ? 5'd0 : ROB_End_Index
    ), 
    .WP1_DRindex(ROB_Commit_Rd), 
    .Decoded_WP1_DRindex
    (
        (InstQ_opcode == jal) ? 5'd31 : 
        (
            (InstQ_opcode[11:6] == 6'd0) ? InstQ_rd : InstQ_rt
        )
    ), 
    .WP1_Data(ROB_Commit_Write_Data),

    // inputs
    .ROB_FLUSH_Flag(ROB_FLUSH_Flag),
    .RP1_index1(InstQ_rs), 
    .RP1_index2(InstQ_rt),
    // outputs
    .RP1_Reg1(RegFile_RP1_Reg1), 
    .RP1_Reg2(RegFile_RP1_Reg2),
    .RP1_Reg1_ROBEN(RegFile_RP1_Reg1_ROBEN), 
    .RP1_Reg2_ROBEN(RegFile_RP1_Reg2_ROBEN)
);



BranchPredictor #(.N(3)) BPU
(
    .rst(rst), 
    .clk(clk), 
    .Wrong_prediction(ROB_Wrong_prediction), 
    .Decoded_opcode(InstQ_opcode),
    .Commit_opcode(ROB_Commit_opcode),
    .predicted(predicted)
);

ROB rob
(
    .clk(clk), 
    .rst(rst),
    .Decoded_opcode(InstQ_opcode),
    .Decoded_PC(InstQ_PC),
    .Decoded_Rd
    (
        (InstQ_opcode == jal) ? 5'd31 : 
        (
            (InstQ_opcode == addi || InstQ_opcode == andi || InstQ_opcode == ori || InstQ_opcode == xori || 
            InstQ_opcode == slti || InstQ_opcode == lw) ? InstQ_rt : InstQ_rd
        )
    ),
    .Decoded_prediction(predicted),
    .Branch_Target_Addr((predicted || InstQ_opcode == jal) ? InstQ_PC + 1'b1 : InstQ_PC + {{16{InstQ_immediate[15]}},InstQ_immediate}),

    .CDB_ROBEN1(CDB_ROBEN1),
    .CDB_ROBEN1_Write_Data(CDB_Write_Data1),
    .CDB_Branch_Decision1(FU_Branch_Decision1),
    .CDB_EXCEPTION1(CDB_EXCEPTION1),

    .CDB_ROBEN2(CDB_ROBEN2),
    .CDB_ROBEN2_Write_Data(CDB_Write_Data2),
    .CDB_EXCEPTION2(CDB_EXCEPTION2),

    .CDB_ROBEN3(CDB_ROBEN3),
    .CDB_ROBEN3_Write_Data(CDB_Write_Data3),
    .CDB_Branch_Decision2(FU_Branch_Decision2),
    .CDB_EXCEPTION3(CDB_EXCEPTION3),

    .CDB_ROBEN4(CDB_ROBEN4),
    .CDB_ROBEN4_Write_Data(CDB_Write_Data4),
    .CDB_Branch_Decision3(FU_Branch_Decision3),
    .CDB_EXCEPTION4(CDB_EXCEPTION4),

    .VALID_Inst
    (
        ~rst && 
         ~ROB_FLUSH_Flag && ~(ROB_FULL_FLAG || LdStB_FULL_FLAG) && InstQ_VALID_Inst && InstQ_opcode != j
    ),

    .FULL_FLAG(ROB_FULL_FLAG),
    .EXCEPTION_Flag(ROB_EXCEPTION_Flag),
    .FLUSH_Flag(ROB_FLUSH_Flag),
    .Wrong_prediction(ROB_Wrong_prediction),

    .Commit_opcode(ROB_Commit_opcode),
    .commit_pc(ROB_Commit_pc),
    .Commit_Rd(ROB_Commit_Rd),
    .Commit_Write_Data(ROB_Commit_Write_Data),
    .Commit_Control_Signals(ROB_Commit_Control_Signals),

    .RP1_ROBEN1(RegFile_RP1_Reg1_ROBEN), 
    .RP1_ROBEN2(RegFile_RP1_Reg2_ROBEN),

    .RP1_Write_Data1(ROB_RP1_Write_Data1), 
    .RP1_Write_Data2(ROB_RP1_Write_Data2),
    .RP1_Ready1(ROB_RP1_Ready1), 
    .RP1_Ready2(ROB_RP1_Ready2),

    .Start_Index(ROB_Start_Index),
    .End_Index(ROB_End_Index)
);


ALU_OPER alu_op(InstQ_opcode, InstQ_ALUOP);

RS rs
(
    .clk(clk), 
    .rst(rst),
    .opcode(InstQ_opcode),
    .ALUOP(InstQ_ALUOP),
    // .ROBEN((ROB_End_Index == 5'd1) ? 5'd16 : (ROB_End_Index - 1'b1)),
    .ROBEN(ROB_End_Index),
    .ROBEN1
    (
        (RegFile_RP1_Reg1_ROBEN == 0 || InstQ_opcode == sll || InstQ_opcode == srl || InstQ_opcode == jal) ? 5'd0 : 
        (
            (ROB_RP1_Ready1) ? 5'd0 : RegFile_RP1_Reg1_ROBEN
        )
    ), 
    .ROBEN2
    (
        (InstQ_opcode == addi || InstQ_opcode == andi || InstQ_opcode == ori || InstQ_opcode == xori || 
         InstQ_opcode == slti || InstQ_opcode == jal) ? 5'd0 : 
         (
            (RegFile_RP1_Reg2_ROBEN == 0) ? 5'd0 : 
            (
                (ROB_RP1_Ready2) ? 5'd0 : RegFile_RP1_Reg2_ROBEN
            )
         )
    ), 
    .ROBEN1_VAL
    (
        (RegFile_RP1_Reg1_ROBEN == 0) ? RegFile_RP1_Reg1 : ROB_RP1_Write_Data1
    ), 
    .ROBEN2_VAL
    (
        (RegFile_RP1_Reg2_ROBEN == 0) ? RegFile_RP1_Reg2 : ROB_RP1_Write_Data2
    ), 
    .Immediate
    (
        (InstQ_opcode == sll || InstQ_opcode == srl) ? {27'd0,InstQ_shamt} : 
        (
            (InstQ_opcode == andi || InstQ_opcode == ori || InstQ_opcode == xori) ? {16'd0,InstQ_immediate} : 
            (
                {{16{InstQ_immediate[15]}},InstQ_immediate}
            )
        )
    ),
    .CDB_ROBEN1(CDB_ROBEN1),
    .CDB_ROBEN1_VAL(CDB_Write_Data1),
    .CDB_ROBEN2(CDB_ROBEN2),
    .CDB_ROBEN2_VAL(CDB_Write_Data2),
    .CDB_ROBEN3(CDB_ROBEN3),
    .CDB_ROBEN3_VAL(CDB_Write_Data3),
    .CDB_ROBEN4(CDB_ROBEN4),
    .CDB_ROBEN4_VAL(CDB_Write_Data4),

    .ROB_FLUSH_Flag(ROB_FLUSH_Flag),
    .VALID_Inst
    (
        InstQ_opcode != hlt_inst && InstQ_VALID_Inst && ~ROB_FULL_FLAG && ~ROB_FLUSH_Flag && 
        InstQ_opcode != lw && InstQ_opcode != sw && InstQ_opcode != jal && InstQ_opcode != j
    ),
    .FU_Is_Free(FU_Is_Free),

    .FULL_FLAG(RS_FULL_FLAG),

    .RS_FU_RS_ID1(RS_FU_RS_ID1),
    .RS_FU_ROBEN1(RS_FU_ROBEN1),
    .RS_FU_opcode1(RS_FU_opcode1),   
    .RS_FU_ALUOP1(RS_FU_ALUOP1),
    .RS_FU_Val11(RS_FU_Val11), 
    .RS_FU_Val21(RS_FU_Val21),
    .RS_FU_Immediate1(RS_FU_Immediate1),

    .RS_FU_RS_ID2(RS_FU_RS_ID2),
    .RS_FU_ROBEN2(RS_FU_ROBEN2),
    .RS_FU_opcode2(RS_FU_opcode2),   
    .RS_FU_ALUOP2(RS_FU_ALUOP2),
    .RS_FU_Val12(RS_FU_Val12), 
    .RS_FU_Val22(RS_FU_Val22),
    .RS_FU_Immediate2(RS_FU_Immediate2),

    .RS_FU_RS_ID3(RS_FU_RS_ID3),
    .RS_FU_ROBEN3(RS_FU_ROBEN3),
    .RS_FU_opcode3(RS_FU_opcode3),   
    .RS_FU_ALUOP3(RS_FU_ALUOP3),
    .RS_FU_Val13(RS_FU_Val13), 
    .RS_FU_Val23(RS_FU_Val23),
    .RS_FU_Immediate3(RS_FU_Immediate3)

);

ALU alu1
(
    .clk(clk),
    .rst(rst),
    .ROBEN(RS_FU_ROBEN1),
    .opcode(RS_FU_opcode1),
    .A((RS_FU_opcode1 == sll || RS_FU_opcode1 == srl) ? RS_FU_Val21 : RS_FU_Val11), 
    .B
    (
        (RS_FU_opcode1 == addi || RS_FU_opcode1 == andi || RS_FU_opcode1 == ori || RS_FU_opcode1 == xori || 
         RS_FU_opcode1 == sll  || RS_FU_opcode1 == srl  || RS_FU_opcode1 == slti) ? RS_FU_Immediate1 : RS_FU_Val21
    ), 
    .ALUOP(RS_FU_ALUOP1),

    .FU_res(FU_Result1), 
    .FU_Branch_Decision(FU_Branch_Decision1),
    .FU_ROBEN(FU_ROBEN1),
    .FU_opcode(FU_opcode1)
    // .FU_Is_Free(FU_Is_Free)
);
ALU alu2
(
    .clk(clk),
    .rst(rst),
    .ROBEN(RS_FU_ROBEN2),
    .opcode(RS_FU_opcode2),
    .A((RS_FU_opcode2 == sll || RS_FU_opcode2 == srl) ? RS_FU_Val22 : RS_FU_Val12), 
    .B
    (
        (RS_FU_opcode2 == addi || RS_FU_opcode2 == andi || RS_FU_opcode2 == ori || RS_FU_opcode2 == xori || 
         RS_FU_opcode2 == sll  || RS_FU_opcode2 == srl  || RS_FU_opcode2 == slti) ? RS_FU_Immediate2 : RS_FU_Val22
    ), 
    .ALUOP(RS_FU_ALUOP2),

    .FU_res(FU_Result2), 
    .FU_Branch_Decision(FU_Branch_Decision2),
    .FU_ROBEN(FU_ROBEN2),
    .FU_opcode(FU_opcode2)
    // .FU_Is_Free(FU_Is_Free)
);
ALU alu3
(
    .clk(clk),
    .rst(rst),
    .ROBEN(RS_FU_ROBEN3),
    .opcode(RS_FU_opcode3),
    .A((RS_FU_opcode3 == sll || RS_FU_opcode3 == srl) ? RS_FU_Val23 : RS_FU_Val13), 
    .B
    (
        (RS_FU_opcode3 == addi || RS_FU_opcode3 == andi || RS_FU_opcode3 == ori || RS_FU_opcode3 == xori || 
         RS_FU_opcode3 == sll  || RS_FU_opcode3 == srl  || RS_FU_opcode3 == slti) ? RS_FU_Immediate3 : RS_FU_Val23
    ), 
    .ALUOP(RS_FU_ALUOP3),

    .FU_res(FU_Result3), 
    .FU_Branch_Decision(FU_Branch_Decision3),
    .FU_ROBEN(FU_ROBEN3),
    .FU_opcode(FU_opcode3)
    // .FU_Is_Free(FU_Is_Free)
);




AddressUnit AU
(
    .Decoded_ROBEN(ROB_End_Index),
    .Decoded_Rd(InstQ_rt),
    .Decoded_opcode(InstQ_opcode),
    .ROBEN1
    (
        (RegFile_RP1_Reg1_ROBEN == 0) ? 5'd0 : 
        (
            (ROB_RP1_Ready1) ? 5'd0 : RegFile_RP1_Reg1_ROBEN
        )
    ), 
    .ROBEN2
    (
        (InstQ_opcode == lw) ? 5'd0 : 
        (
            (RegFile_RP1_Reg2_ROBEN == 0) ? 5'd0 : 
            (
                (ROB_RP1_Ready2) ? 5'd0 : RegFile_RP1_Reg2_ROBEN
            )
        )
    ),
    .ROBEN1_VAL
    (
        (RegFile_RP1_Reg1_ROBEN == 0) ? RegFile_RP1_Reg1 : ROB_RP1_Write_Data1
    ), 
    .ROBEN2_VAL
    (
        (RegFile_RP1_Reg2_ROBEN == 0) ? RegFile_RP1_Reg2 : ROB_RP1_Write_Data2
    ), 
    .Immediate({{16{InstQ_immediate[15]}},InstQ_immediate}),
    .InstQ_VALID_Inst(InstQ_VALID_Inst),

    .AU_LdStB_VALID_Inst(AU_LdStB_VALID_Inst),
    .AU_LdStB_ROBEN(AU_LdStB_ROBEN),
    .AU_LdStB_Rd(AU_LdStB_Rd),
    .AU_LdStB_opcode(AU_LdStB_opcode),
    .AU_LdStB_ROBEN1(AU_LdStB_ROBEN1), 
    .AU_LdStB_ROBEN2(AU_LdStB_ROBEN2),
    .AU_LdStB_ROBEN1_VAL(AU_LdStB_ROBEN1_VAL), 
    .AU_LdStB_ROBEN2_VAL(AU_LdStB_ROBEN2_VAL),
    .AU_LdStB_Immediate(AU_LdStB_Immediate)
);


/*
option 0:
we let the store enter the ldstbuffer but we let them write to the memory once they commit from the ROB 
and if there is a memory dependency we forward the data to the load once they are ready from within the ldstbuffer

option 1:
we separate the ld/st buffer into load buffer and store buffer:

option 2:
we make it a load buffer and store instructions can write to the memory once they commit from the ROB, but in this case 
    - we should modify the ROB so it can update the dependent fields of the store instruction to be ready and currently it doesn't support that
    - if there is a memory dependecy we should check every previous store instruction for similarity in the effective address (EA) and forward the data from there 
    or wait until it write to the memory
    - 
*/

LSBuffer lsbuffer
(
    .clk(clk), 
    .rst(rst),
    .VALID_Inst(AU_LdStB_VALID_Inst && ~ROB_FULL_FLAG && ~ROB_FLUSH_Flag && ~rst),
    .ROBEN(AU_LdStB_ROBEN),
    .Rd(AU_LdStB_Rd),
    .opcode(AU_LdStB_opcode),
    .ROBEN1(AU_LdStB_ROBEN1), 
    .ROBEN2(AU_LdStB_ROBEN2),
    .ROBEN1_VAL(AU_LdStB_ROBEN1_VAL), 
    .ROBEN2_VAL(AU_LdStB_ROBEN2_VAL),
    .Immediate(AU_LdStB_Immediate),
    .EA(AU_LdStB_EA),

    .ROB_Start_Index(ROB_Start_Index),
    .ROB_FLUSH_Flag(ROB_FLUSH_Flag),

    .CDB_ROBEN1(CDB_ROBEN1),
    .CDB_ROBEN1_VAL(CDB_Write_Data1),
    .CDB_ROBEN2(CDB_ROBEN2),
    .CDB_ROBEN2_VAL(CDB_Write_Data2),
    .CDB_ROBEN3(CDB_ROBEN3),
    .CDB_ROBEN3_VAL(CDB_Write_Data3),
    .CDB_ROBEN4(CDB_ROBEN4),
    .CDB_ROBEN4_VAL(CDB_Write_Data4),

    .FULL_FLAG(LdStB_FULL_FLAG),
    .out_VALID_Inst(LdStB_MEMU_VALID_Inst),
    .out_ROBEN(LdStB_MEMU_ROBEN),
    .out_Rd(LdStB_MEMU_Rd),
    .out_opcode(LdStB_MEMU_opcode),
    .out_ROBEN1(LdStB_MEMU_ROBEN1), 
    .out_ROBEN2(LdStB_MEMU_ROBEN2),
    .out_ROBEN1_VAL(LdStB_MEMU_ROBEN1_VAL), 
    .out_ROBEN2_VAL(LdStB_MEMU_ROBEN2_VAL),
    .out_Immediate(LdStB_MEMU_Immediate),
    .out_EA(LdStB_MEMU_EA),

    .Start_Index(LdStB_Start_Index),
    .End_Index(LdStB_End_Index)
);


DM datamemory
(
    .clk(clk), 
    .ROBEN((LdStB_MEMU_VALID_Inst) ? LdStB_MEMU_ROBEN : 5'd0),
    .Read_en
    (
        (LdStB_MEMU_VALID_Inst) ? LdStB_MEMU_opcode == lw : 1'b0
    ), 
    .Write_en
    (
        (LdStB_MEMU_VALID_Inst) ? LdStB_MEMU_opcode == sw : 1'b0
    ), 
    .address(LdStB_MEMU_EA),
    .data(LdStB_MEMU_ROBEN2_VAL),
    .MEMU_invalid_address(MEMU_invalid_address),
    .MEMU_ROBEN(MEMU_ROBEN),
    .MEMU_Result(MEMU_Result)

);




CDB cdb
(
    .ROBEN1(FU_ROBEN1),
    .Write_Data1(FU_Result1),
    .EXCEPTION1(1'b0),

    .ROBEN2(MEMU_ROBEN),
    .Write_Data2(MEMU_Result),
    .EXCEPTION2(MEMU_invalid_address),

    .ROBEN3(FU_ROBEN2),
    .Write_Data3(FU_Result2),
    .EXCEPTION3(1'b0),

    .ROBEN4(FU_ROBEN3),
    .Write_Data4(FU_Result3),
    .EXCEPTION4(1'b0),


    .out_ROBEN1(CDB_ROBEN1),
    .out_Write_Data1(CDB_Write_Data1),
    .out_EXCEPTION1(CDB_EXCEPTION1),    

    .out_ROBEN2(CDB_ROBEN2),
    .out_Write_Data2(CDB_Write_Data2),
    .out_EXCEPTION2(CDB_EXCEPTION2),

    .out_ROBEN3(CDB_ROBEN3),
    .out_Write_Data3(CDB_Write_Data3),
    .out_EXCEPTION3(CDB_EXCEPTION3),

    .out_ROBEN4(CDB_ROBEN4),
    .out_Write_Data4(CDB_Write_Data4),
    .out_EXCEPTION4(CDB_EXCEPTION4)

);





endmodule