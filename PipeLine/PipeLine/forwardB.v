module forwardB
(
	idhaz, exhaz, memhaz,
	alu_selB, EX1_is_oper2_immed
);

input EX1_is_oper2_immed;

output [1:0] alu_selB;

input idhaz, exhaz, memhaz;

assign alu_selB[0] =  (idhaz || (memhaz && ~exhaz)) && ~EX1_is_oper2_immed;
assign alu_selB[1] = (idhaz ||  exhaz) && ~EX1_is_oper2_immed;

endmodule
