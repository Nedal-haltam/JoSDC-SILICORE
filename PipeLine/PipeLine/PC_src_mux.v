module PC_src_mux(ina , inb , inc , ind , ine , inf , ing , inh, sel, out);
parameter bit_with = 32;
input [bit_with-1:0] ina , inb , inc , ind , ine , inf , ing , inh;
input [2:0] sel;

output [bit_with-1:0] out;

wire [31:0] s0, s1, s2, s3, s4;



assign out = 
(({32{(~sel[2]&~sel[1]&~sel[0])}})&ina) | 
(({32{(~sel[2]&~sel[1]&sel[0])}})&inb) | 
(({32{(~sel[2]&sel[1]&~sel[0])}})&inc) | 
(({32{(~sel[2]&sel[1]&sel[0])}})&ind) | 
(({32{(sel[2]&~sel[1]&~sel[0])}})&ine);

endmodule