`include "CLA_Adder.v"

module CLA_Adder_tb;
reg [31:0] operand1;
reg [31:0] operand2;
reg operation;
wire [31:0] result;

CLA_Adder DUT(
    .operand1(operand1),
    .operand2(operand2),
    .operation(operation),
    .result(result)
);

initial begin
    operand1 = 32'hAAAA34A; operand2 = 32'h14; operation = 1'b0;
    #1000
    $display("%d %b %d = %d", $signed(operand1), operation, $signed(operand2), $signed(result));

    operand1 = -32'hA; operand2 = 32'hBC; operation = 1'b0;
    #1000
    $display("%d %b %d = %d", $signed(operand1), operation, $signed(operand2), $signed(result));

    operand1 = 32'h1A; operand2 = -32'hB; operation = 1'b0;
    #1000
    $display("%d %b %d = %d", $signed(operand1), operation, $signed(operand2), $signed(result));

    operand1 = 32'hA; operand2 = -32'h7ABFC623; operation = 1'b0;
    #1000
    $display("%d %b %d = %d", $signed(operand1), operation, $signed(operand2), $signed(result));

    operand1 = -32'hA; operand2 = 32'h1; operation = 1'b0;
    #1000
    $display("%d %b %d = %d", $signed(operand1), operation, $signed(operand2), $signed(result));

    operand1 = 32'h1B4BFA52; operand2 = 32'h341; operation = 1'b1;
    #1000
    $display("%d %b %d = %d", $signed(operand1), operation, $signed(operand2), $signed(result));

    operand1 = 32'h52; operand2 = 32'h341; operation = 1'b1;
    #1000
    $display("%d %b %d = %d", $signed(operand1), operation, $signed(operand2), $signed(result));

    operand1 = 32'h5432; operand2 = -32'h13341; operation = 1'b1;
    #1000
    $display("%d %b %d = %d", $signed(operand1), operation, $signed(operand2), $signed(result));

    operand1 = -32'h32; operand2 = -32'hFFFFFF; operation = 1'b1;
    #1000
    $display("%d %b %d = %d", $signed(operand1), operation, $signed(operand2), $signed(result));
end
endmodule