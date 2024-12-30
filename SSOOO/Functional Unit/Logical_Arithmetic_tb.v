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
    reg [4:0] ROBEN_in;
    reg [2:0] operation;
    wire [31:0] result;
    wire [4:0] ROBEN_out;

    Logical_Arithmetic DUT(
        .operand1(operand1),
        .operand2(operand2),
        .shamt(shamt),
        .ROBEN_in(ROBEN_in),
        .operation(operation),
        .ROBEN_out(ROBEN_out),
        .result(result)
    );

    initial begin
        operand1 <= 32'hFF00FF00; operand2 <= 32'hF0F0F0F0; operation <= AND; shamt <= 5'b0100; ROBEN_in = 5'b1; #1 
        $display("%h AND (%d) %h = %h, ROBEN_out = %d", operand1, operation, operand2, result, ROBEN_out);
        #1 operation <= OR; ROBEN_in = 5'b10; #1
        $display("%h OR (%d) %h = %h, ROBEN_out = %d", operand1, operation, operand2, result, ROBEN_out);
        #1 operation <= XOR; ROBEN_in = 5'b11; #1
        $display("%h XOR (%d) %h = %h, ROBEN_out = %d", operand1, operation, operand2, result, ROBEN_out);
        #1 operation <= XNOR; ROBEN_in = 5'b100; #1
        $display("%h XNOR (%d) %h = %h, ROBEN_out = %d", operand1, operation, operand2, result, ROBEN_out);
        #1 operation <= SLL; ROBEN_in = 5'b101; #1
        $display("%h SLL (%d) %d = %h, ROBEN_out = %d", operand1, operation, shamt, result, ROBEN_out);
        #1 operation <= SRL; ROBEN_in = 5'b110; #1
        $display("%h SRL (%d) %d = %h, ROBEN_out = %d", operand1, operation, shamt, result, ROBEN_out);
        #1 operation <= SLT; ROBEN_in = 5'b111; #1
        $display("%h SLT (%d) %h = %h, ROBEN_out = %d", operand1, operation, operand2, result, ROBEN_out);
        #1 operand1 <= 32'h0F00FF00; operand2 <= 32'hF0F0F0F0; ROBEN_in = 5'b1000; #1
        $display("%h SLT (%d) %h = %h, ROBEN_out = %d", operand1, operation, operand2, result, ROBEN_out);

    end

endmodule
