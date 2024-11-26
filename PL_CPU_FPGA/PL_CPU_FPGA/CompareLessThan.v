
module compare_lt(lt, a, b);

input [31:0] a, b;
wire [31:0] temp;
output lt;

// assign lt = ($signed(a) < $signed(b)) ? 1'b1 : 1'b0;
and and0 (temp[0], ~a[0], b[0]);
and and1 (temp[1], ~a[1], b[1]);
and and2 (temp[2], ~a[2], b[2]);
and and3 (temp[3], ~a[3], b[3]);
and and4 (temp[4], ~a[4], b[4]);
and and5 (temp[5], ~a[5], b[5]);
and and6 (temp[6], ~a[6], b[6]);
and and7 (temp[7], ~a[7], b[7]);
and and8 (temp[8], ~a[8], b[8]);
and and9 (temp[9], ~a[9], b[9]);
and and10(temp[10], ~a[10], b[10]);
and and11(temp[11], ~a[11], b[11]);
and and12(temp[12], ~a[12], b[12]);
and and13(temp[13], ~a[13], b[13]);
and and14(temp[14], ~a[14], b[14]);
and and15(temp[15], ~a[15], b[15]);
and and16(temp[16], ~a[16], b[16]);
and and17(temp[17], ~a[17], b[17]);
and and18(temp[18], ~a[18], b[18]);
and and19(temp[19], ~a[19], b[19]);
and and20(temp[20], ~a[20], b[20]);
and and21(temp[21], ~a[21], b[21]);
and and22(temp[22], ~a[22], b[22]);
and and23(temp[23], ~a[23], b[23]);
and and24(temp[24], ~a[24], b[24]);
and and25(temp[25], ~a[25], b[25]);
and and26(temp[26], ~a[26], b[26]);
and and27(temp[27], ~a[27], b[27]);
and and28(temp[28], ~a[28], b[28]);
and and29(temp[29], ~a[29], b[29]);
and and30(temp[30], ~a[30], b[30]);
// and and31(temp[31], a[31], ~b[31]);

wire ltw, ltww;
nor or1(ltw
, temp[0]
, temp[1], temp[2], temp[3], temp[4], temp[5], temp[6], temp[7], temp[8], temp[9], temp[10]
, temp[11], temp[12], temp[13], temp[14], temp[15], temp[16], temp[17], temp[18], temp[19], temp[20]
, temp[21], temp[22], temp[23], temp[24], temp[25], temp[26], temp[27], temp[28], temp[29], temp[30]
, a[31] & ~b[31] );

nor (ltww, ~a[31] & b[31], ltw);
xor (lt, ltww, a[31] &  b[31]);
// cases : 
// two  positive                 ~a[31] & ~b[31] ->      compare all the bits normally
// two  negative                  a[31] &  b[31] -> also compare all the bits normally with inversion at the end
// a is positive , b is negative ~a[31] &  b[31] ->      we directly conclude that a is not less than b
// a is negative , b is positive  a[31] & ~b[31] -> also we directly conclude that a is     less than b

endmodule