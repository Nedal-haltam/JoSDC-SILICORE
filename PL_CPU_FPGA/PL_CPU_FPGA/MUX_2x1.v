module MUX_2x1(ina , inb , sel , out);

input [31:0] ina , inb;
input sel;


output reg [31:0] out;

wire [32*2:0] conc;
assign conc = { inb , ina };

always@ (ina, inb, sel)
    out <= conc[32*sel +: 32];

endmodule
