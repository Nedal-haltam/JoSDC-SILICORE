module CLA_Adder_8_Stage(
    input [31:0] operand1,
    input [31:0] operand2,
    input operation, // 0 for addition and 1 for subtraction
    output [31:0] result
);

    wire [31:0] op2;
    wire [31:0] p;
    wire [31:0] g;
    wire [31:0] c;
    wire [79:0] i;

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


    // BLOCK 1

    // c0 = g0 +p0cin
    and g0(g[0], operand1[0], op2[0]); // generate
    xor p0(p[0], operand1[0], op2[0]); // propagate 
    and i0(i[0], operation, p[0]); // intermediate logic
    or  c0(c[0], g[0], i[0]); // carry generation

    // c1 = g1 + p1g0 + p1p0cin
    and g1(g[1], operand1[1], op2[1]); // generate
    xor p1(p[1], operand1[1], op2[1]); // propagate 
    and i1(i[1], p[1], g[0]); // intermediate logic
    and i2(i[2], p[1], p[0], operation); // intermediate logic
    or  c1(c[1], g[1], i[1], i[2]); // carry generation

    // c2 = g2 + p2g1 + p2p1g0 + p2p1p0cin
    and g2(g[2], operand1[2], op2[2]); // generate
    xor p2(p[2], operand1[2], op2[2]); // propagate 
    and i3(i[3], p[2], g[1]); // intermediate logic
    and i4(i[4], p[2], p[1], g[0]); // intermediate logic
    and i5(i[5], p[2], p[1], p[0], operation); // intermediate logic
    or  c2(c[2], g[2], i[3], i[4], i[5]); // carry generation

    // c3 = g3 + p3g2 + p3p2g1 + p3p2p1g0 + p3p2p1p0cin
    and g3(g[3], operand1[3], op2[3]); // generate
    xor p3(p[3], operand1[3], op2[3]); // propagate 
    and i6(i[6], p[3], g[2]); // intermediate logic
    and i7(i[7], p[3], p[2], g[1]); // intermediate logic
    and i8(i[8], p[3], p[2], p[1], g[0]); // intermediate logic
    and i9(i[9], p[3], p[2], p[1], p[0], operation); // intermediate logic
    or  c3(c[3], g[3], i[6], i[7], i[8], i[9]); // carry generation

    // BLOCK 2

    // c4 = g4 +p4c3
    and g4(g[4], operand1[4], op2[4]); // generate
    xor p4(p[4], operand1[4], op2[4]); // propagate 
    and i10(i[10], p[4], c[3]); // intermediate logic
    or  c4(c[4], g[4], i[10]); // carry generation

    // c5 = g5 + p5g4 + p5p4c3
    and g5(g[5], operand1[5], op2[5]); // generate
    xor p5(p[5], operand1[5], op2[5]); // propagate 
    and i11(i[11], p[5], g[4]); // intermediate logic
    and i12(i[12], p[5], p[4], c[3]); // intermediate logic
    or  c5(c[5], g[5], i[11], i[12]); // carry generation

    // c6 = g6 + p6g5 + p6p5g4 + p6p5p4c3
    and g6(g[6], operand1[6], op2[6]); // generate
    xor p6(p[6], operand1[6], op2[6]); // propagate 
    and i13(i[13], p[6], g[5]); // intermediate logic
    and i14(i[14], p[6], p[5], g[4]); // intermediate logic
    and i15(i[15], p[6], p[5], p[4], c[3]); // intermediate logic
    or  c6(c[6], g[6], i[13], i[14], i[15]); // carry generation

    // c7 = g7 + p7g6 + p7p6g5 + p7p6p5g4 + p7p6p5p4c3
    and g7(g[7], operand1[7], op2[7]); // generate
    xor p7(p[7], operand1[7], op2[7]); // propagate 
    and i16(i[16], p[7], g[6]); // intermediate logic
    and i17(i[17], p[7], p[6], g[5]); // intermediate logic
    and i18(i[18], p[7], p[6], p[5], g[4]); // intermediate logic
    and i19(i[19], p[7], p[6], p[5], p[4], c[3]); // intermediate logic
    or  c7(c[7], g[7], i[16], i[17], i[18], i[19]); // carry generation

    // BLOCK 3

    // c8 = g8 +p8c7
    and g8(g[8], operand1[8], op2[8]); // generate
    xor p8(p[8], operand1[8], op2[8]); // propagate 
    and i20(i[20], p[8], c[7]); // intermediate logic
    or  c8(c[8], g[8], i[20]); // carry generation

    // c9 = g9 + p9g8 + p9p8c7
    and g9(g[9], operand1[9], op2[9]); // generate
    xor p9(p[9], operand1[9], op2[9]); // propagate 
    and i21(i[21], p[9], g[8]); // intermediate logic
    and i22(i[22], p[9], p[8], c[7]); // intermediate logic
    or  c9(c[9], g[9], i[21], i[22]); // carry generation

    // c10 = g10 + p10g9 + p10p9g8 + p10p9p8c7
    and g10(g[10], operand1[10], op2[10]); // generate
    xor p10(p[10], operand1[10], op2[10]); // propagate 
    and i23(i[23], p[10], g[9]); // intermediate logic
    and i24(i[24], p[10], p[9], g[8]); // intermediate logic
    and i25(i[25], p[10], p[9], p[8], c[7]); // intermediate logic
    or  c10(c[10], g[10], i[23], i[24], i[25]); // carry generation

    // c11 = g11 + p11g10 + p11p10g9 + p11p10p9g8 + p11p10p9p8c7
    and g11(g[11], operand1[11], op2[11]); // generate
    xor p11(p[11], operand1[11], op2[11]); // propagate 
    and i26(i[26], p[11], g[10]); // intermediate logic
    and i27(i[27], p[11], p[10], g[9]); // intermediate logic
    and i28(i[28], p[11], p[10], p[9], g[8]); // intermediate logic
    and i29(i[29], p[11], p[10], p[9], p[8], c[7]); // intermediate logic
    or  c11(c[11], g[11], i[26], i[27], i[28], i[29]); // carry generation

    // BLOCK 4

    // c12 = g12 +p12c11
    and g12(g[12], operand1[12], op2[12]); // generate
    xor p12(p[12], operand1[12], op2[12]); // propagate 
    and i30(i[30], p[12], c[11]); // intermediate logic
    or  c12(c[12], g[12], i[30]); // carry generation

    // c13 = g13 + p13g12 + p13p12c11
    and g13(g[13], operand1[13], op2[13]); // generate
    xor p13(p[13], operand1[13], op2[13]); // propagate 
    and i31(i[31], p[13], g[12]); // intermediate logic
    and i32(i[32], p[13], p[12], c[11]); // intermediate logic
    or  c13(c[13], g[13], i[31], i[32]); // carry generation

    // c14 = g14 + p14g13 + p14p13g12 + p14p13p12c11
    and g14(g[14], operand1[14], op2[14]); // generate
    xor p14(p[14], operand1[14], op2[14]); // propagate 
    and i33(i[33], p[14], g[13]); // intermediate logic
    and i34(i[34], p[14], p[13], g[12]); // intermediate logic
    and i35(i[35], p[14], p[13], p[12], c[11]); // intermediate logic
    or  c14(c[14], g[14], i[33], i[34], i[35]); // carry generation

    // c15 = g15 + p15g14 + p15p14g13 + p15p14p13g12 + p15p14p13p12c11
    and g15(g[15], operand1[15], op2[15]); // generate
    xor p15(p[15], operand1[15], op2[15]); // propagate 
    and i36(i[36], p[15], g[14]); // intermediate logic
    and i37(i[37], p[15], p[14], g[13]); // intermediate logic
    and i38(i[38], p[15], p[14], p[13], g[12]); // intermediate logic
    and i39(i[39], p[15], p[14], p[13], p[12], c[11]); // intermediate logic
    or  c15(c[15], g[15], i[36], i[37], i[38], i[39]); // carry generation

    // BLOCK 5

    // c16 = g16 +p16c15
    and g16(g[16], operand1[16], op2[16]); // generate
    xor p16(p[16], operand1[16], op2[16]); // propagate 
    and i40(i[40], p[16], c[15]); // intermediate logic
    or  c16(c[16], g[16], i[40]); // carry generation

    // c17 = g17 + p17g16 + p17p16c15
    and g17(g[17], operand1[17], op2[17]); // generate
    xor p17(p[17], operand1[17], op2[17]); // propagate 
    and i41(i[41], p[17], g[16]); // intermediate logic
    and i42(i[42], p[17], p[16], c[15]); // intermediate logic
    or  c17(c[17], g[17], i[41], i[42]); // carry generation

    // c18 = g18 + p18g17 + p18p17g16 + p18p17p16c15
    and g18(g[18], operand1[18], op2[18]); // generate
    xor p18(p[18], operand1[18], op2[18]); // propagate 
    and i43(i[43], p[18], g[17]); // intermediate logic
    and i44(i[44], p[18], p[17], g[16]); // intermediate logic
    and i45(i[45], p[18], p[17], p[16], c[15]); // intermediate logic
    or  c18(c[18], g[18], i[43], i[44], i[45]); // carry generation

    // c19 = g19 + p19g18 + p19p18g17 + p19p18p17g16 + p19p18p17p16c15
    and g19(g[19], operand1[19], op2[19]); // generate
    xor p19(p[19], operand1[19], op2[19]); // propagate 
    and i46(i[46], p[19], g[18]); // intermediate logic
    and i47(i[47], p[19], p[18], g[17]); // intermediate logic
    and i48(i[48], p[19], p[18], p[17], g[16]); // intermediate logic
    and i49(i[49], p[19], p[18], p[17], p[16], c[15]); // intermediate logic
    or  c19(c[19], g[19], i[46], i[47], i[48], i[49]); // carry generation

    // BLOCK 6

    // c20 = g20 +p20c19
    and g20(g[20], operand1[20], op2[20]); // generate
    xor p20(p[20], operand1[20], op2[20]); // propagate 
    and i50(i[50], p[20], c[19]); // intermediate logic
    or  c20(c[20], g[20], i[50]); // carry generation

    // c21 = g21 + p21g20 + p21p20c19
    and g21(g[21], operand1[21], op2[21]); // generate
    xor p21(p[21], operand1[21], op2[21]); // propagate 
    and i51(i[51], p[21], g[20]); // intermediate logic
    and i52(i[52], p[21], p[20], c[19]); // intermediate logic
    or  c21(c[21], g[21], i[51], i[52]); // carry generation

    // c22 = g22 + p22g21 + p22p21g20 + p22p21p20c19
    and g22(g[22], operand1[22], op2[22]); // generate
    xor p22(p[22], operand1[22], op2[22]); // propagate 
    and i53(i[53], p[22], g[21]); // intermediate logic
    and i54(i[54], p[22], p[21], g[20]); // intermediate logic
    and i55(i[55], p[22], p[21], p[20], c[19]); // intermediate logic
    or  c22(c[22], g[22], i[53], i[54], i[55]); // carry generation

    // c23 = g23 + p23g22 + p23p22g21 + p23p22p21g20 + p23p22p21p20c19
    and g23(g[23], operand1[23], op2[23]); // generate
    xor p23(p[23], operand1[23], op2[23]); // propagate 
    and i56(i[56], p[23], g[22]); // intermediate logic
    and i57(i[57], p[23], p[22], g[21]); // intermediate logic
    and i58(i[58], p[23], p[22], p[21], g[20]); // intermediate logic
    and i59(i[59], p[23], p[22], p[21], p[20], c[19]); // intermediate logic
    or  c23(c[23], g[23], i[56], i[57], i[58], i[59]); // carry generation

    // BLOCK 7

    // c24 = g24 +p24c23
    and g24(g[24], operand1[24], op2[24]); // generate
    xor p24(p[24], operand1[24], op2[24]); // propagate 
    and i60(i[60], p[24], c[23]); // intermediate logic
    or  c24(c[24], g[24], i[60]); // carry generation

    // c25 = g25 + p25g24 + p25p24c23
    and g25(g[25], operand1[25], op2[25]); // generate
    xor p25(p[25], operand1[25], op2[25]); // propagate 
    and i61(i[61], p[25], g[24]); // intermediate logic
    and i62(i[62], p[25], p[24], c[23]); // intermediate logic
    or  c25(c[25], g[25], i[61], i[62]); // carry generation

    // c26 = g26 + p26g25 + p26p25g24 + p26p25p24c23
    and g26(g[26], operand1[26], op2[26]); // generate
    xor p26(p[26], operand1[26], op2[26]); // propagate 
    and i63(i[63], p[26], g[25]); // intermediate logic
    and i64(i[64], p[26], p[25], g[24]); // intermediate logic
    and i65(i[65], p[26], p[25], p[24], c[23]); // intermediate logic
    or  c26(c[26], g[26], i[63], i[64], i[65]); // carry generation

    // c27 = g27 + p27g26 + p27p26g25 + p27p26p25g24 + p27p26p25p24c23
    and g27(g[27], operand1[27], op2[27]); // generate
    xor p27(p[27], operand1[27], op2[27]); // propagate 
    and i66(i[66], p[27], g[26]); // intermediate logic
    and i67(i[67], p[27], p[26], g[25]); // intermediate logic
    and i68(i[68], p[27], p[26], p[25], g[24]); // intermediate logic
    and i69(i[69], p[27], p[26], p[25], p[24], c[23]); // intermediate logic
    or  c27(c[27], g[27], i[66], i[67], i[68], i[69]); // carry generation

    // BLOCK 8

    // c28 = g28 +p28c27
    and g28(g[28], operand1[28], op2[28]); // generate
    xor p28(p[28], operand1[28], op2[28]); // propagate 
    and i70(i[70], p[28], c[27]); // intermediate logic
    or  c28(c[28], g[28], i[70]); // carry generation

    // c29 = g29 + p29g28 + p29p28c27
    and g29(g[29], operand1[29], op2[29]); // generate
    xor p29(p[29], operand1[29], op2[29]); // propagate 
    and i71(i[71], p[29], g[28]); // intermediate logic
    and i72(i[72], p[29], p[28], c[27]); // intermediate logic
    or  c29(c[29], g[29], i[71], i[72]); // carry generation

    // c30 = g30 + p30g29 + p30p29g28 + p30p29p28c27
    and g30(g[30], operand1[30], op2[30]); // generate
    xor p30(p[30], operand1[30], op2[30]); // propagate 
    and i73(i[73], p[30], g[29]); // intermediate logic
    and i74(i[74], p[30], p[29], g[28]); // intermediate logic
    and i75(i[75], p[30], p[29], p[28], c[27]); // intermediate logic
    or  c30(c[30], g[30], i[73], i[74], i[75]); // carry generation

    // c31 = g31 + p31g30 + p31p30g29 + p31p30p29g28 + p31p30p29p28c27
    and g31(g[31], operand1[11], op2[11]); // generate
    xor p31(p[31], operand1[11], op2[11]); // propagate 
    and i76(i[76], p[31], g[30]); // intermediate logic
    and i77(i[77], p[31], p[30], g[29]); // intermediate logic
    and i78(i[78], p[31], p[30], p[29], g[28]); // intermediate logic
    and i79(i[79], p[31], p[30], p[29], p[28], c[27]); // intermediate logic
    or  c31(c[31], g[31], i[76], i[77], i[78], i[79]); // carry generation

    
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
