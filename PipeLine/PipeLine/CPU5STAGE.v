
module CPU5STAGE(PC, input_clk, rst, cycles_consumed);


input input_clk, rst;
output [31:0] PC;
output reg [31:0] cycles_consumed;

parameter handler_addr = 32'd1000;


wire clk, hlt;
wire [31:0] ID_PFC_to_IF, ID_PFC_to_EX, EX_PFC, IF_pc, IF_INST, ID_PC, ID_INST, alu_out, forwarded_data, wdata_to_reg_file, ID_rs1, ID_rs2, ID_Immed, EX_PC, EX_INST, EX_Immed, EX_PFC_to_IF;
wire [31:0] EX_rs1, EX_rs2, MEM_PC, MEM_INST, WB_PC, WB_INST, MEM_ALU_OUT, MEM_rs2, MEM_Data_mem_out, WB_ALU_OUT, WB_rs2, WB_Data_mem_out, ID_rs1_ind_test, MEM_ALU_OUT_test, rs2_out, ID_forward_to_B, EX_forward_to_B;
wire [11:0]  ID_opcode, EX_opcode, MEM_opcode, WB_opcode;
wire [4:0]  ID_rs1_ind, ID_rs2_ind, ID_rd_ind, EX_rd_ind, EX_rs1_ind, EX_rs2_ind, MEM_rs1_ind, MEM_rs2_ind, MEM_rd_ind, WB_rs1_ind, WB_rs2_ind, WB_rd_ind;
wire [2:0]  pc_src, target_addr_adder_mux_sel;
wire [1:0]  comp_selA, comp_selB, alu_selA, store_rs2_forward, alu_selB;
wire pc_write, if_id_write, EX_memread, ID_regwrite, ID_memread, ID_memwrite, EX_regwrite, EX_memwrite, MEM_memread, Wrong_prediction, predicted;
wire MEM_memwrite, MEM_regwrite, WB_memread, WB_memwrite, WB_regwrite, exception_flag, ID_is_oper2_immed, EX_is_oper2_immed; 
wire ID_is_beq, ID_is_bne, ID_is_jr, EX_is_jr, EX_is_beq, EX_is_bne, ID_is_jal, EX_is_jal, ID_is_j, is_branch_and_taken, MEM_rd_indzero, WB_rd_indzero;

wire STALL_IF_FLUSH, STALL_ID_FLUSH;
wire EXCEP_IF_FLUSH, EXCEP_ID_FLUSH, EXCEP_EX_FLUSH, EXCEP_MEM_FLUSH;


always@(negedge clk, posedge rst) begin
	if (rst)
		cycles_consumed <= 0;
	else
		cycles_consumed <= cycles_consumed + 32'd1;

end

 
nor hlt_logic(clk, input_clk, hlt);

exception_detect_unit EDU(is_branch_and_taken, ID_is_j, ID_is_jal, ID_PFC_to_IF, EX_PFC_to_IF, exception_flag, EXCEP_IF_FLUSH, EXCEP_ID_FLUSH, EXCEP_EX_FLUSH, EXCEP_MEM_FLUSH, clk, rst);

forwardA FA(EX_opcode, EX_rs1_ind, EX_rs2_ind, MEM_rd_indzero, MEM_rd_ind, MEM_regwrite, WB_rd_indzero, WB_rd_ind, WB_regwrite,
		 	    alu_selA, clk, EX_is_jal);
		
forwardB FB(EX_opcode, EX_rs1_ind, EX_rs2_ind, MEM_rd_indzero, MEM_rd_ind, MEM_regwrite, WB_rd_indzero, WB_rd_ind, WB_regwrite,
		 	    alu_selB, EX_is_oper2_immed, clk, EX_is_jal);
		
forwardC FC(EX_opcode, EX_rs1_ind, EX_rs2_ind, MEM_rd_indzero, MEM_rd_ind, MEM_regwrite, WB_rd_indzero, WB_rd_ind, WB_regwrite,
		 	    store_rs2_forward, clk);
		





IF_stage #(.handler_addr(handler_addr))if_stage(ID_PFC_to_IF, EX_PFC_to_IF, pc_src, IF_pc, pc_write, clk, IF_INST, rst);




IF_ID_buffer if_id_buffer(IF_pc, IF_INST, STALL_IF_FLUSH, if_id_write, ~clk, ID_opcode, ID_rs1_ind, ID_rs2_ind, ID_rd_ind, ID_PC, ID_INST, rst); 


ID_stage id_stage(ID_PC, ID_INST, ID_opcode, EX_opcode, EX_memread, alu_out, forwarded_data, wdata_to_reg_file, wdata_to_reg_file, 
	ID_rs1_ind, ID_rs2_ind,
	EX_rd_ind, WB_rd_ind,
	STALL_ID_FLUSH, Wrong_prediction, exception_flag, clk, ID_PFC_to_IF, ID_PFC_to_EX, ID_predicted, ID_rs1, ID_rs2, pc_src,
	pc_write, if_id_write, STALL_IF_FLUSH, ID_Immed, WB_regwrite, ID_regwrite, ID_memread, ID_memwrite, rst, ID_is_oper2_immed, 
	ID_is_beq, ID_is_bne, ID_is_jr, ID_is_jal, ID_is_j, is_branch_and_taken, ID_forward_to_B);



ID_EX_buffer id_ex_buffer(ID_opcode, ID_rs1_ind, ID_rs2_ind, ID_rd_ind,
			ID_PC, ID_INST, ID_Immed, ID_rs1, ID_rs2, ID_regwrite,
			ID_memread, ID_memwrite, ~clk, (EXCEP_ID_FLUSH | STALL_ID_FLUSH), ID_PFC_to_EX, ID_predicted, ID_is_oper2_immed, ID_is_beq, ID_is_bne, ID_is_jr, ID_is_jal,
			ID_forward_to_B,
			EX_opcode, EX_rs1_ind,
			EX_rs2_ind, EX_rd_ind, EX_PC,
			EX_INST, EX_Immed, EX_rs1,
			EX_rs2, EX_regwrite, EX_memread, EX_memwrite, EX_PFC, EX_predicted, 
			EX_is_oper2_immed, rst, EX_is_beq, EX_is_bne, EX_is_jr, EX_is_jal, EX_forward_to_B);

EX_stage ex_stage(EX_PC, EX_PFC, EX_PFC_to_IF, EX_opcode, MEM_ALU_OUT, wdata_to_reg_file, EX_rs1, EX_forward_to_B, EX_rs1_ind, EX_rs2_ind, 
	alu_selA, alu_selB, store_rs2_forward, EX_regwrite, EX_memread, EX_memwrite, EX_rs2, rs2_out, alu_out, EX_predicted, Wrong_prediction, rst, 
	EX_is_beq, EX_is_bne, EX_is_jr, EX_rd_indzero, EX_rd_ind);






			
EX_MEM_buffer ex_mem_buffer(alu_out, rs2_out, EX_rs1_ind, EX_rs2_ind, EX_rd_indzero, EX_rd_ind,
			 EX_PC, EX_INST, EX_opcode, EX_memread, EX_memwrite, EX_regwrite, EXCEP_EX_FLUSH, ~clk,
			 MEM_ALU_OUT, MEM_rs2, MEM_rs1_ind, MEM_rs2_ind,
			 MEM_rd_indzero, MEM_rd_ind, MEM_PC, MEM_INST, MEM_opcode, MEM_memread, MEM_memwrite, MEM_regwrite, rst);					 

MEM_stage mem_stage(MEM_ALU_OUT, MEM_rs2, MEM_memwrite, MEM_memread, MEM_regwrite, MEM_Data_mem_out, clk);





MEM_WB_buffer mem_wb_buffer(MEM_ALU_OUT, MEM_rs2, MEM_Data_mem_out, MEM_rs1_ind, MEM_rs2_ind, MEM_rd_indzero, MEM_rd_ind,MEM_PC, MEM_INST, MEM_opcode,
			 MEM_memread, MEM_memwrite, MEM_regwrite, EXCEP_MEM_FLUSH, ~clk,
			 WB_ALU_OUT, WB_rs2, WB_Data_mem_out, WB_rs1_ind, WB_rs2_ind,
			 WB_rd_indzero, WB_rd_ind, WB_PC, WB_INST, WB_opcode, WB_memread, WB_memwrite, WB_regwrite, hlt, rst);
			 
WB_stage wb_stage(WB_Data_mem_out, WB_ALU_OUT, WB_memread, wdata_to_reg_file);				

assign PC = IF_pc;


endmodule