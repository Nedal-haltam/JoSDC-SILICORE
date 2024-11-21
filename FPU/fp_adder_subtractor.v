module fp_adder_subtractor(
    input [31:0] operand1,
    input [31:0] operand2,
    input operation, // 0 for addition and 1 for subtraction
    output [31:0] result,
    output overflow,
    output underflow
)
    // 8-bit difference between the exponents
    reg [7:0] e_diff;
    // 8-bit exponents
    reg [7:0] e_op1;
    reg [7:0] e_op2;
    // 24-bit significand w/ hidden bit
    reg [23:0] s_op1;
    reg [23:0] s_op2;
    // 24-bit addition or subtraction result
    reg [24:0] op_result;

    integer i;
    integer leadingZeros;

    always @ (*) begin
        // variables used later to count leading zeros
        leadingZeros = 0;

        e_op1 = operand1[30:23];
        e_op2 = operand2[30:23];

        // Deal with extreme cases | STEP 1
        // either operands being NaN
        if((operand1[30:23] == 8'hFF && operand1[22:0] != 23'b0) || (operand2[30:23] == 8'hFF && operand2[22:0] != 23'b0)) begin
          	result[30:23] <= 8'hFF;
          	result[22:0] <= 23'h7FFFFF;
        end
        // either operands are infinity
        else if((operand1[30:23] == 8'hFF && operand1[22:0] == 23'b0) || (operand2[30:23] == 8'hFF && operand2[22:0] == 23'b0)) begin
          // checks if the signs are different
          if(operand1[31] ^ operand2[31] == 1'b1) begin
            // result is NaN
          	result[30:23] <= 8'hFF;
            result[22:0] <= 23'h7FFFFF;
          end
          else begin
            result[31] == operand1[31];
            result[30:23] <= 8'hFF;
            result[22:0] <= 23'b0;
          end
        end
        // if operand1 = 0
        else if(operand1[30:0] == 31'b0) begin
          result = operand2;
        end
        // if operand2 = 0
        else if(operand2[30:0] == 31'b0) begin
          result = operand1;
        end

        // Deal with normal-subnormal addition 
        else begin
            //adds the hidden bit to operand1's significand
            if(e_op1 == 0) begin
                s_op1 = {1'b0, operand1[22:0]};
            end
            else begin
                s_op1 = {1'b1, operand1[22:0]};
            end

            //adds the hidden bit to operand2's significand
            if(e_op2 == 0) begin
                s_op2 = {1'b0, operand2[22:0]};
            end
            else begin
                s_op2 = {1'b1, operand2[22:0]};
            end

            //Finds the difference between the exponents | STEP 2
            // makes the exponents equal (to the bigger exponent)
            if(e_op1 > e_op2) begin
                e_diff = (e_op2 == 8'b0) ? e_op1 - 8'b1 : e_op1 - e_op2;
                // applies the changes to the exponent and the significand
                e_op2 += e_diff;
                s_op2 >> e_diff;
            end
            else if(e_op2 > e_op1) begin
                e_diff = (e_op1 == 8'b0) ? e_op2 - 8'b1 : e_op2 - e_op1;
                // applies the changes to the exponent and the significand
                e_op1 += e_diff;
                s_op1 >> e_diff;
            end
            
            // if the operands have the same sign
            if(operand1[31] == operand2[31]) begin
                op_result = s_op1 + s_op2;
                result[31] = operand1[31];
            end
            // if the operands have different signs
            else if(s_op1 >= s_op2) begin
                op_result = s_op1 - s_op2;
                result[31] = operand1[31];
            end
            else begin
                op_result = s_op2 - s_op1;
                result[31] = operand2[31];
            end

            // result needs to be normalized ()
            if(op_result[24] == 1) begin
                result[22:0] = op_result[23:1];
                result[30:23] = e_op1 + 1'b1;
            end
            else if(op_result[23] == 0) begin
                for (i = 22; op_result[i] == 0 && i >= 0; i -= 1) begin
                    leadingZeros += 1;
                end
                result[22:0] = op_result[22:0] << leadingZeros + 1;
                result[30:23] = e_op1 - leadingZeros - 1;
            end 

            // if all bits of the smaller operand are shifted out
            if(e_diff > 23) begin
                if(operand1[31:23] > operand2[31:23])
                    result = operand1;
                else
                    result = operand2;
            end
        end
    end

endmodule
