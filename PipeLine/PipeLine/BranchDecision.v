module BranchDecision(
    oper1, oper2, BranchDecision,
    is_beq, is_bne
    );

input [31:0] oper1, oper2;
input is_beq, is_bne;

output BranchDecision;


wire is_beq_taken, is_bne_taken;
wire is_eq;

compare_equal cmp1(is_eq, oper1, oper2);

assign is_beq_taken = is_beq &&  (is_eq);
assign is_bne_taken = is_bne && ~(is_eq);

assign BranchDecision = is_beq_taken || is_bne_taken;


endmodule