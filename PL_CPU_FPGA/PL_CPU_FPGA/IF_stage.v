module IF_stage#(
    parameter handler_addr = 32'd1000
)
(ID_PFC, EX_PFC, pc_src, inst_mem_in, pc_write, clk, inst, rst);
	
input [31:0] ID_PFC, EX_PFC;
input [2:0] pc_src;
input pc_write, clk;
output [31:0] inst;
input rst;
inout [31:0] inst_mem_in;

wire [31:0] pc_next, pc_reg_in, out;


MUX_8x1 pc_src_mux(pc_next, handler_addr, ID_PFC, inst_mem_in, EX_PFC, 0, 0, 0, pc_src, pc_reg_in);

PC_register pc_reg(pc_reg_in, inst_mem_in, pc_write, clk, rst); 

IM inst_mem(pc_reg_in, inst_mem_in , inst, clk);

assign pc_next = inst_mem_in + 1'b1;
	
endmodule
