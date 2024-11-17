
module BITWISEand2(out, in1, in2);

input [31:0] in1, in2;
output [31:0] out;

assign out = in1 & in2;

endmodule

module MUX_4x1(ina, inb, inc, ind, sel, out);
parameter bit_width = 32;
input [bit_width-1:0] ina , inb , inc , ind; 
input [1:0] sel;

output [bit_width-1:0] out;

wire [31:0] s0, s1, s2, s3;

BITWISEand2 sel0(s0, {32{~sel[1]}} , {32{~sel[0]}});
BITWISEand2 sel1(s1, {32{~sel[1]}} , {32{sel[0]}} );
BITWISEand2 sel2(s2, {32{sel[1]}} , {32{~sel[0]}} );
BITWISEand2 sel3(s3, {32{sel[1]}} , {32{sel[0]}}  );

assign out = (s0&ina) | (s1&inb) | (s2&inc) | (s3&ind);

endmodule