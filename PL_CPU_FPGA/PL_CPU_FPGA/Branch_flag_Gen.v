
module Branch_flag_Gen(Rs1 , Rs2 , eq, ne, lt, le, gt, ge);
parameter bit_width = 32;

input [bit_width-1:0] Rs1 , Rs2;
output eq, ne, lt, le, gt, ge;


assign eq = (Rs1 == Rs2) ? 1'b1 : 1'b0;
assign ne = (Rs1 != Rs2) ? 1'b1 : 1'b0;
assign lt = ($signed(Rs1) < $signed(Rs2)) ? 1'b1 : 1'b0;
assign le = ($signed(Rs1) <= $signed(Rs2)) ? 1'b1 : 1'b0;
assign gt = ($signed(Rs1) > $signed(Rs2)) ? 1'b1 : 1'b0;
assign ge = ($signed(Rs1) >= $signed(Rs2)) ? 1'b1 : 1'b0;


endmodule