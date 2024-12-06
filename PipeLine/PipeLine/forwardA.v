
module forwardA(id_ex_opcode, id_ex_rs1, id_ex_rs2, 
					ex_mem_rdzero, ex_mem_rd, ex_mem_wr , mem_wb_rdzero, mem_wb_rd, mem_wb_wr, 
					forwardA, clk, is_jal
					);
parameter bit_width = 32;

`include "opcodes.txt"
// these might containg the funct for the I-format but we will stick the opcode just for naming simplicity
input [11:0] id_ex_opcode;

// forward to 2 places (aka stages)
input [4:0] id_ex_rs1, id_ex_rs2;				

// forward from 3 places (aka stages)
input [4:0] ex_mem_rd, mem_wb_rd; 

input ex_mem_wr, mem_wb_wr, ex_mem_rdzero, mem_wb_rdzero, clk, is_jal;

output [1:0] forwardA; // the selection lines for the ALU oprands mux
// output reg [1:0] forwardA; // the selection lines for the ALU oprands mux

// 0 -> defualt from register file
// 1 -> EXE HAZ
// 2 -> MEM HAZ
// 3 -> jal operandA
wire exhaz, memhaz;
assign exhaz = ex_mem_wr && ex_mem_rdzero && ex_mem_rd == id_ex_rs1;
assign memhaz = mem_wb_wr && mem_wb_rdzero && mem_wb_rd == id_ex_rs1;

assign forwardA[0] = is_jal || (memhaz && ~exhaz);
assign forwardA[1] = is_jal || exhaz;

// always@(posedge clk) begin

// forwardA[0] <= id_ex_opcode == jal || (memhaz && ~exhaz);
// forwardA[1] <= id_ex_opcode == jal || exhaz;

// end





endmodule
