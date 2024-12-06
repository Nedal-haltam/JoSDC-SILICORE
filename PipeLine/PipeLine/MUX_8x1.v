
module BITWISEand3(out, in1, in2, in3);

input [31:0] in1, in2, in3;
output [31:0] out;

assign out = in1 & in2 & in3;

endmodule

module MUX_8x1(ina , inb , inc , ind , ine , inf , ing , inh, sel, out);
parameter bit_with = 32;
input [bit_with-1:0] ina , inb , inc , ind , ine , inf , ing , inh;
input [2:0] sel;

output [bit_with-1:0] out;

wire [31:0] s0, s1, s2, s3, s4, s5, s6, s7;




BITWISEand3 sel0(s0, {32{~sel[2]}} , {32{~sel[1]}}  , {32{~sel[0]}});
BITWISEand3 sel1(s1, {32{~sel[2]}} , {32{~sel[1]}}  , {32{sel[0]}} );
BITWISEand3 sel2(s2, {32{~sel[2]}} , {32{sel[1]}}   , {32{~sel[0]}} );
BITWISEand3 sel3(s3, {32{~sel[2]}} , {32{sel[1]}}   , {32{sel[0]}}  );
BITWISEand3 sel4(s4, {32{sel[2]}}  ,  {32{~sel[1]}} , {32{~sel[0]}});
BITWISEand3 sel5(s5, {32{sel[2]}}  ,  {32{~sel[1]}} , {32{sel[0]}} );
BITWISEand3 sel6(s6, {32{sel[2]}}  ,  {32{sel[1]}}  , {32{~sel[0]}} );
BITWISEand3 sel7(s7, {32{sel[2]}}  ,  {32{sel[1]}}  , {32{sel[0]}}  );


assign out = (s0&ina) | (s1&inb) | (s2&inc) | (s3&ind) | (s4&ine) | (s5&inf) | (s6&ing) | (s7&inh); 


endmodule