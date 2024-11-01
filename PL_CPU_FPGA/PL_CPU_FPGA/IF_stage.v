module IF_stage#(
    parameter handler_addr = 32'h0000_00FE	
)
(pfc, pc_src, inst_mem_in, pc_write, clk, inst, rst);
	
input [31:0] pfc;
input [1:0] pc_src;
input pc_write, clk;
output [31:0] inst;
input rst;
inout [31:0] inst_mem_in;

wire [31:0] pc_next, pc_reg_in, out;


MUX_4x1 pc_src_mux(pc_next, handler_addr, pfc, inst_mem_in, pc_src, pc_reg_in);

PC_register pc_reg(pc_reg_in, inst_mem_in, pc_write, clk, rst); 

IM inst_mem(inst_mem_in , inst);

Branch_or_Jump_TargGen new_PC(inst_mem_in , 32'd1 , pc_next);
  
    	
	
endmodule
