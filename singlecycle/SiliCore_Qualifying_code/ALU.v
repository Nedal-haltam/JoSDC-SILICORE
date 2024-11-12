module ALU (operand1, operand2, opSel, result, zero);
	
parameter data_width = 32;  
parameter sel_width = 4;
	
input [data_width - 1 : 0] operand1, operand2;  
input [sel_width - 1 : 0] opSel;                  

output reg [data_width - 1 : 0] result;  
output zero;                          

parameter ADD = 4'd0, SUB = 4'd1, AND = 4'd2, OR = 4'd3, XOR = 4'd4, NOR = 4'd5, SLT = 4'd6, SGT = 4'd7, SLL = 4'd8, SRL = 4'd9;

always @ (*) begin

  case(opSel)
    ADD: result <= operand1 + operand2;
    SUB: result <= operand1 - operand2;
    AND: result <= operand1 & operand2;
    OR : result <= operand1 | operand2;
    XOR: result <= operand1 ^ operand2; 
    NOR: result <= ~(operand1 | operand2);
    SLT: result <= ($signed(operand1) < $signed(operand2)) ? 32'b1 : 32'b0; 
    SGT: result <= ($signed(operand1) > $signed(operand2)) ? 32'b1 : 32'b0; 
    SLL: result <= operand1 << operand2;
    SRL: result <= operand1 >> operand2;

    default: result <= -1;
  endcase

end
	
	
assign zero = (result == 32'b0);

endmodule