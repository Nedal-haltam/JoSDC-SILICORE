module Branch_Unit(
    input [31:0] operand1,
    input [31:0] operand2,
    input [4:0] ROBEN_in,
    output equal,
    output [4:0] ROBEN_out
);

    // outputs ROBEN for the executed instruction
    assign ROBEN_out = ROBEN_in;

    assign equal =  (operand1[0] ~^ operand2[0]) &
                    (operand1[1] ~^ operand2[1]) &
                    (operand1[2] ~^ operand2[2]) &
                    (operand1[3] ~^ operand2[3]) &
                    (operand1[4] ~^ operand2[4]) &
                    (operand1[5] ~^ operand2[5]) &
                    (operand1[6] ~^ operand2[6]) &
                    (operand1[7] ~^ operand2[7]) &
                    (operand1[8] ~^ operand2[8]) &
                    (operand1[9] ~^ operand2[9]) &
                    (operand1[10] ~^ operand2[10]) &
                    (operand1[11] ~^ operand2[11]) &
                    (operand1[12] ~^ operand2[12]) &
                    (operand1[13] ~^ operand2[13]) &
                    (operand1[14] ~^ operand2[14]) &
                    (operand1[15] ~^ operand2[15]) &
                    (operand1[16] ~^ operand2[16]) &
                    (operand1[17] ~^ operand2[17]) &
                    (operand1[18] ~^ operand2[18]) &
                    (operand1[19] ~^ operand2[19]) &
                    (operand1[20] ~^ operand2[20]) &
                    (operand1[21] ~^ operand2[21]) &
                    (operand1[22] ~^ operand2[22]) &
                    (operand1[23] ~^ operand2[23]) &
                    (operand1[24] ~^ operand2[24]) &
                    (operand1[25] ~^ operand2[25]) &
                    (operand1[26] ~^ operand2[26]) &
                    (operand1[27] ~^ operand2[27]) &
                    (operand1[28] ~^ operand2[28]) &
                    (operand1[29] ~^ operand2[29]) &
                    (operand1[30] ~^ operand2[30]) &
                    (operand1[31] ~^ operand2[31]);
                
endmodule
