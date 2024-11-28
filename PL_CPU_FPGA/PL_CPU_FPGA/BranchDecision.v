module BranchDecision(
    oper1, oper2, BranchDecision,
    is_beq, is_bne
    );

input [31:0] oper1, oper2;
input is_beq, is_bne, is_blt, is_ble, is_bgt, is_bge;

output BranchDecision;

wire is_beq_taken, is_bne_taken, is_blt_taken, is_ble_taken, is_bgt_taken, is_bge_taken;
wire is_eq, is_lt;

compare_equal cmp1(is_eq, oper1, oper2);
// assign is_eq = oper1 == oper2;

assign is_beq_taken = is_beq &&  (is_eq);
assign is_bne_taken = is_bne && ~(is_eq);

assign BranchDecision = is_beq_taken || is_bne_taken;


endmodule