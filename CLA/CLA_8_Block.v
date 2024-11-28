module CLA_8_Block(
    input [31:0] operand1,
    input [31:0] operand2,
    input operation, // 0 for addition and 1 for subtraction
    output [31:0] result
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

endmodule

module CLA_4_bit (
    input [3:0] operand1,
    input [3:0] operand2,
    input cin,
    input operation,
    output [3:0] result,
    output cout
);

    wire [3:0] op2;
    wire [3:0] p;
    wire [3:0] g;
    wire [3:0] c;
    wire [9:0] i;

    // computes the two's compelement for subtraction operations
    xor t1(op2[0], operation, operand2[0]);
    xor t2(op2[1], operation, operand2[1]);
    xor t3(op2[2], operation, operand2[2]);
    xor t4(op2[3], operation, operand2[3]);

    and g0(g[0], operand1[0], op2[0]); // generate
    xor p0(p[0], operand1[0], op2[0]); // propagate 
    and i0(i[0], cin, p[0]); // intermediate logic
    or  c0(c[0], g[0], i[0]); // carry generation

    // c1 = g1 + p1g0 + p1p0cin
    and g1(g[1], operand1[1], op2[1]); // generate
    xor p1(p[1], operand1[1], op2[1]); // propagate 
    and i1(i[1], p[1], g[0]); // intermediate logic
    and i2(i[2], p[1], p[0], cin); // intermediate logic
    or  c1(c[1], g[1], i[1], i[2]); // carry generation

    // c2 = g2 + p2g1 + p2p1g0 + p2p1p0cin
    and g2(g[2], operand1[2], op2[2]); // generate
    xor p2(p[2], operand1[2], op2[2]); // propagate 
    and i3(i[3], p[2], g[1]); // intermediate logic
    and i4(i[4], p[2], p[1], g[0]); // intermediate logic
    and i5(i[5], p[2], p[1], p[0], cin); // intermediate logic
    or  c2(c[2], g[2], i[3], i[4], i[5]); // carry generation

    // c3 = g3 + p3g2 + p3p2g1 + p3p2p1g0 + p3p2p1p0cin
    and g3(g[3], operand1[3], op2[3]); // generate
    xor p3(p[3], operand1[3], op2[3]); // propagate 
    and i6(i[6], p[3], g[2]); // intermediate logic
    and i7(i[7], p[3], p[2], g[1]); // intermediate logic
    and i8(i[8], p[3], p[2], p[1], g[0]); // intermediate logic
    and i9(i[9], p[3], p[2], p[1], p[0], cin); // intermediate logic
    or  c3(c[3], g[3], i[6], i[7], i[8], i[9]); // carry generation

    and temp(cout, c[3], 1);

     // computes the sum for each stage
    xor s0  (result[0], operand1[0], op2[0], c[0]);
    xor s1  (result[1], operand1[1], op2[1], c[1]);
    xor s2  (result[2], operand1[2], op2[2], c[2]);
    xor s3  (result[3], operand1[3], op2[3], c[3]);

endmodule
