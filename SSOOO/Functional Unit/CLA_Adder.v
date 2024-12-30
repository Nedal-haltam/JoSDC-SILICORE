module CLA_Adder(
    input [31:0] operand1,
    input [31:0] operand2,
    input [ 4:0] ROBEN_in,
    input operation, // 0 for addition and 1 for subtraction
    output [31:0] result,
    output [ 4:0] ROBEN_out,
    output flow // overflow and underflow flag
);
    wire [7:0] C;

    CLA_4_bit x1(
        .operand1(operand1[3:0]),
        .operand2(operand2[3:0]),
        .cin(operation),
        .operation(operation),
        .result(result[3:0]),
        .cout(C[0])
    );

    CLA_4_bit x2(
        .operand1(operand1[7:4]),
        .operand2(operand2[7:4]),
        .cin(C[0]),
        .operation(operation),
        .result(result[7:4]),
        .cout(C[1])
    );

    CLA_4_bit x3(
        .operand1(operand1[11:8]),
        .operand2(operand2[11:8]),
        .cin(C[1]),
        .operation(operation),
        .result(result[11:8]),
        .cout(C[2])
    );

    CLA_4_bit x4(
        .operand1(operand1[15:12]),
        .operand2(operand2[15:12]),
        .cin(C[2]),
        .operation(operation),
        .result(result[15:12]),
        .cout(C[3])
    );

    CLA_4_bit x5(
        .operand1(operand1[19:16]),
        .operand2(operand2[19:16]),
        .cin(C[3]),
        .operation(operation),
        .result(result[19:16]),
        .cout(C[4])
    );

    CLA_4_bit x6(
        .operand1(operand1[23:20]),
        .operand2(operand2[23:20]),
        .cin(C[4]),
        .operation(operation),
        .result(result[23:20]),
        .cout(C[5])
    );

    CLA_4_bit x7(
        .operand1(operand1[27:24]),
        .operand2(operand2[27:24]),
        .cin(C[5]),
        .operation(operation),
        .result(result[27:24]),
        .cout(C[6])
    );

    CLA_4_bit x8(
        .operand1(operand1[31:28]),
        .operand2(operand2[31:28]),
        .cin(C[6]),
        .operation(operation),
        .result(result[31:28]),
        .cout(C[7])
    );

    // outputs ROBEN for the executed instruction
    assign ROBEN_out = ROBEN_in;

    // flag for overflow and underflow
    assign flow = C[7] ^ C[6];

endmodule

module CLA_4_bit (
    input [3:0] operand1,
    input [3:0] operand2,
    input cin,
    input operation,
    output [3:0] result,
    output cout
);

    wire [3:0] op2, p, g, c;

    // computes the two's compelement for subtraction operations
    assign op2[0] = operation ^ operand2[0];
    assign op2[1] = operation ^ operand2[1];
    assign op2[2] = operation ^ operand2[2];
    assign op2[3] = operation ^ operand2[3];

    // generates
    assign g[0] = operand1[0] & op2[0];
    assign g[1] = operand1[1] & op2[1];
    assign g[2] = operand1[2] & op2[2];
    assign g[3] = operand1[3] & op2[3];

    // propagates
    assign p[0] = operand1[0] ^ op2[0];
    assign p[1] = operand1[1] ^ op2[1];
    assign p[2] = operand1[2] ^ op2[2];
    assign p[3] = operand1[3] ^ op2[3];

    
    // c0 = g0 + p0cin
    assign c[0] = g[0] | (p[0] & cin);
    // c1 = g1 + p1g0 + p1p0cin
    assign c[1] = g[1] | (p[1] & c[0]) | (p[1] & p[0] & cin);
    // c2 = g2 + p2g1 + p2p1g0 + p2p1p0cin 
    assign c[2] = g[2] | (p[2] & c[1]) | (p[2] & p[1] & c[0]) | (p[2] & p[1] & p[0] & cin);
    // c3 = g3 + p3g2 + p3p2g1 + p3p2p1g0 + p3p2p1p0cin
    assign c[3] = g[3] | (p[3] & c[2]) | (p[3] & p[2] & c[1]) | (p[3] & p[2] & p[1] & c[0]) | (p[3] & p[2] & p[1] & p[0] & cin);

    // output carry
    assign cout = c[3];

     // computes the sum for each stage
     assign result[0] = operand1[0] ^ op2[0] ^ cin;
     assign result[1] = operand1[1] ^ op2[1] ^ c[0];
     assign result[2] = operand1[2] ^ op2[2] ^ c[1];
     assign result[3] = operand1[3] ^ op2[3] ^ c[2];

endmodule
