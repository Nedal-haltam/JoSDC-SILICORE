module MUX_4x1(ina, inb, inc, ind, sel, out);
parameter bit_width = 32;
input [bit_width-1:0] ina , inb , inc , ind; 
input [1:0] sel;

output reg [bit_width-1:0] out;

always@ (*) begin

case (sel)

    2'b00: out <= ina;

    2'b01: out <= inb;
    
    2'b10: out <= inc;
    
    2'b11: out <= ind;
    
endcase
end
endmodule