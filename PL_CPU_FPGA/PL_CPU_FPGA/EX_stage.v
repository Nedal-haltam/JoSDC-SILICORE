

module EX_stage(pc, opcode, ex_haz, mem_haz, rs1, imm, rs1_ind, rs2_ind, alu_selA, alu_selB, store_rs2_forward, reg_write, mem_read, mem_write, rs2_in, rs2_out, alu_out);
	
	input [31:0] pc, ex_haz, mem_haz, rs1, imm;
	input [6:0] opcode;
	input [4:0] rs1_ind, rs2_ind;
    input [1:0] alu_selA, store_rs2_forward;
	input [2:0] alu_selB;
	
	inout reg_write, mem_read, mem_write;
    input [31:0] rs2_in;
	
    output [31:0] alu_out, rs2_out; 
  
	wire [31:0] oper1, oper2;
	wire [3:0] alu_op;
	wire ZF, CF;
	
	MUX_4x1 alu_oper1(pc, ex_haz, mem_haz, rs1, alu_selA, oper1);
	
    MUX_8x1 alu_oper2(imm , 32'd1, ex_haz, mem_haz , rs2_in, 0,0,0, alu_selB, oper2);
	
	ALU alu(oper1, oper2, alu_out, ZF, CF, alu_op);

    ALU_OPER alu_oper(opcode, alu_op);

    MUX_4x1 store_rs2_mux(rs2_in, ex_haz, mem_haz, 32'd0, store_rs2_forward, rs2_out);
  	
endmodule