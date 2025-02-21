
`define MEMORY_SIZE 2048
`define MEMORY_BITS 11
`define ROB_SIZE_bits (4)
`define BUFFER_SIZE_bitslsbuffer (4)
`define BUFFER_SIZE_bitsRS (4)
`define ROB_SIZE ((1 << `ROB_SIZE_bits))


`ifndef VGA
module SSOOO_CPU
(
    input input_clk, rst,
    output reg [31:0] cycles_consumed
);

`else

module SSOOO_CPU
(
    input input_clk, rst,
    output reg [31:0] cycles_consumed,
    output [31:0] PC_out,
    output reg hlt,

    output reg [11:0] InstQ_opcode,
    output reg [4:0] InstQ_rs, InstQ_rt, InstQ_rd, InstQ_shamt,
    output reg [15:0] InstQ_immediate,
    output reg [25:0] InstQ_address,
    output reg [31:0] InstQ_PC,

    input [9:0] VGA_address,
    input VGA_clk,
    output [31:0] VGA_data
);
`endif

`include "opcodes.txt"

wire [31:0] PC, Branch_Target_Addr;
wire PC_src, clk;

// InstQ
wire [3:0] InstQ_ALUOP;
`ifndef VGA
    reg hlt;
    wire [31:0] PC_out;

    reg [ 11:0] InstQ_opcode;
    reg [ 4:0] InstQ_rs, InstQ_rt, InstQ_rd, InstQ_shamt;
    reg [15:0] InstQ_immediate;
    reg [25:0] InstQ_address;
    reg [31:0] InstQ_PC;
`endif
wire [ 11:0] InstQ_opcode_temp;
wire [ 4:0] InstQ_rs_temp, InstQ_rt_temp, InstQ_rd_temp, InstQ_shamt_temp;
wire [15:0] InstQ_immediate_temp;
wire [25:0] InstQ_address_temp;
wire [31:0] InstQ_PC_temp;

wire [ 11:0] InstQ_opcode_temp2;
wire [ 4:0] InstQ_rs_temp2, InstQ_rt_temp2, InstQ_rd_temp2, InstQ_shamt_temp2;
wire [15:0] InstQ_immediate_temp2;
wire [25:0] InstQ_address_temp2;
wire [31:0] InstQ_PC_temp2;

wire InstQ_VALID_Inst_temp;
reg InstQ_VALID_Inst;

wire InstQ_FLUSH_Flag;


// RegFile
reg [31:0] RegFile_RP1_Reg1, RegFile_RP1_Reg2;
reg [`ROB_SIZE_bits:0] RegFile_RP1_Reg1_ROBEN, RegFile_RP1_Reg2_ROBEN;
wire [31:0] RegFile_RP1_Reg1_temp, RegFile_RP1_Reg2_temp;
wire [`ROB_SIZE_bits:0] RegFile_RP1_Reg1_ROBEN_temp, RegFile_RP1_Reg2_ROBEN_temp;

// BPU
wire [11:0] Decoded_opcode, Commit_opcode;
wire [1:0] state;  // 2-bit state (00 NT | 01 NT | 10 T | 11 T)
reg predicted; // prediction (1 = taken, 0 = not taken)
wire predicted_temp; // prediction (1 = taken, 0 = not taken)

// ROB
wire ROB_FULL_FLAG;
wire ROB_FLUSH_Flag;
wire ROB_EXCEPTION_Flag;
wire ROB_Wrong_prediction;

wire [11:0] ROB_Commit_opcode;
wire [31:0] ROB_Commit_pc;
wire [4:0] ROB_Commit_Rd;
wire [31:0] ROB_Commit_Write_Data;
wire [2:0] ROB_Commit_Control_Signals;
wire [31:0] ROB_Commit_BTA;
wire [`ROB_SIZE_bits:0] ROB_Start_Index;
wire [`ROB_SIZE_bits:0] ROB_End_Index;
wire [31:0] ROB_RP1_Write_Data1, ROB_RP1_Write_Data2;
wire ROB_RP1_Ready1, ROB_RP1_Ready2;

// RS
wire RS_FULL_FLAG;
wire [`BUFFER_SIZE_bitsRS+1:0] RS_FU_RS_ID1;
wire [`ROB_SIZE_bits:0] RS_FU_ROBEN1;
wire [11:0] RS_FU_opcode1;
wire [3:0] RS_FU_ALUOP1;
wire [31:0] RS_FU_Val11, RS_FU_Val21;
wire [31:0] RS_FU_Immediate1;

wire [`BUFFER_SIZE_bitsRS+1:0] RS_FU_RS_ID2;
wire [`ROB_SIZE_bits:0] RS_FU_ROBEN2;
wire [11:0] RS_FU_opcode2;
wire [3:0] RS_FU_ALUOP2;
wire [31:0] RS_FU_Val12, RS_FU_Val22;
wire [31:0] RS_FU_Immediate2;

wire [`BUFFER_SIZE_bitsRS+1:0] RS_FU_RS_ID3;
wire [`ROB_SIZE_bits:0] RS_FU_ROBEN3;
wire [11:0] RS_FU_opcode3;
wire [3:0] RS_FU_ALUOP3;
wire [31:0] RS_FU_Val13, RS_FU_Val23;
wire [31:0] RS_FU_Immediate3;

// FU
wire [31:0] FU_Result1;
wire [`ROB_SIZE_bits:0] FU_ROBEN1;
wire [11:0] FU_opcode1;
wire FU_Branch_Decision1;

wire [31:0] FU_Result2;
wire [`ROB_SIZE_bits:0] FU_ROBEN2;
wire [11:0] FU_opcode2;
wire FU_Branch_Decision2;

wire [31:0] FU_Result3;
wire [`ROB_SIZE_bits:0] FU_ROBEN3;
wire [11:0] FU_opcode3;
wire FU_Branch_Decision3;


wire FU_Is_Free;

// Address Unit
wire AU_LdStB_VALID_Inst;
wire [`ROB_SIZE_bits:0]  AU_LdStB_ROBEN;
wire [4:0]  AU_LdStB_Rd;
wire [11:0] AU_LdStB_opcode;
wire [`ROB_SIZE_bits:0]  AU_LdStB_ROBEN1, AU_LdStB_ROBEN2;
wire [31:0] AU_LdStB_ROBEN1_VAL, AU_LdStB_ROBEN2_VAL;
wire [31:0] AU_LdStB_Immediate;
wire [31:0] AU_LdStB_EA, AU_LdStB_Write_Data;

// Load Store Buffer
wire LdStB_MEMU_VALID_Inst;
wire LdStB_FULL_FLAG;
wire [`ROB_SIZE_bits:0]  LdStB_MEMU_ROBEN;
wire [4:0]  LdStB_MEMU_Rd;
wire [11:0] LdStB_MEMU_opcode;
wire [`ROB_SIZE_bits:0]  LdStB_MEMU_ROBEN1, LdStB_MEMU_ROBEN2;
wire [31:0] LdStB_MEMU_ROBEN1_VAL, LdStB_MEMU_ROBEN2_VAL;
wire [31:0] LdStB_MEMU_Immediate;
wire [31:0] LdStB_MEMU_EA, LdStB_MEMU_Write_Data;
wire [2:0] LdStB_Start_Index;
wire [2:0] LdStB_End_Index;

// Memory Unit
wire [`ROB_SIZE_bits:0] MEMU_ROBEN;
wire [31:0] MEMU_Result;
wire MEMU_invalid_address;

// CDB
wire [`ROB_SIZE_bits:0] CDB_ROBEN1;
wire [31:0] CDB_Write_Data1;
wire CDB_EXCEPTION1;
wire [`ROB_SIZE_bits:0] CDB_ROBEN2;
wire [31:0] CDB_Write_Data2;
wire CDB_EXCEPTION2;
wire [`ROB_SIZE_bits:0] CDB_ROBEN3;
wire [31:0] CDB_Write_Data3;
wire CDB_EXCEPTION3;
wire [`ROB_SIZE_bits:0] CDB_ROBEN4;
wire [31:0] CDB_Write_Data4;
wire CDB_EXCEPTION4;

// misc
`define exception_handler 32'd1000
// wire hlt;
reg isjr;
reg [31:0] EXCEPTION_EPC, EXCEPTION_CAUSE;
parameter EXCEPTION_CAUSE_INVALID_IM_ADDR = 1,
          EXCEPTION_CAUSE_INVALID_DM_ADDR = 2;

always@(posedge clk, posedge rst) begin
    if (rst)
        hlt <= 1'b0;
    else
        hlt <= ROB_Commit_opcode == hlt_inst;
end
// assign hlt <= ROB_Commit_opcode == hlt_inst;


nor hlt_logic(clk, input_clk, hlt);

always@(negedge clk , posedge rst) begin
	if (rst)
		cycles_consumed <= 32'd0;
	else
		cycles_consumed <= cycles_consumed + 32'd1;
end


/*
TODO:
    - make it SS

    - Fmax the design, and pick the best to take to the finals

    - MultiCore (dualcore is enough)

    - see remaining todos in iphone picture or from teams
*/


always@(posedge clk, posedge rst) begin
    if (rst) begin
        EXCEPTION_EPC <= 0;
        EXCEPTION_CAUSE <= 0;
    end
    else begin
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


`define JR_DESTINATION (~(|RegFile_RP1_Reg1_ROBEN)) ? RegFile_RP1_Reg1 : (ROB_RP1_Ready1 ? ROB_RP1_Write_Data1 : InstQ_PC)

assign PC = (ROB_FLUSH_Flag == 1'b1) ? ((ROB_Wrong_prediction) ? ROB_Commit_BTA : `exception_handler) : 
(
    (
        (InstQ_opcode_temp == j || InstQ_opcode_temp == jal) ? {6'd0,InstQ_address_temp} : 
        (
            (InstQ_opcode == jr) ? (`JR_DESTINATION) : 
            (
                (InstQ_opcode_temp == jr) ? InstQ_PC_temp : 
                (
                    (InstQ_opcode == hlt_inst) ? InstQ_PC: 
                    (
                        ((InstQ_opcode_temp == beq || InstQ_opcode_temp == bne) && predicted_temp) ? InstQ_PC_temp + {{16{InstQ_immediate_temp[15]}},InstQ_immediate_temp} : PC_out + 2'd1
                    )
                )
            )
        )
    )
);
// `endif
// assign InstQ_FLUSH_Flag = ~(rst || ~(|(PC[31:10])));
assign InstQ_FLUSH_Flag = ~(rst || (PC <= `MEMORY_SIZE));

PC_register pcreg
(
    (InstQ_FLUSH_Flag) ? `exception_handler : PC, 
    PC_out, 
    ~(ROB_FULL_FLAG || RS_FULL_FLAG || LdStB_FULL_FLAG) || ROB_FLUSH_Flag , 
    clk, rst
);

InstQ instq
(
    .clk(clk), 
    .rst(rst),
    .PC_from_assign(PC),
    .PC(PC_out),
    
    .opcode1(InstQ_opcode_temp),
    .rs1(InstQ_rs_temp), 
    .rt1(InstQ_rt_temp), 
    .rd1(InstQ_rd_temp), 
    .shamt1(InstQ_shamt_temp),
    .immediate1(InstQ_immediate_temp),
    .address1(InstQ_address_temp),
    .pc1(InstQ_PC_temp),
    .VALID_Inst(InstQ_VALID_Inst_temp),

    .opcode2(InstQ_opcode_temp2),
    .rs2(InstQ_rs_temp2), 
    .rt2(InstQ_rt_temp2), 
    .rd2(InstQ_rd_temp2), 
    .shamt2(InstQ_shamt_temp2),
    .immediate2(InstQ_immediate_temp2),
    .address2(InstQ_address_temp2),
    .pc2(InstQ_PC_temp2)
);



always@(negedge clk, posedge rst) begin
    if (rst) begin
        InstQ_opcode <= 0;
        InstQ_VALID_Inst <= 0;
    end
    else if (ROB_FLUSH_Flag || RS_FULL_FLAG || LdStB_FULL_FLAG) begin
        InstQ_rs <= 0;
        InstQ_rt <= 0;
        InstQ_rd <= 0;
        InstQ_opcode <= 0;
        InstQ_VALID_Inst <= 0;
        RegFile_RP1_Reg1_ROBEN <= 0;
        RegFile_RP1_Reg2_ROBEN <= 0;
        RegFile_RP1_Reg1 <= 0;
        RegFile_RP1_Reg2 <= 0;
    end
    else if (~ROB_FULL_FLAG) begin
        InstQ_opcode <= InstQ_opcode_temp;
        InstQ_rs <= InstQ_rs_temp;
        InstQ_rt <= InstQ_rt_temp;
        InstQ_rd <= InstQ_rd_temp;
        InstQ_shamt <= InstQ_shamt_temp;
        InstQ_immediate <= InstQ_immediate_temp;
        InstQ_address <= InstQ_address_temp;
        InstQ_PC <= InstQ_PC_temp;
        InstQ_VALID_Inst <= InstQ_VALID_Inst_temp;
        predicted <= predicted_temp;

        RegFile_RP1_Reg1_ROBEN <= RegFile_RP1_Reg1_ROBEN_temp;
        RegFile_RP1_Reg2_ROBEN <= RegFile_RP1_Reg2_ROBEN_temp;
        RegFile_RP1_Reg1 <= RegFile_RP1_Reg1_temp;
        RegFile_RP1_Reg2 <= RegFile_RP1_Reg2_temp;
    end
end


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
        ((ROB_FULL_FLAG || RS_FULL_FLAG || LdStB_FULL_FLAG) || ROB_FLUSH_Flag) ? {(`ROB_SIZE_bits+1){1'b0}} : ROB_End_Index
    ), 
    .WP1_DRindex(ROB_Commit_Rd), 
    .Decoded_WP1_DRindex
    (
        (InstQ_opcode == jal) ? 5'd31 : 
        (
            (~(|InstQ_opcode[11:6])) ? InstQ_rd : InstQ_rt
        )
    ), 
    .WP1_Data(ROB_Commit_Write_Data),

    // inputs
    .ROB_FLUSH_Flag(ROB_FLUSH_Flag),
    
    .RP1_index1(InstQ_rs_temp), 
    .RP1_index2(InstQ_rt_temp),
    // outputs
    .RP1_Reg1(RegFile_RP1_Reg1_temp), 
    .RP1_Reg2(RegFile_RP1_Reg2_temp),
    .RP1_Reg1_ROBEN(RegFile_RP1_Reg1_ROBEN_temp), 
    .RP1_Reg2_ROBEN(RegFile_RP1_Reg2_ROBEN_temp)
);



BranchPredictor #(.N(3)) BPU
(
    .rst(rst), 
    .clk(clk), 
    .Wrong_prediction(ROB_Wrong_prediction), 
    .Decoded_opcode(InstQ_opcode_temp),
    .Commit_opcode(ROB_Commit_opcode),
    .predicted(predicted_temp)
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
            (~(|InstQ_opcode[11:6])) ? InstQ_rd : InstQ_rt
        )
    ),
    .Decoded_prediction(predicted),
    .Branch_Target_Addr((predicted) ? InstQ_PC + 1'b1 : InstQ_PC + {{16{InstQ_immediate[15]}},InstQ_immediate}),
    .init_Write_Data(InstQ_PC + 1'b1),

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
         ~ROB_FLUSH_Flag && ~(ROB_FULL_FLAG || RS_FULL_FLAG || LdStB_FULL_FLAG) && InstQ_VALID_Inst && InstQ_opcode != j && InstQ_opcode != jr
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
    .commit_BTA(ROB_Commit_BTA),


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
/*
(InstQ_opcode == jal) ? 5'd31 : 
(
    (InstQ_opcode == addi || InstQ_opcode == andi || InstQ_opcode == ori || InstQ_opcode == xori || 
    InstQ_opcode == slti || InstQ_opcode == lw) ? InstQ_rt : InstQ_rd
)
*/

wire [`ROB_SIZE_bits:0] new_End_Index = (ROB_End_Index == 1) ? `ROB_SIZE : ROB_End_Index - 1'b1;
RS rs
(
    .clk(clk), 
    .rst(rst),
    .opcode(InstQ_opcode),
    .ALUOP(InstQ_ALUOP),
    .ROBEN(new_End_Index),
    .ROBEN1
    (
        (~(|RegFile_RP1_Reg1_ROBEN) || ROB_RP1_Ready1 || 
        InstQ_opcode == sll || InstQ_opcode == srl) ?                                 {(`ROB_SIZE_bits+1){1'b0}} : RegFile_RP1_Reg1_ROBEN
    ), 
    .ROBEN2
    (
        (~(|RegFile_RP1_Reg2_ROBEN) || ROB_RP1_Ready2 || 
        (InstQ_opcode[11:6] != 6'd0 && InstQ_opcode != beq && InstQ_opcode != bne)) ? {(`ROB_SIZE_bits+1){1'b0}} : RegFile_RP1_Reg2_ROBEN
    ), 
    .ROBEN1_VAL
    (
        (~(|RegFile_RP1_Reg1_ROBEN)) ? RegFile_RP1_Reg1 : ROB_RP1_Write_Data1
    ), 
    .ROBEN2_VAL
    (
        (~(|RegFile_RP1_Reg2_ROBEN)) ? RegFile_RP1_Reg2 : ROB_RP1_Write_Data2
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
        InstQ_opcode != hlt_inst && InstQ_VALID_Inst && ~ROB_FULL_FLAG && ~RS_FULL_FLAG && ~ROB_FLUSH_Flag && 
        InstQ_opcode != lw && InstQ_opcode != sw && InstQ_opcode != jal && InstQ_opcode != j && InstQ_opcode != jr
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
        (RS_FU_opcode1 == sll  || RS_FU_opcode1 == srl  || ((|RS_FU_opcode1[11:6]) && RS_FU_opcode1 != beq && RS_FU_opcode1 != bne)) ? RS_FU_Immediate1 : RS_FU_Val21
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
        (RS_FU_opcode2 == sll  || RS_FU_opcode2 == srl  || ((|RS_FU_opcode2[11:6]) && RS_FU_opcode2 != beq && RS_FU_opcode2 != bne)) ? RS_FU_Immediate2 : RS_FU_Val22
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
        (RS_FU_opcode3 == sll  || RS_FU_opcode3 == srl  || ((|RS_FU_opcode3[11:6]) && RS_FU_opcode3 != beq && RS_FU_opcode3 != bne)) ? RS_FU_Immediate3 : RS_FU_Val23
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
    .Decoded_ROBEN(new_End_Index),
    .Decoded_Rd(InstQ_rt),
    .Decoded_opcode(InstQ_opcode),
    .ROBEN1
    (
        (~(|RegFile_RP1_Reg1_ROBEN) || ROB_RP1_Ready1) ? {(`ROB_SIZE_bits+1){1'b0}} : RegFile_RP1_Reg1_ROBEN
    ), 
    .ROBEN2
    (
        (~(|RegFile_RP1_Reg2_ROBEN) || ROB_RP1_Ready2 || 
        InstQ_opcode == lw) ?                            {(`ROB_SIZE_bits+1){1'b0}} : RegFile_RP1_Reg2_ROBEN
    ),
    .ROBEN1_VAL
    (
        (~(|RegFile_RP1_Reg1_ROBEN)) ? RegFile_RP1_Reg1 : ROB_RP1_Write_Data1
    ), 
    .ROBEN2_VAL
    (
        (~(|RegFile_RP1_Reg2_ROBEN)) ? RegFile_RP1_Reg2 : ROB_RP1_Write_Data2
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
    .VALID_Inst(AU_LdStB_VALID_Inst && ~ROB_FULL_FLAG && ~LdStB_FULL_FLAG && ~ROB_FLUSH_Flag && ~rst),
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
    .out_EA(LdStB_MEMU_EA)

    // ,.Start_Index(LdStB_Start_Index),
    // .End_Index(LdStB_End_Index)
);


DM datamemory
(
    .clk(clk), 
    .ROBEN((LdStB_MEMU_VALID_Inst) ? LdStB_MEMU_ROBEN : {(`ROB_SIZE_bits+1){1'b0}}),
    .Read_en
    (
        (LdStB_MEMU_VALID_Inst) ? LdStB_MEMU_opcode == lw : 1'b0
    ), 
    .Write_en
    (
        (LdStB_MEMU_VALID_Inst) ? LdStB_MEMU_opcode == sw : 1'b0
    ), 
    .LdStB_MEMU_ROBEN1_VAL(LdStB_MEMU_ROBEN1_VAL),
    .LdStB_MEMU_Immediate(LdStB_MEMU_Immediate),
    .address(LdStB_MEMU_EA),
    .data(LdStB_MEMU_ROBEN2_VAL),
    .MEMU_invalid_address(MEMU_invalid_address),
    .MEMU_ROBEN(MEMU_ROBEN),
    .MEMU_Result(MEMU_Result)
`ifdef VGA
    ,.VGA_address(VGA_address),
    .VGA_clk(VGA_clk),
    .VGA_data(VGA_data)
`endif

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