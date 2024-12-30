`include "CLA_Adder.v"

module CLA_Adder_tb;
reg [31:0] operand1, operand2;
reg [ 4:0] ROBEN_in;
reg operation;
wire [31:0] result;
wire [ 4:0] ROBEN_out;
wire flow;

CLA_Adder DUT(
    .operand1(operand1),
    .operand2(operand2),
    .ROBEN_in(ROBEN_in),
    .operation(operation),
    .result(result),
    .ROBEN_out(ROBEN_out),
    .flow(flow)
);

initial begin
    operand1 = 32'hAAAA34A; operand2 = 32'h14; ROBEN_in = 5'b00100; operation = 1'b0;
    #1000
    $display("ROBEN_out = ", ROBEN_out);
    $display("%d %b %d = %d, flow = %b", $signed(operand1), operation, $signed(operand2), $signed(result), flow);

    operand1 = -32'hA; operand2 = 32'hBC; operation = 1'b0;
    #1000
    $display("ROBEN_out = ", ROBEN_out);
    $display("%d %b %d = %d, flow = %b", $signed(operand1), operation, $signed(operand2), $signed(result), flow);

    operand1 = 32'h1A; operand2 = -32'hB; operation = 1'b0;
    #1000
    $display("ROBEN_out = ", ROBEN_out);
    $display("%d %b %d = %d, flow = %b", $signed(operand1), operation, $signed(operand2), $signed(result), flow);

    operand1 = 32'hA; operand2 = -32'h7ABFC623; operation = 1'b0;
    #1000
    $display("ROBEN_out = ", ROBEN_out);
    $display("%d %b %d = %d, flow = %b", $signed(operand1), operation, $signed(operand2), $signed(result), flow);

    operand1 = -32'hA; operand2 = 32'h1; operation = 1'b0;
    #1000
    $display("ROBEN_out = ", ROBEN_out);
    $display("%d %b %d = %d, flow = %b", $signed(operand1), operation, $signed(operand2), $signed(result), flow);

    operand1 = 32'h1B4BFA52; operand2 = 32'h341; operation = 1'b1;
    #1000
    $display("ROBEN_out = ", ROBEN_out);
    $display("%d %b %d = %d, flow = %b", $signed(operand1), operation, $signed(operand2), $signed(result), flow);

    operand1 = 32'h52; operand2 = 32'h341; operation = 1'b1;
    #1000
    $display("ROBEN_out = ", ROBEN_out);
    $display("%d %b %d = %d, flow = %b", $signed(operand1), operation, $signed(operand2), $signed(result), flow);

    operand1 = 32'h5432; operand2 = -32'h13341; operation = 1'b1;
    #1000
    $display("ROBEN_out = ", ROBEN_out);
    $display("%d %b %d = %d, flow = %b", $signed(operand1), operation, $signed(operand2), $signed(result), flow);

    operand1 = -32'h32; operand2 = -32'hFFFFFF; operation = 1'b1;
    #1000
    $display("ROBEN_out = ", ROBEN_out);
    $display("%d %b %d = %d, flow = %b", $signed(operand1), operation, $signed(operand2), $signed(result), flow);

    operand1 = 32'h1; operand2 = 32'h7FFFFFFF; operation = 1'b0; ROBEN_in = 5'b10000;
    #1000
    $display("ROBEN_out = ", ROBEN_out);
    $display("%d %b %d = %d, flow = %b", $signed(operand1), operation, $signed(operand2), $signed(result), flow);

    operand1 = -32'hFFFFFFF; operand2 = 32'hFFFFFFF; operation = 1'b1; ROBEN_in = 5'b10000;
    #1000
    $display("ROBEN_out = ", ROBEN_out);
    $display("%d %b %d = %d, flow = %b", $signed(operand1), operation, $signed(operand2), $signed(result), flow);
end
endmodule
