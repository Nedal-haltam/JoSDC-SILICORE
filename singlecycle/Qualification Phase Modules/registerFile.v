// register file contains 32 register

module registerFile (clk, rst, we, 
					 readRegister1, readRegister2, writeRegister,
					 writeData, readData1, readData2);

	// inputs
	input wire clk, rst, we;
	input wire [4:0] readRegister1, readRegister2, writeRegister;
	input wire [31:0] writeData;
	
	// outputs
	output wire [31:0] readData1, readData2;
	
	// register file (registers)
	reg [31:0] registers [0:31];
	
	// Read from the register file
	assign readData1 = registers[readRegister1];
  assign readData2 = registers[readRegister2];
						
  						//design specifications about reset; sync vs. async? *check
  always@(posedge clk,  negedge rst) begin : Write_on_register_file_block
	
		integer i;   //usually variable definition is outside of the always-statement *check if it causes issues
		// Reset the register file
		if(~rst) begin
      for(i=0; i<32; i = i + 1) registers[i] <= 0; //it was = I changed it to <= for non-blocking assignment 
		end
		// Write to the register file
		else if(we) begin
			registers[writeRegister] <= writeData;
      registers[0] <= 32'b0; //added this line because writing on register 0 is illegal for MIPS-like architecture 
		end
		// Defualt to prevent latching
		else;
		
	end
endmodule

/*
//additional testbench 
module tb();
  reg clk, rst, we;
  reg [4:0] readRegister1, readRegister2, writeRegister;
  reg [31:0] writeData;
  
  wire [31:0] readData1, readData2;
  
  registerFile testing(clk, rst, we, 
					             readRegister1, readRegister2, writeRegister,
					             writeData, readData1, readData2);
  
  always #50 clk = ~clk;
  
  initial begin
    clk = 0;
    rst = 0;
    #100
    rst = 1;
    readRegister1 = 5'b1;
    readRegister2 = 5'b11;
    writeRegister = 5'b11;
    writeData = 32'b1010101;
    we = 1'b1; 
    #100 $display(readData1, " ", readData2);
    
    we = 1'b0;
    #100 $display(readData1, " ", readData2);
    
    #1000 $finish;
    
  end
endmodule
*/
