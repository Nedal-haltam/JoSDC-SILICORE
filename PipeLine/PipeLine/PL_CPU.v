
module PL_CPU
(
	input input_clk, rst, 
	output [31:0] PC,
	output reg [31:0] cycles_consumed,
	output reg [31:0] StallCount,
	output reg [31:0] BranchPredictionCount,
	output reg [31:0] BranchPredictionMissCount
);

wire clk, hlt;
`include "opcodes.txt"

wire [31:0] IF_pc, IF_INST;
wire [2:0]  pc_src;
wire if_id_write;

wire [31:0] ID_PFC_to_IF, ID_PFC_to_EX, ID_PC, ID_INST, ID_rs1, ID_rs2, ID_forward_to_B;
wire [11:0]  ID_opcode;
wire [4:0]  ID_rs1_ind, ID_rs2_ind, ID_rd_ind;
wire ID_regwrite, ID_memread, ID_memwrite, ID_is_oper2_immed, ID_predicted;


wire [31:0] EX1_PFC, EX1_ALU_OUT, EX1_PC, EX1_PFC_to_IF, EX1_rs1, EX1_rs2, EX1_rs2_out, EX1_forward_to_B, EX1_ALU_OPER1, EX1_ALU_OPER2;
wire [11:0] EX1_opcode;
wire [4:0] EX1_rd_ind, EX1_rs1_ind, EX1_rs2_ind;
wire [1:0]  alu_selA, alu_selB, store_rs2_forward;
wire EX1_regwrite, EX1_memread, EX1_memwrite, EX1_predicted, EX1_is_oper2_immed, EX1_is_jr, EX1_is_beq, EX1_is_bne, EX1_is_jal, EX1_rd_indzero;

wire [31:0] EX2_ALU_OUT, EX2_PC, EX2_PFC_to_IF, EX2_rs1, EX2_rs2, EX2_rs2_out, EX2_forward_to_B, EX2_ALU_OPER1, EX2_ALU_OPER2;
wire [11:0] EX2_opcode;
wire [4:0] EX2_rd_ind, EX2_rs1_ind, EX2_rs2_ind;
wire EX2_regwrite, EX2_memread, EX2_memwrite, EX2_predicted, EX2_is_oper2_immed, EX2_is_jr, EX2_is_beq, EX2_is_bne, EX2_is_jal, STALL_ID2_FLUSH, EX2_rd_indzero;


wire [31:0] MEM_ALU_OUT, MEM_rs2, MEM_Data_mem_out;
wire [11:0] MEM_opcode;
wire [4:0]  MEM_rd_ind;
wire MEM_regwrite, MEM_memread, MEM_memwrite; 

wire [31:0] WB_ALU_OUT, WB_Data_mem_out, wdata_to_reg_file;
wire [4:0]  WB_rd_ind;
wire WB_memread, WB_regwrite;


wire pc_write, Wrong_prediction;
wire ID_is_beq, ID_is_bne, ID_is_jr, ID_is_jal, ID_is_j, 
	 is_branch_and_taken, MEM_rd_indzero, WB_rd_indzero;
wire STALL_IF_FLUSH, STALL_ID1_FLUSH;
wire idhaz, exhaz, memhaz;
wire idhaz2, exhaz2, memhaz2;


always@(negedge clk, posedge rst) begin
	if (rst) begin
		cycles_consumed <= 0;
		StallCount <= 0;
		BranchPredictionCount <= 0;
		BranchPredictionMissCount <= 0;
	end
	else begin
		cycles_consumed <= cycles_consumed + 32'd1;
		StallCount <= StallCount + ((STALL_IF_FLUSH || STALL_ID1_FLUSH || STALL_ID2_FLUSH) ? 1'b1 : 1'b0);
		BranchPredictionCount <= BranchPredictionCount + ((EX2_opcode == beq || EX2_opcode == bne) ? 1'b1 : 1'b0);
		BranchPredictionMissCount <= BranchPredictionMissCount + (((EX2_opcode == beq || EX2_opcode == bne) && Wrong_prediction) ? 1'b1 : 1'b0);
	end
end


nor hlt_logic(clk, input_clk, hlt);


assign idhaz = EX2_regwrite && EX2_rd_indzero && EX2_rd_ind == EX1_rs1_ind;
assign exhaz = MEM_regwrite && MEM_rd_indzero && MEM_rd_ind == EX1_rs1_ind;
assign memhaz = WB_regwrite && WB_rd_indzero && WB_rd_ind == EX1_rs1_ind;
forwardA FA
(
	idhaz, exhaz, memhaz,
	alu_selA
);


assign idhaz2 = EX2_regwrite && EX2_rd_indzero && EX2_rd_ind == EX1_rs2_ind;
assign exhaz2 = MEM_regwrite && MEM_rd_indzero && MEM_rd_ind == EX1_rs2_ind;
assign memhaz2 = WB_regwrite && WB_rd_indzero && WB_rd_ind == EX1_rs2_ind;
forwardB FB
(
	idhaz2, exhaz2, memhaz2,
	alu_selB, EX1_is_oper2_immed
);

forwardC FC
(
	idhaz2, exhaz2, memhaz2,
	store_rs2_forward
);





IF_stage if_stage(ID_PFC_to_IF, EX1_PFC_to_IF, EX2_PFC_to_IF, pc_src, IF_pc, pc_write, clk, IF_INST, rst);


IF_ID_buffer if_id_buffer(IF_pc, IF_INST, STALL_IF_FLUSH, if_id_write, ~clk, ID_opcode, ID_rs1_ind, ID_rs2_ind, ID_rd_ind, ID_PC, ID_INST, rst); 



ID_stage id_stage
(
	ID_PC, ID_INST, ID_opcode, EX1_opcode, EX2_opcode, EX1_memread, EX2_memread, wdata_to_reg_file, 
	ID_rs1_ind, ID_rs2_ind,
	EX1_rd_indzero, EX1_rd_ind, EX2_rd_indzero, EX2_rd_ind, WB_rd_ind,
	STALL_ID1_FLUSH, STALL_ID2_FLUSH, Wrong_prediction, clk, ID_PFC_to_IF, ID_PFC_to_EX, ID_predicted, ID_rs1, ID_rs2, pc_src,
	pc_write, if_id_write, STALL_IF_FLUSH, WB_regwrite, ID_regwrite, ID_memread, ID_memwrite, rst, ID_is_oper2_immed, 
	ID_is_beq, ID_is_bne, ID_is_jr, ID_is_jal, ID_is_j, is_branch_and_taken, ID_forward_to_B
);













ID_EX_buffer1 id_ex_buffer1
(
	~clk, STALL_ID1_FLUSH, rst,
	ID_opcode, ID_rs1_ind, ID_rs2_ind, ID_rd_ind != 0, ID_rd_ind, ID_PC, ID_rs1, ID_rs2, ID_regwrite, ID_memread, ID_memwrite, ID_PFC_to_EX, ID_predicted, ID_is_oper2_immed, ID_is_beq, ID_is_bne, ID_is_jr, ID_is_jal, ID_forward_to_B,
	EX1_opcode, EX1_rs1_ind, EX1_rs2_ind, EX1_rd_indzero, EX1_rd_ind, EX1_PC, EX1_rs1, EX1_rs2, EX1_regwrite, EX1_memread, EX1_memwrite, EX1_PFC, EX1_predicted, EX1_is_oper2_immed, EX1_is_beq, EX1_is_bne, EX1_is_jr, EX1_is_jal, EX1_forward_to_B
);


FORWARDING_stage forwarding_stage
(
    EX1_rs1, EX2_ALU_OUT, MEM_ALU_OUT, wdata_to_reg_file, EX1_PC, alu_selA, EX1_ALU_OPER1,
    EX1_forward_to_B, alu_selB, EX1_ALU_OPER2,
    EX1_rs2, store_rs2_forward, EX1_rs2_out,
    EX1_is_jr, EX1_PFC, EX1_PFC_to_IF
);



ID_EX_buffer2 id_ex_buffer2
(
	~clk, STALL_ID2_FLUSH, rst,
	EX1_ALU_OPER1, EX1_ALU_OPER2, EX1_opcode, EX1_rs1_ind, EX1_rs2_ind, EX1_rd_indzero, EX1_rd_ind, EX1_PC, EX1_rs1, EX1_rs2_out, EX1_regwrite, EX1_memread, EX1_memwrite, EX1_predicted, EX1_is_oper2_immed, EX1_is_beq, EX1_is_bne, EX1_is_jr, EX1_is_jal, EX1_forward_to_B, EX1_PFC_to_IF, 
	EX2_ALU_OPER1, EX2_ALU_OPER2, EX2_opcode, EX2_rs1_ind, EX2_rs2_ind, EX2_rd_indzero, EX2_rd_ind, EX2_PC, EX2_rs1, EX2_rs2_out, EX2_regwrite, EX2_memread, EX2_memwrite, EX2_predicted, EX2_is_oper2_immed, EX2_is_beq, EX2_is_bne, EX2_is_jr, EX2_is_jal, EX2_forward_to_B,	EX2_PFC_to_IF
);


EX_stage ex_stage
(
	EX2_PC, EX2_ALU_OPER1, EX2_ALU_OPER2, EX2_opcode, EX2_ALU_OUT, EX2_predicted, Wrong_prediction, rst, EX2_is_beq, EX2_is_bne, EX2_is_jal
);





















EX_MEM_buffer ex_mem_buffer
(
	~clk, rst,
	EX2_ALU_OUT, EX2_rs2_out, EX2_rd_ind != 0, EX2_rd_ind, EX2_opcode, EX2_regwrite, EX2_memread, EX2_memwrite,
	MEM_ALU_OUT, MEM_rs2, MEM_rd_indzero, MEM_rd_ind, MEM_opcode, MEM_regwrite, MEM_memread, MEM_memwrite
);					 


MEM_stage mem_stage(MEM_ALU_OUT, MEM_rs2, MEM_memwrite, MEM_memread, MEM_Data_mem_out, clk);



MEM_WB_buffer mem_wb_buffer
(
	~clk, hlt, rst,
	MEM_ALU_OUT, MEM_Data_mem_out, MEM_rd_indzero, MEM_rd_ind, MEM_memread, MEM_regwrite, MEM_opcode,
	WB_ALU_OUT, WB_Data_mem_out, WB_rd_indzero, WB_rd_ind, WB_memread, WB_regwrite,
);


WB_stage wb_stage(WB_Data_mem_out, WB_ALU_OUT, WB_memread, wdata_to_reg_file);				

assign PC = IF_pc;


endmodule