
module forwardB(id_ex_opcode, id_ex_rs1, id_ex_rs2, 
					ex_mem_rdzero, ex_mem_rd, ex_mem_wr , mem_wb_rdzero, mem_wb_rd, mem_wb_wr, 
					forwardB, is_oper2_immed, clk, is_jal
					);
parameter bit_width = 32;

`include "opcodes.txt"

// these might containg the funct for the I-format but we will stick the opcode just for naming simplicity
input [11:0] id_ex_opcode;

// forward to 2 places (aka stages)
input [4:0] id_ex_rs1, id_ex_rs2;				

// forward from 3 places (aka stages)
input [4:0] ex_mem_rd, mem_wb_rd; 

input ex_mem_wr, mem_wb_wr, is_oper2_immed, ex_mem_rdzero, mem_wb_rdzero, clk, is_jal;

output [1:0] forwardB; // the selection lines for the ALU oprands mux

wire exhaz, memhaz;
assign exhaz = ex_mem_wr && ex_mem_rdzero && ex_mem_rd == id_ex_rs2;
assign memhaz = mem_wb_wr && mem_wb_rdzero && mem_wb_rd == id_ex_rs2;

// MUX_8x1 alu_oper2(rs2_in, mem_haz, ex_haz, 0, imm, imm, imm, 32'b1, alu_selB, oper2);
assign forwardB[0] = is_jal || (memhaz && ~exhaz);
assign forwardB[1] = (is_jal ||  exhaz) && ~is_oper2_immed;

// always@(posedge clk) begin

// forwardB[0] <= id_ex_opcode == jal || (memhaz && ~exhaz);
// forwardB[1] <= id_ex_opcode == jal ||  exhaz;
// forwardB[2] <= id_ex_opcode == jal ||  is_oper2_immed;

// end



endmodule
