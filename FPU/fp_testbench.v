`include "fp_multiplier.v"

module testbench;
  reg [31:0] op1, op2;
  wire [31:0] result;
  wire overflow, underflow;
  
  fp_multiplier DUT(
    .operand1(op1),
    .operand2(op2),
    .result(result),
    .overflow(overflow),
    .underflow(underflow)
  );
  
  initial begin
    // two normalized numbers | 1 00001001 0110111110...
    op1 = {1'b1, 8'b10000000, 5'b01010, 18'b0};
    op2 = {1'b0, 8'b10000011, 5'b00011, 18'b0};
    #1
    $display ("%b %d %b", op1[31], op1[30:23], op1[22:0]);
    $display ("%b %d %b", op2[31], op2[30:23], op2[22:0]);
    $display ("%b %d %b | O= %b U=%b", result[31], result[30:23], result[22:0], overflow, underflow);
    $display("");

    // two normalized numbers w/ overflow | 0 11111111 0...
    op1 = {1'b1, 8'b10000010, 5'b01010, 18'b0};
    op2 = {1'b1, 8'b11111100, 5'b00011, 18'b0};
    #1
    $display ("%b %d %b", op1[31], op1[30:23], op1[22:0]);
    $display ("%b %d %b", op2[31], op2[30:23], op2[22:0]);
    $display ("%b %d %b | O=%b U=%b", result[31], result[30:23], result[22:0], overflow, underflow);
    $display("");

    // two subnormal numbers| 0 00000000 0...
    op1 = {1'b0, 8'b0, 5'b01010, 18'b0};
    op2 = {1'b1, 8'b0, 5'b00011, 18'b0};
    #1
    $display ("%b %d %b", op1[31], op1[30:23], op1[22:0]);
    $display ("%b %d %b", op2[31], op2[30:23], op2[22:0]);
    $display ("%b %d %b | O=%b U=%b", result[31], result[30:23], result[22:0], overflow, underflow);
    $display("");
    
    // one normalized one subnormal| 0 1000000 011111...
    // 0.3125 * 1.59375 * 2 = 0.498046875 * 2 = 1.1111111 * 2^-1
    op1 = {1'b0, 8'b0, 5'b01010, 18'b0};
    op2 = {1'b0, 8'b11111110, 5'b10011, 18'b0};
    #1
    $display ("%b %d %b", op1[31], op1[30:23], op1[22:0]);
    $display ("%b %d %b", op2[31], op2[30:23], op2[22:0]);
    $display ("%b %d %b | O=%b U=%b", result[31], result[30:23], result[22:0], overflow, underflow);
    $display("");
  end
  
endmodule
