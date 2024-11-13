

module MUX_8x1(ina , inb , inc , ind , ine , inf , ing , inh, sel, out);
parameter bit_with = 32;
input [bit_with-1:0] ina , inb , inc , ind , ine , inf , ing , inh;
input [2:0] sel;

output reg [bit_with-1:0] out;

always@ (*) begin

case (sel)

    3'b000: out <= ina;

    3'b001: out <= inb;
    
    3'b010: out <= inc;
    
    3'b011: out <= ind;
    
    3'b100: out <= ine;

    3'b101: out <= inf;
    
    3'b110: out <= ing;
    
    3'b111: out <= inh;
    
endcase
end 
endmodule