module MUX_2x1(ina , inb , sel , out);

input [31:0] ina , inb;
input sel;

output reg [31:0] out;

always@ (*)
    out = (!sel) ? ina : inb;

endmodule