

module EX_stage(pc, EX_PFC, EX_PFC_to_IF, opcode, ex_haz, mem_haz, rs1, imm, rs1_ind, rs2_ind, alu_selA, alu_selB, store_rs2_forward, 
			    reg_write, mem_read, mem_write, rs2_in, rs2_out, alu_out, predicted, Wrong_prediction, rst, is_beq, is_bne, EX_rd_indzero, EX_rd_ind);
	
	`include "opcodes.v"


	input [31:0] pc, EX_PFC, ex_haz, mem_haz, rs1, imm;
	input [6:0] opcode;
	input [4:0] rs1_ind, rs2_ind, EX_rd_ind;
    input [1:0] alu_selA, store_rs2_forward;
	input [2:0] alu_selB;
	
	input reg_write, mem_read, mem_write, predicted, rst, is_beq, is_bne;
    input [31:0] rs2_in;
	
    output [31:0] alu_out, rs2_out, EX_PFC_to_IF; 
	output Wrong_prediction, EX_rd_indzero;
  
	wire [31:0] oper1, oper2;
	wire [3:0] alu_op;
	wire ZF, CF;
	
	assign EX_rd_indzero = EX_rd_ind != 0;
	MUX_4x1 alu_oper1(pc, ex_haz, mem_haz, rs1, alu_selA, oper1);
	
    MUX_8x1 alu_oper2(imm , 32'b1, ex_haz, mem_haz , rs2_in, 0,0,0, alu_selB, oper2);
	
	ALU alu(oper1, oper2, alu_out, ZF, CF, alu_op);

    ALU_OPER alu_oper(opcode, alu_op);

	assign EX_PFC_to_IF = (opcode == jr) ? oper1 : EX_PFC;

    MUX_4x1 store_rs2_mux(rs2_in, ex_haz, mem_haz, 0, store_rs2_forward, rs2_out);

	// here we assume branch is alyaws taken so we check if our prediction is wrong or not.
	// so the Wrong_prediction will be high if we are wrong

	wire temp2, temp3;
	wire BranchDecision;
	// TODO: make faster comparison logic instead of default `equal` block of the FPGA 
	assign temp2 = is_beq && oper1 == oper2;
	assign temp3 = is_bne && oper1 != oper2;
	assign BranchDecision = temp2 || temp3;

	// always@(*) begin
	// 	case(opcode)
	// 		j, jal:      BranchDecision <= 1'b1;
	// 		beq: 		 BranchDecision <= oper1 == oper2;
	// 		bne: 		 BranchDecision <= oper1 != oper2;
	// 		default:     BranchDecision <= 0;
	// 	endcase
	// end

	assign Wrong_prediction = (rst || BranchDecision == predicted) ? 0 : 1'b1;

endmodule