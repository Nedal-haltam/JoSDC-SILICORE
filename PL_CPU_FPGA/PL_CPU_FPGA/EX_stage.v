


module compare_equal(out, a, b);

input [31:0] a, b;
output out;

wire [31:0] temp;

xor xor0(temp[0], a[0], b[0]);
xor xor1(temp[1], a[1], b[1]);
xor xor2(temp[2], a[2], b[2]);
xor xor3(temp[3], a[3], b[3]);
xor xor4(temp[4], a[4], b[4]);
xor xor5(temp[5], a[5], b[5]);
xor xor6(temp[6], a[6], b[6]);
xor xor7(temp[7], a[7], b[7]);
xor xor8(temp[8], a[8], b[8]);
xor xor9(temp[9], a[9], b[9]);
xor xor10(temp[10], a[10], b[10]);
xor xor11(temp[11], a[11], b[11]);
xor xor12(temp[12], a[12], b[12]);
xor xor13(temp[13], a[13], b[13]);
xor xor14(temp[14], a[14], b[14]);
xor xor15(temp[15], a[15], b[15]);
xor xor16(temp[16], a[16], b[16]);
xor xor17(temp[17], a[17], b[17]);
xor xor18(temp[18], a[18], b[18]);
xor xor19(temp[19], a[19], b[19]);
xor xor20(temp[20], a[20], b[20]);
xor xor21(temp[21], a[21], b[21]);
xor xor22(temp[22], a[22], b[22]);
xor xor23(temp[23], a[23], b[23]);
xor xor24(temp[24], a[24], b[24]);
xor xor25(temp[25], a[25], b[25]);
xor xor26(temp[26], a[26], b[26]);
xor xor27(temp[27], a[27], b[27]);
xor xor28(temp[28], a[28], b[28]);
xor xor29(temp[29], a[29], b[29]);
xor xor30(temp[30], a[30], b[30]);
xor xor31(temp[31], a[31], b[31]);

nor or1(out
, temp[0]
, temp[1], temp[2], temp[3], temp[4], temp[5], temp[6], temp[7], temp[8], temp[9], temp[10]
, temp[11], temp[12], temp[13], temp[14], temp[15], temp[16], temp[17], temp[18], temp[19], temp[20]
, temp[21], temp[22], temp[23], temp[24], temp[25], temp[26], temp[27], temp[28], temp[29], temp[30]
, temp[31]);


endmodule

module compare_lt_gt(lt, a, b);

input [31:0] a, b;
wire [31:0] temp;
output lt;

// assign lt = ($signed(a) < $signed(b)) ? 1'b1 : 1'b0;
and and0 (temp[0], ~a[0], b[0]);
and and1 (temp[1], ~a[1], b[1]);
and and2 (temp[2], ~a[2], b[2]);
and and3 (temp[3], ~a[3], b[3]);
and and4 (temp[4], ~a[4], b[4]);
and and5 (temp[5], ~a[5], b[5]);
and and6 (temp[6], ~a[6], b[6]);
and and7 (temp[7], ~a[7], b[7]);
and and8 (temp[8], ~a[8], b[8]);
and and9 (temp[9], ~a[9], b[9]);
and and10(temp[10], ~a[10], b[10]);
and and11(temp[11], ~a[11], b[11]);
and and12(temp[12], ~a[12], b[12]);
and and13(temp[13], ~a[13], b[13]);
and and14(temp[14], ~a[14], b[14]);
and and15(temp[15], ~a[15], b[15]);
and and16(temp[16], ~a[16], b[16]);
and and17(temp[17], ~a[17], b[17]);
and and18(temp[18], ~a[18], b[18]);
and and19(temp[19], ~a[19], b[19]);
and and20(temp[20], ~a[20], b[20]);
and and21(temp[21], ~a[21], b[21]);
and and22(temp[22], ~a[22], b[22]);
and and23(temp[23], ~a[23], b[23]);
and and24(temp[24], ~a[24], b[24]);
and and25(temp[25], ~a[25], b[25]);
and and26(temp[26], ~a[26], b[26]);
and and27(temp[27], ~a[27], b[27]);
and and28(temp[28], ~a[28], b[28]);
and and29(temp[29], ~a[29], b[29]);
and and30(temp[30], ~a[30], b[30]);
// and and31(temp[31], a[31], ~b[31]);

wire ltw, ltww;
nor or1(ltw
, temp[0]
, temp[1], temp[2], temp[3], temp[4], temp[5], temp[6], temp[7], temp[8], temp[9], temp[10]
, temp[11], temp[12], temp[13], temp[14], temp[15], temp[16], temp[17], temp[18], temp[19], temp[20]
, temp[21], temp[22], temp[23], temp[24], temp[25], temp[26], temp[27], temp[28], temp[29], temp[30]
, a[31] & ~b[31] );

nor (ltww, ~a[31] & b[31], ltw);
xor (lt, ltww, a[31] &  b[31]);
// cases : 
// two  positive                 ~a[31] & ~b[31] ->      compare all the bits normally
// two  negative                  a[31] &  b[31] -> also compare all the bits normally with inversion at the end
// a is positive , b is negative ~a[31] &  b[31] ->      we directly conclude that a is not less than b
// a is negative , b is positive  a[31] & ~b[31] -> also we directly conclude that a is     less than b

endmodule


module EX_stage(pc, EX_PFC, EX_PFC_to_IF, opcode, ex_haz, mem_haz, rs1, imm, rs1_ind, rs2_ind, alu_selA, alu_selB, store_rs2_forward, 
			    reg_write, mem_read, mem_write, rs2_in, rs2_out, alu_out, predicted, Wrong_prediction, rst, is_beq, is_bne, is_blt, is_ble, is_bgt, is_bge, EX_rd_indzero, EX_rd_ind);
	
`include "opcodes.txt"

	input [31:0] pc, EX_PFC, ex_haz, mem_haz, rs1, imm;
	input [6:0] opcode;
	input [4:0] rs1_ind, rs2_ind, EX_rd_ind;
    input [1:0] alu_selA, store_rs2_forward;
	input [2:0] alu_selB;
	
	input reg_write, mem_read, mem_write, predicted, rst, is_beq, is_bne, is_blt, is_ble, is_bgt, is_bge;
    input [31:0] rs2_in;
	
    output [31:0] alu_out, rs2_out, EX_PFC_to_IF; 
	output Wrong_prediction, EX_rd_indzero;
  
	wire [31:0] oper1, oper2;
	wire [3:0] alu_op;
	wire ZF, CF;
	
	assign EX_rd_indzero = EX_rd_ind != 0;
	MUX_4x1 alu_oper1(rs1, mem_haz, ex_haz, pc, alu_selA, oper1);
	
	
	MUX_8x1 alu_oper2(rs2_in, mem_haz, ex_haz, 0, imm, imm, imm, 32'b1, alu_selB, oper2);
    // MUX_8x1 alu_oper2(imm , 32'b1, ex_haz, mem_haz , rs2_in, 0,0,0, alu_selB, oper2);
	
	ALU alu(oper1, oper2, alu_out, ZF, CF, alu_op);

    ALU_OPER alu_oper(opcode, alu_op);

	assign EX_PFC_to_IF = (opcode == jr) ? oper1 : EX_PFC;

    MUX_4x1 store_rs2_mux(rs2_in, ex_haz, mem_haz, 0, store_rs2_forward, rs2_out);

	// here we assume branch is alyaws taken so we check if our prediction is wrong or not.
	// so the Wrong_prediction will be high if we are wrong

	wire is_eq, is_lt;
	wire BranchDecision;
	// TODO: make faster comparison logic instead of default `equal` block of the FPGA 

	compare_equal cmp1(is_eq, oper1, oper2);
	compare_lt_gt cmp2(is_lt, oper1, oper2);
	// assign is_eq = oper1 == oper2;
	// assign is_lt = $signed(oper1) < $signed(oper2);
	assign is_beq_taken = is_beq &&  (is_eq);
	assign is_bne_taken = is_bne && ~(is_eq);
	assign is_blt_taken = is_blt &&  (is_lt);
	assign is_ble_taken = is_ble &&  (is_lt || is_eq);
	assign is_bgt_taken = is_bgt && ~(is_lt || is_eq);
	assign is_bge_taken = is_bge && ~(is_lt);

	assign BranchDecision = is_beq_taken || is_bne_taken || is_blt_taken || is_ble_taken || is_bgt_taken || is_bge_taken;

	assign Wrong_prediction = ~(rst || BranchDecision == predicted);

endmodule