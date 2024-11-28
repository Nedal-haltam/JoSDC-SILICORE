module CLA_Adder(
    input [31:0] operand1,
    input [31:0] operand2,
    input operation, // 0 for addition and 1 for subtraction
    output [31:0] result
);

    wire [31:0] op2;
    wire [31:0] p;
    wire [31:0] g;
    wire [31:0] c;
    wire [529:0] i;

    // computes the two's compelement for subtraction operations
    xor t1(op2[0], operation, operand2[0]);
    xor t2(op2[1], operation, operand2[1]);
    xor t3(op2[2], operation, operand2[2]);
    xor t4(op2[3], operation, operand2[3]);
    xor t5(op2[4], operation, operand2[4]);
    xor t6(op2[5], operation, operand2[5]);
    xor t7(op2[6], operation, operand2[6]);
    xor t8(op2[7], operation, operand2[7]);
    xor t9(op2[8], operation, operand2[8]);
    xor t10(op2[9], operation, operand2[9]);
    xor t11(op2[10], operation, operand2[10]);
    xor t12(op2[11], operation, operand2[11]);
    xor t13(op2[12], operation, operand2[12]);
    xor t14(op2[13], operation, operand2[13]);
    xor t15(op2[14], operation, operand2[14]);
    xor t16(op2[15], operation, operand2[15]);
    xor t17(op2[16], operation, operand2[16]);
    xor t18(op2[17], operation, operand2[17]);
    xor t19(op2[18], operation, operand2[18]);
    xor t20(op2[19], operation, operand2[19]);
    xor t21(op2[20], operation, operand2[20]);
    xor t22(op2[21], operation, operand2[21]);
    xor t23(op2[22], operation, operand2[22]);
    xor t24(op2[23], operation, operand2[23]);
    xor t25(op2[24], operation, operand2[24]);
    xor t26(op2[25], operation, operand2[25]);
    xor t27(op2[26], operation, operand2[26]);
    xor t28(op2[27], operation, operand2[27]);
    xor t29(op2[28], operation, operand2[28]);
    xor t30(op2[29], operation, operand2[29]);
    xor t31(op2[30], operation, operand2[30]);
    xor t32(op2[31], operation, operand2[31]);


    //computes the carries using the generates (gi) and propagates (pi)
    // c0 = g0 +p0cin
    and g0(g[0], operand1[0], op2[0]); // generate
    xor p0(p[0], operand1[0], op2[0]); // propagate 
    and i0(i[0], operation, p[0]); // intermiate logic
    or  c0(c[0], g[0], i[0]); // carry generation

    // c1 = g1 + p1g0 + p1p0cin
    and g1(g[1], operand1[1], op2[1]); // generate
    xor p1(p[1], operand1[1], op2[1]); // propagate 
    and i1(i[1], p[1], g[0]); // intermiate logic
    and i2(i[2], p[1], p[0], operation); // intermiate logic
    or  c1(c[1], g[1], i[1], i[2]); // carry generation

    // c2 = g2 + p2g1 + p2p1g0 + p2p1p0cin
    and g2(g[2], operand1[2], op2[2]); // generate
    xor p2(p[2], operand1[2], op2[2]); // propagate 
    and i3(i[3], p[2], g[1]); // intermiate logic
    and i4(i[4], p[2], p[1], g[0]); // intermiate logic
    and i5(i[5], p[2], p[1], p[0], operation); // intermiate logic
    or  c2(c[2], g[2], i[3], i[4], i[5]); // carry generation

    // c3 = g3 + p3g2 + p3p2g1 + p3p2p1g0 + p3p2p1p0cin
    and g3(g[3], operand1[3], op2[3]); // generate
    xor p3(p[3], operand1[3], op2[3]); // propagate 
    and i6(i[6], p[3], g[2]); // intermiate logic
    and i7(i[7], p[3], p[2], g[1]); // intermiate logic
    and i8(i[8], p[3], p[2], p[1], g[0]); // intermiate logic
    and i9(i[9], p[3], p[2], p[1], p[0], operation); // intermiate logic
    or  c3(c[3], g[3], i[6], i[7], i[8], i[9]); // carry generation

    // c4 = g4 + p4g3 + p4p3g2 + p4p3p2g1 + + p4p3p2p1g0 + p4p3p2p1p0cin
    and g4(g[4], operand1[4], op2[4]); // generate
    xor p4(p[4], operand1[4], op2[4]); // propagate 
    and i10(i[10], p[4], g[3]); // intermiate logic
    and i11(i[11], p[4], p[3], g[2]); // intermiate logic
    and i12(i[12], p[4], p[3], p[2], g[1]); // intermiate logic
    and i13(i[13], p[4], p[3], p[2], p[1], g[0], operation); // intermiate logic
    or  c4(c[4], g[4], i[10], i[11], i[12], i[13]); // carry generation

    // c5 = g5 + p5g4 + p5p4g3 + p5p4p3g2 + p5p4p3p2g1 + p5p4p3p2p1g0 + p5p4p3p2p1p0cin
    and g5(g[5], operand1[5], op2[5]); // generate
    xor p5(p[5], operand1[5], op2[5]); // propagate 
    and i14(i[14], p[5], g[4]); // intermiate logic
    and i15(i[15], p[5], p[4], g[3]); // intermiate logic
    and i16(i[16], p[5], p[4], p[3], g[2]); // intermiate logic
    and i17(i[17], p[5], p[4], p[3], p[2], g[1]); // intermiate logic
    and i18(i[18], p[5], p[4], p[3], p[2], p[1], g[0]); // intermiate logic
    and i19(i[19], p[5], p[4], p[3], p[2], p[1], p[0], operation); // intermiate logic
    or  c5(c[5], g[5], i[14], i[15], i[16], i[17], i[18], i[19]); // carry generation

    // c6 = g6 + p6g5 + p6p5g4 + p6p5p4g3 + p6p5p4p3g2 + p6p5p4p3p2g1 + p6p5p4p3p2p1g0 + p6p5p4p3p2p1p0cin
    and g6(g[6], operand1[6], op2[6]); // generate
    xor p6(p[6], operand1[6], op2[6]); // propagate 
    and i20(i[20], p[6], g[5]); // intermiate logic
    and i21(i[21], p[6], p[5], g[4]); // intermiate logic
    and i22(i[22], p[6], p[5], p[4], g[3]); // intermiate logic
    and i23(i[23], p[6], p[5], p[4], p[3], g[2]); // intermiate logic
    and i24(i[24], p[6], p[5], p[4], p[3], p[2], g[1]); // intermiate logic
    and i25(i[25], p[6], p[5], p[4], p[3], p[2], p[1], g[0]); // intermiate logic
    and i26(i[26], p[6], p[5], p[4], p[3], p[2], p[1], p[0], operation); // intermiate logic
    or  c6(c[6], g[6], i[20], i[21], i[22], i[23], i[24], i[25], i[26]); // carry generation

    // c7 = g7 + p7g6 + p7p6g5 + p7p6p5g4 + p7p6p5p4g3 + p7p6p5p4p3g2 + p7p6p5p4p3p2g1 + p7p6p5p4p3p2p1g0 + p7p6p5p4p3p2p1p0cin
    and g7(g[7], operand1[7], op2[7]); // generate
    xor p7(p[7], operand1[7], op2[7]); // propagate 
    and i27(i[27], p[7], g[6]); // intermiate logic
    and i28(i[28], p[7], p[6], g[5]); // intermiate logic
    and i29(i[29], p[7], p[6], p[5], g[4]); // intermiate logic
    and i30(i[30], p[7], p[6], p[5], p[4], g[3]); // intermiate logic
    and i31(i[31], p[7], p[6], p[5], p[4], p[3], g[2]); // intermiate logic
    and i32(i[32], p[7], p[6], p[5], p[4], p[3], p[2], g[1]); // intermiate logic
    and i33(i[33], p[7], p[6], p[5], p[4], p[3], p[2], p[1], g[0]); // intermiate logic
    and i34(i[34], p[7], p[6], p[5], p[4], p[3], p[2], p[1], p[0], operation); // intermiate logic
    or  c7(c[7], g[7], i[27], i[28], i[29], i[30], i[31], i[32], i[33]); // carry generation


    and c8(c[8], 0, 0);
    and c9(c[9], 0, 0);
    and c10(c[10], 0, 0);
    and c11(c[11], 0, 0);
    and c12(c[12], 0, 0);
    and c13(c[13], 0, 0);
    and c14(c[14], 0, 0);
    and c15(c[15], 0, 0);
    and c16(c[16], 0, 0);
    and c17(c[17], 0, 0);
    and c18(c[18], 0, 0);
    and c19(c[19], 0, 0);
    and c20(c[20], 0, 0);
    and c21(c[21], 0, 0);
    and c22(c[22], 0, 0);
    and c23(c[23], 0, 0);
    and c24(c[24], 0, 0);
    and c25(c[25], 0, 0);
    and c26(c[26], 0, 0);
    and c27(c[27], 0, 0);
    and c28(c[28], 0, 0);
    and c29(c[29], 0, 0);
    and c30(c[30], 0, 0);
    and c31(c[31], 0, 0);
    
    // computes the sum for each stage
    xor s0  (result[0], operand1[0], op2[0], c[0]);
    xor s1  (result[1], operand1[1], op2[1], c[1]);
    xor s2  (result[2], operand1[2], op2[2], c[2]);
    xor s3  (result[3], operand1[3], op2[3], c[3]);
    xor s4  (result[4], operand1[4], op2[4], c[4]);
    xor s5  (result[5], operand1[5], op2[5], c[5]);
    xor s6  (result[6], operand1[6], op2[6], c[6]);
    xor s7  (result[7], operand1[7], op2[7], c[7]);
    xor s8  (result[8], operand1[8], op2[8], c[8]);
    xor s9  (result[9], operand1[9], op2[9], c[9]);
    xor s10 (result[10], operand1[10], op2[10], c[10]);
    xor s11 (result[11], operand1[11], op2[11], c[11]);
    xor s12 (result[12], operand1[12], op2[12], c[12]);
    xor s13 (result[13], operand1[13], op2[13], c[13]);
    xor s14 (result[14], operand1[14], op2[14], c[14]);
    xor s15 (result[15], operand1[15], op2[15], c[15]);
    xor s16 (result[16], operand1[16], op2[16], c[16]);
    xor s17 (result[17], operand1[17], op2[17], c[17]);
    xor s18 (result[18], operand1[18], op2[18], c[18]);
    xor s19 (result[19], operand1[19], op2[19], c[19]);
    xor s20 (result[20], operand1[20], op2[20], c[20]);
    xor s21 (result[21], operand1[21], op2[21], c[21]);
    xor s22 (result[22], operand1[22], op2[22], c[22]);
    xor s23 (result[23], operand1[23], op2[23], c[23]);
    xor s24 (result[24], operand1[24], op2[24], c[24]);
    xor s25 (result[25], operand1[25], op2[25], c[25]);
    xor s26 (result[26], operand1[26], op2[26], c[26]);
    xor s27 (result[27], operand1[27], op2[27], c[27]);
    xor s28 (result[28], operand1[28], op2[28], c[28]);
    xor s29 (result[29], operand1[29], op2[29], c[29]);
    xor s30 (result[30], operand1[30], op2[30], c[30]);
    xor s31 (result[31], operand1[31], op2[31], c[31]);

endmodule
