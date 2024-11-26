module BranchDecision(
    oper1, oper2, BranchDecision,
    is_beq, is_bne, is_blt, is_ble, is_bgt, is_bge
    );

input [31:0] oper1, oper2;
input is_beq, is_bne, is_blt, is_ble, is_bgt, is_bge;

output BranchDecision;

wire is_beq_taken, is_bne_taken, is_blt_taken, is_ble_taken, is_bgt_taken, is_bge_taken;
wire is_eq, is_lt;

compare_equal cmp1(is_eq, oper1, oper2);
compare_lt cmp2(is_lt, oper1, oper2);
// assign is_eq = oper1 == oper2;
// assign is_lt = $signed(oper1) < $signed(oper2);

assign is_beq_taken = is_beq &&  (is_eq);
assign is_bne_taken = is_bne && ~(is_eq);
assign is_blt_taken = is_blt &&  (is_lt);
assign is_ble_taken = is_ble &&  (is_lt || is_eq);
assign is_bgt_taken = is_bgt && ~(is_lt || is_eq);
assign is_bge_taken = is_bge && ~(is_lt);

assign BranchDecision = is_beq_taken || is_bne_taken || is_blt_taken || is_ble_taken || is_bgt_taken || is_bge_taken;


endmodule