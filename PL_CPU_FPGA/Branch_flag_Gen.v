
module Branch_flag_Gen(Rs1 , Rs2 , eq , neq , lt, gteq);
parameter bit_width = 32;

input [bit_width-1:0] Rs1 , Rs2;
output eq, neq, lt, gteq;


assign eq = (Rs1 == Rs2) ? 1'b1 : 1'b0;
assign neq = (Rs1 != Rs2) ? 1'b1 : 1'b0;
assign lt = ($signed(Rs1) < $signed(Rs2)) ? 1'b1 : 1'b0;
assign gte = ($signed(Rs1) >= $signed(Rs2)) ? 1'b1 : 1'b0;


endmodule