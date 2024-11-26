
module compare_equal(out, a, b);

input [31:0] a, b;
output out;

wire [31:0] temp;

xor xor0(temp[0], a[0], b[0]);
xor xor1(temp[1], a[1], b[1]);
xor xor2(temp[2], a[2], b[2]);
xor xor3(temp[3], a[3], b[3]);
xor xor4(temp[4], a[4], b[4]);
xor xor5(temp[5], a[5], b[5]);
xor xor6(temp[6], a[6], b[6]);
xor xor7(temp[7], a[7], b[7]);
xor xor8(temp[8], a[8], b[8]);
xor xor9(temp[9], a[9], b[9]);
xor xor10(temp[10], a[10], b[10]);
xor xor11(temp[11], a[11], b[11]);
xor xor12(temp[12], a[12], b[12]);
xor xor13(temp[13], a[13], b[13]);
xor xor14(temp[14], a[14], b[14]);
xor xor15(temp[15], a[15], b[15]);
xor xor16(temp[16], a[16], b[16]);
xor xor17(temp[17], a[17], b[17]);
xor xor18(temp[18], a[18], b[18]);
xor xor19(temp[19], a[19], b[19]);
xor xor20(temp[20], a[20], b[20]);
xor xor21(temp[21], a[21], b[21]);
xor xor22(temp[22], a[22], b[22]);
xor xor23(temp[23], a[23], b[23]);
xor xor24(temp[24], a[24], b[24]);
xor xor25(temp[25], a[25], b[25]);
xor xor26(temp[26], a[26], b[26]);
xor xor27(temp[27], a[27], b[27]);
xor xor28(temp[28], a[28], b[28]);
xor xor29(temp[29], a[29], b[29]);
xor xor30(temp[30], a[30], b[30]);
xor xor31(temp[31], a[31], b[31]);

nor or1(out
, temp[0]
, temp[1], temp[2], temp[3], temp[4], temp[5], temp[6], temp[7], temp[8], temp[9], temp[10]
, temp[11], temp[12], temp[13], temp[14], temp[15], temp[16], temp[17], temp[18], temp[19], temp[20]
, temp[21], temp[22], temp[23], temp[24], temp[25], temp[26], temp[27], temp[28], temp[29], temp[30]
, temp[31]);


endmodule