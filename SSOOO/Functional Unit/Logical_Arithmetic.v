module Logical_Arithmetic
# (parameter
    AND     = 3'b000,
    OR      = 3'b001,
    XOR     = 3'b010,
    XNOR    = 3'b011,
    SLL     = 3'b100,
    SRL     = 3'b101,
    SLT     = 3'b110
)

(   input [31:0] operand1,
    input [31:0] operand2,
    input [4:0]  shamt,
    input [4:0]  ROBEN_in,
    input [2:0]  operation,
    output reg [31:0] result,
    output [4:0] ROBEN_out
);

    // outputs ROBEN for the executed instruction
    assign ROBEN_out = ROBEN_in;
    
    always @ (*) begin
        case(operation)
        AND :   result <= operand1 &  operand2;
        OR  :   result <= operand1 |  operand2;
        XOR :   result <= operand1 ^  operand2;
        XNOR:   result <= operand1 ~^ operand2;
        SLL :   result <= operand1 << shamt;
        SRL :   result <= operand1 >> shamt;
        SLT :   result <= (operand1 < operand2) ? 32'b1 : 32'b0;
        endcase
    end

endmodule
