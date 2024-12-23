`include "Logical_Arithmetic.v"
module Logical_Arithmetic_tb
# (parameter
    AND     = 3'b000,
    OR      = 3'b001,
    XOR     = 3'b010,
    XNOR    = 3'b011,
    SLL     = 3'b100,
    SRL     = 3'b101,
    SLT     = 3'b110
);
    reg [31:0] operand1;
    reg [31:0] operand2;
    reg [4:0] shamt;
    reg [2:0] operation;
    wire [31:0] result;

    Logical_Arithmetic DUT(
        .operand1(operand1),
        .operand2(operand2),
        .shamt(shamt),
        .operation(operation),
        .result(result)
    );

    initial begin
        operand1 <= 32'hFF00FF00; operand2 <= 32'hF0F0F0F0; operation <= AND; shamt <= 5'b0100; #1
        $display("%h AND (%d) %h = %h", operand1, operation, operand2, result);
        #1 operation <= OR; #1
        $display("%h OR (%d) %h = %h", operand1, operation, operand2, result);
        #1 operation <= XOR; #1
        $display("%h XOR (%d) %h = %h", operand1, operation, operand2, result);
        #1 operation <= XNOR; #1
        $display("%h XNOR (%d) %h = %h", operand1, operation, operand2, result);
        #1 operation <= SLL; #1
        $display("%h SLL (%d) %d = %h", operand1, operation, shamt, result);
        #1 operation <= SRL; #1
        $display("%h SRL (%d) %d = %h", operand1, operation, shamt, result);
        #1 operation <= SLT; #1
        $display("%h SLT (%d) %h = %h", operand1, operation, operand2, result);
        #1 operand1 <= 32'h0F00FF00; operand2 <= 32'hF0F0F0F0; #1
        $display("%h SLT (%d) %h = %h", operand1, operation, operand2, result);

    end

endmodule