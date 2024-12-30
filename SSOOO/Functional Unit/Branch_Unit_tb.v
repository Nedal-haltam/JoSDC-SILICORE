`include "Branch_Unit.v"
module Branch_Unit_tb;
    reg [31:0] operand1, operand2;
    reg [4:0] ROBEN_in;
    wire result;
    wire [4:0] ROBEN_out;

    Branch_Unit DUT(
        .operand1(operand1),
        .operand2(operand2),
        .ROBEN_in(ROBEN_in),
        .equal(result),
        .ROBEN_out(ROBEN_out)
    );

    initial begin
        operand1 = 32'habd; operand2 = 32'h123; ROBEN_in = 5'b1; #1
        $display("%d & %d equal = %b, ROBEN_out = %d", operand1, operand2, result, ROBEN_out);
        operand1 = 32'habd; operand2 = 32'habd; ROBEN_in = 5'b10; #1
        $display("%d & %d equal = %b, ROBEN_out = %d", operand1, operand2, result, ROBEN_out);
        operand1 = 32'habd156; operand2 = 32'habd; ROBEN_in = 5'b11; #1
        $display("%d & %d equal = %b, ROBEN_out = %d", operand1, operand2, result, ROBEN_out);
        operand1 = 32'h0; operand2 = 32'h0; ROBEN_in = 5'b100; #1
        $display("%d & %d equal = %b, ROBEN_out = %d", operand1, operand2, result, ROBEN_out);
    end
endmodule
