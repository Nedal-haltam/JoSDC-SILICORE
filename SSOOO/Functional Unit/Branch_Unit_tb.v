`include "Branch_Unit.v"
module Branch_Unit_tb;
    reg [31:0] operand1, operand2;
    wire result;

    Branch_Unit DUT(
        .operand1(operand1),
        .operand2(operand2),
        .equal(result)
    );

    initial begin
        operand1 = 32'habd; operand2 = 32'h123; #1
        $display("%d & %d equal = %b", operand1, operand2, result);
        operand1 = 32'habd; operand2 = 32'habd; #1
        $display("%d & %d equal = %b", operand1, operand2, result);
        operand1 = 32'habd156; operand2 = 32'habd; #1
        $display("%d & %d equal = %b", operand1, operand2, result);
        operand1 = 32'h0; operand2 = 32'h0; #1
        $display("%d & %d equal = %b", operand1, operand2, result);
    end
endmodule