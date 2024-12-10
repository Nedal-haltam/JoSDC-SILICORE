module forwardC
(
	idhaz, exhaz, memhaz,
	store_rs2_forward
);

output [1:0] store_rs2_forward;

input idhaz, exhaz, memhaz;

assign store_rs2_forward[0] = idhaz || (memhaz && ~exhaz);
assign store_rs2_forward[1] = idhaz || exhaz;

endmodule
