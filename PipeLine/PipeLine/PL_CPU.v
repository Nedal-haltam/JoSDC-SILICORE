
module PL_CPU(PC, input_clk, rst, cycles_consumed);


input input_clk, rst;
output [31:0] PC;
output reg [31:0] cycles_consumed;

parameter handler_addr = 32'd1000;


wire clk, hlt;


wire [31:0] IF_pc, IF_INST;
wire [2:0]  pc_src;
wire if_id_write;

wire [31:0] ID_PFC_to_IF, ID_PFC_to_EX, ID_PC, ID_INST, ID_rs1, ID_rs2, ID_forward_to_B;
wire [11:0]  ID_opcode;
wire [4:0]  ID_rs1_ind, ID_rs2_ind, ID_rd_ind;
wire ID_regwrite, ID_memread, ID_memwrite, ID_is_oper2_immed, ID_predicted;

wire [31:0] EX_PFC, EX_ALU_OUT, EX_PC, EX_PFC_to_IF, EX_rs1, EX_rs2, EX_rs2_out, EX_forward_to_B;
wire [11:0] EX_opcode;
wire [4:0] EX_rd_ind, EX_rs1_ind, EX_rs2_ind;
wire [1:0]  alu_selA, alu_selB, store_rs2_forward;
wire EX_regwrite, EX_memread, EX_memwrite, EX_predicted, EX_is_oper2_immed;

wire [31:0] MEM_ALU_OUT, MEM_rs2, MEM_Data_mem_out;
wire [11:0] MEM_opcode;
wire [4:0]  MEM_rd_ind;
wire MEM_regwrite, MEM_memread, MEM_memwrite; 

wire [31:0] WB_ALU_OUT, WB_Data_mem_out, wdata_to_reg_file;
wire [4:0]  WB_rd_ind;
wire WB_memread, WB_regwrite;

wire pc_write, Wrong_prediction;


wire ID_is_beq, ID_is_bne, ID_is_jr, EX_is_jr, EX_is_beq, EX_is_bne, ID_is_jal, EX_is_jal, ID_is_j, 
	 is_branch_and_taken, MEM_rd_indzero, WB_rd_indzero;
wire STALL_IF_FLUSH, STALL_ID_FLUSH;


always@(negedge clk, posedge rst) begin
	if (rst)
		cycles_consumed <= 0;
	else
		cycles_consumed <= cycles_consumed + 32'd1;

end

 
nor hlt_logic(clk, input_clk, hlt);


forwardA FA(EX_opcode, EX_rs1_ind, EX_rs2_ind, MEM_rd_indzero, MEM_rd_ind, MEM_regwrite, WB_rd_indzero, WB_rd_ind, WB_regwrite,
		 	    alu_selA, clk, EX_is_jal);
		
forwardB FB(EX_opcode, EX_rs1_ind, EX_rs2_ind, MEM_rd_indzero, MEM_rd_ind, MEM_regwrite, WB_rd_indzero, WB_rd_ind, WB_regwrite,
		 	    alu_selB, EX_is_oper2_immed, clk, EX_is_jal);
		
forwardC FC(EX_opcode, EX_rs1_ind, EX_rs2_ind, MEM_rd_indzero, MEM_rd_ind, MEM_regwrite, WB_rd_indzero, WB_rd_ind, WB_regwrite,
		 	    store_rs2_forward, clk);
		




IF_stage #(.handler_addr(handler_addr))if_stage(ID_PFC_to_IF, EX_PFC_to_IF, pc_src, IF_pc, pc_write, clk, IF_INST, rst);


IF_ID_buffer if_id_buffer(IF_pc, IF_INST, STALL_IF_FLUSH, if_id_write, ~clk, ID_opcode, ID_rs1_ind, ID_rs2_ind, ID_rd_ind, ID_PC, ID_INST, rst); 



ID_stage id_stage
(
	ID_PC, ID_INST, ID_opcode, EX_opcode, EX_memread, wdata_to_reg_file, 
	ID_rs1_ind, ID_rs2_ind,
	EX_rd_ind, WB_rd_ind,
	STALL_ID_FLUSH, Wrong_prediction, 1'b0, clk, ID_PFC_to_IF, ID_PFC_to_EX, ID_predicted, ID_rs1, ID_rs2, pc_src,
	pc_write, if_id_write, STALL_IF_FLUSH, WB_regwrite, ID_regwrite, ID_memread, ID_memwrite, rst, ID_is_oper2_immed, 
	ID_is_beq, ID_is_bne, ID_is_jr, ID_is_jal, ID_is_j, is_branch_and_taken, ID_forward_to_B
);


ID_EX_buffer id_ex_buffer1
(
	~clk, (STALL_ID_FLUSH), rst,
	ID_opcode, ID_rs1_ind, ID_rs2_ind, ID_rd_ind, ID_PC, ID_rs1, ID_rs2, ID_regwrite, ID_memread, ID_memwrite, ID_PFC_to_EX, ID_predicted, ID_is_oper2_immed, ID_is_beq, ID_is_bne, ID_is_jr, ID_is_jal, ID_forward_to_B,
	EX_opcode, EX_rs1_ind, EX_rs2_ind, EX_rd_ind, EX_PC, EX_rs1, EX_rs2, EX_regwrite, EX_memread, EX_memwrite, EX_PFC, EX_predicted, EX_is_oper2_immed, EX_is_beq, EX_is_bne, EX_is_jr, EX_is_jal, EX_forward_to_B
);



ID_EX_buffer id_ex_buffer2
(
	~clk, (STALL_ID_FLUSH), rst,
	ID_opcode, ID_rs1_ind, ID_rs2_ind, ID_rd_ind, ID_PC, ID_rs1, ID_rs2, ID_regwrite, ID_memread, ID_memwrite, ID_PFC_to_EX, ID_predicted, ID_is_oper2_immed, ID_is_beq, ID_is_bne, ID_is_jr, ID_is_jal, ID_forward_to_B,
	EX_opcode, EX_rs1_ind, EX_rs2_ind, EX_rd_ind, EX_PC, EX_rs1, EX_rs2, EX_regwrite, EX_memread, EX_memwrite, EX_PFC, EX_predicted, EX_is_oper2_immed, EX_is_beq, EX_is_bne, EX_is_jr, EX_is_jal, EX_forward_to_B
);


EX_stage ex_stage
(
	EX_PC, EX_PFC, EX_PFC_to_IF, EX_opcode, MEM_ALU_OUT, wdata_to_reg_file, EX_rs1, EX_forward_to_B, 
	alu_selA, alu_selB, store_rs2_forward, 
	EX_rs2, EX_rs2_out, EX_ALU_OUT, EX_predicted, Wrong_prediction, rst, 
	EX_is_beq, EX_is_bne, EX_is_jr
);

			

EX_MEM_buffer ex_mem_buffer
(
	~clk, rst,
	EX_ALU_OUT, EX_rs2_out, EX_rd_ind != 0, EX_rd_ind, EX_opcode, EX_regwrite, EX_memread, EX_memwrite,
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