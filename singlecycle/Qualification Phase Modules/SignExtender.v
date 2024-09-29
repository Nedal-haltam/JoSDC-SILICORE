// sign Extender
// input is 16 bit, output is 32 bit

module SignExtender(in, out);

	//inputs
	input [15:0] in;
	
	//outputs
	output [31:0] out;
	
	// Unit logic
	assign out = {{16{in[15]}}, in};
	
endmodule

/*
//additional testbench
module tb();
  reg [15:0] in;
  wire [31:0] out;
  
  SignExtender testing(in, out);
  
  initial 
    begin
      in=16'b1111111111111111;
      #10 $display("%b", out);       
    end

endmodule
*/
