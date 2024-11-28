`include "CLA_8_Block.v"

module adder_testbench;
reg [31:0] operand1;
reg [31:0] operand2;
reg operation;
wire [31:0] result;

CLA_8_Block DUT(
    .operand1(operand1),
    .operand2(operand2),
    .operation(operation),
    .result(result)
);

initial begin
    operand1 = 32'hA; operand2 = 32'h1; operation = 1'b1;
    #1000
    $display("%d %b %d = %d", operand1, operation, operand2, result);
end
endmodule
