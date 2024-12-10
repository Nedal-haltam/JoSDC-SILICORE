module forwardA
(
	idhaz, exhaz, memhaz,	
	alu_selA
);

output [1:0] alu_selA;

input idhaz, exhaz, memhaz;


assign alu_selA[0] = idhaz || (memhaz && ~exhaz);
assign alu_selA[1] = idhaz || exhaz;

endmodule
