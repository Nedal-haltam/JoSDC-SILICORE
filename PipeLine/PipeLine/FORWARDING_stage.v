module FORWARDING_stage
(
    rs1, id_haz, ex_haz, mem_haz, pc, alu_selA, oper1,
    EX1_forward_to_B, alu_selB, oper2,
    rs2_in, store_rs2_forward, rs2_out,
    is_jr, EX_PFC, EX_PFC_to_IF
);


    input [31:0] rs1, id_haz, ex_haz, mem_haz, pc;
    input [31:0] EX1_forward_to_B;
    input [31:0] rs2_in;
    input [31:0] EX_PFC;

    input [1:0] alu_selA, alu_selB, store_rs2_forward;
    input is_jr;

    output [31:0] oper1, oper2, rs2_out, EX_PFC_to_IF;


	MUX_4x1 alu_oper1(rs1, mem_haz, ex_haz, id_haz, alu_selA, oper1);
	
	MUX_4x1 alu_oper2(EX1_forward_to_B, mem_haz, ex_haz, id_haz, alu_selB, oper2);
	
    MUX_4x1 store_rs2_mux(rs2_in, mem_haz, ex_haz, id_haz, store_rs2_forward, rs2_out);

	assign EX_PFC_to_IF = (is_jr) ? oper1 : EX_PFC;


endmodule


