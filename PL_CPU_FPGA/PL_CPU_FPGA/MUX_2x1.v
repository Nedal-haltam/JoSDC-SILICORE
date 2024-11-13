module MUX_2x1(ina , inb , sel , out);

input [31:0] ina , inb;
input sel;

output reg [31:0] out;

always@ (*)
    case(sel)
        1'b0: out <= ina;
        1'b1: out <= inb;
    endcase

endmodule