module fp_multiplier(
  input [31:0] operand1,
  input [31:0] operand2,
  output reg [31:0] result,
  output reg overflow,
  output reg underflow
);

  integer i;
  integer leadingZeros;
  
  // 48-bit result of multiplying two 23-bit numbers
  reg [47:0] mulResult;

  // 10-bit result of adding the exponents
  reg [9:0] expResult;

  always @ (*) begin
    // variables used later to count leading zeros
    leadingZeros = 0;
    
    // sets the overflow and underflow signals
    overflow = 1'b0;
    underflow = 1'b0;

    // sets the sign bit of the result (STEP 1)
    result[31] <= operand1[31] ^ operand2[31];

    // Deal with extreme cases (STEP 2)
    // either operands being NaN
    if(operand1[30:23] == 8'hFF && operand1[22:0] != 23'b0 || operand2[30:23] == 8'hFF && operand2[22:0] != 23'b0) begin
      	result[30:23] <= 8'hFF;
      	result[22:0] <= 23'h7FFFFF;
    end
    // operand1 = infinity
    else if(operand1[30:23] == 8'hFF && operand1[22:0] == 23'b0) begin
      //checks if operand2 = 0
      if(operand2[30:0] == 31'b0) begin
      	result[30:23] <= 8'hFF;
        result[22:0] <= 23'h2A;
      end
      else begin
        result[30:23] <= 8'hFF;
        result[22:0] <= 23'b0;
      end
    end
    // operand2 = infinity
    else if(operand2[30:23] == 8'hFF && operand2[22:0] == 23'b0) begin
      //checks if operand1 = 0
      if(operand1[30:0] == 31'b0) begin
      	result[30:23] <= 8'hFF;
        result[22:0] <= 23'h2A;
      end
      else begin
        result[30:23] <= 8'hFF;
        result[22:0] <= 23'b0;
      end
    end
    // either operands = 0
    else if(operand1[30:0] == 31'b0 || operand2[30:0] == 31'b0) begin
      result[30:0] <= 31'b0;
    end

    // Deal with normal-subnormal multiplication (STEP 3)
    else begin

      // both operands subnormal
      if(operand1[30:23] == 0 && operand2[30:23] == 0) begin
        // sets the result to zero
        result[30:0] <= 31'b0;
        // sets the underflow signal
        underflow = 1'b1;
      end

      else begin
        // if operand1 only is subnormal
        if(operand1[30:23] == 0 && operand2[30:23] != 0) begin
          expResult = - 126 + operand2[30:23];
          mulResult = {1'b0, operand1[22:0]} * {1'b1, operand2[22:0]};
        end
        // if operand 2 only is subnormal
        else if(operand1[30:23] != 0 && operand2[30:23] == 0) begin
          expResult = - 126 + operand1[30:23];
          mulResult = {1'b1, operand1[22:0]} * {1'b0, operand2[22:0]};
        end
        // if both operands are normalized
        else begin
          expResult = operand1[30:23] - 127 + operand2[30:23];
          mulResult = {1'b1, operand1[22:0]} * {1'b1, operand2[22:0]};
        end

        // normalizes the result
        if(mulResult[47:46] >= 2'b10) begin
          // increments the exponent
          expResult = $signed(expResult) + 1;
          // adjusts the result
          mulResult = mulResult >> 1;
        end
        else if(mulResult[47:46] == 2'b00) begin
          // counts the number of leading zeros
          for (i = 45; mulResult[i] == 0 && i >= 0; i -= 1) begin
            leadingZeros += 1;
          end

          // decrements the exponents by the number of leading zeros+1
          expResult = $signed(expResult) - 1 - leadingZeros;
          // adjusts the result
          mulResult = mulResult << leadingZeros + 1;
        end
      
        // tests for overflow
        if($signed(expResult) - 127 > 127) begin
          // sets the result to infinity
          result[30:23] = 8'hFF;
          result[22:0] = 23'b0;
          // sets the overflow signal
          overflow = 1'b1;
        end
        //tests for underflow
        else if($signed(expResult) - 127 < - 126 && !(mulResult[46] == 1 && $signed(expResult) == -127)) begin
          // sets the result to zero
          result[30:0] = 31'b0;
          // sets the underflow signal
          underflow = 1'b1;
        end
        else begin 
          // tests for subnormal numbers
          if(mulResult[46] == 1 && $signed(expResult) == -127) begin
            result[30:23] =8'b0;
            result[22:0] = mulResult[46:24];
          end
          else begin
            // sets the exponent
            result[30:23] = expResult[7:0];
            // sets the significand
            result[22:0] = mulResult[45:23];
          end
        end
      end
    end
  end
endmodule
