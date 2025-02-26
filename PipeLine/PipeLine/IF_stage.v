module IF_stage
(
    ID_PFC, EX1_PFC, EX2_PFC, PC_src, inst_mem_in, PC_write, clk, inst, rst
);
	
input [31:0] ID_PFC, EX1_PFC, EX2_PFC;
input [2:0] PC_src;
input PC_write, clk, rst;

output [31:0] inst;
inout [31:0] inst_mem_in;

wire [31:0] pc_reg_in;


PC_src_mux pc_src_mux(inst_mem_in + 1'b1, ID_PFC, inst_mem_in, EX1_PFC, EX2_PFC, 0, 0, 0, PC_src, pc_reg_in);

PC_register pc_reg(pc_reg_in, inst_mem_in, PC_write, clk, rst); 

IM inst_mem(pc_reg_in, inst_mem_in , inst, clk);

endmodule
