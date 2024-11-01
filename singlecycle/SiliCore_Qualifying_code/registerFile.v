// register file contains 32 register

module registerFile (clk, rst, we, 
					 readRegister1, readRegister2, writeRegister,
					 writeData, readData1, readData2, regs0, regs1, regs2, regs3, regs4, regs5);
// module registerFile (clk, rst, we, 
// 					 readRegister1, readRegister2, writeRegister,
// 					 writeData, readData1, readData2);

	// inputs
	input wire clk, rst, we;
	input wire [4:0] readRegister1, readRegister2, writeRegister;
	input wire [31:0] writeData;
	

	
	
	output [31 : 0] regs0;
	output [31 : 0] regs1;
	output [31 : 0] regs2;
	output [31 : 0] regs3;
	output [31 : 0] regs4;
	output [31 : 0] regs5;
	// outputs
	output wire [31:0] readData1, readData2;
	
	// register file (registers)
	reg [31:0] registers [0:31];
	
	// Read from the register file
	assign readData1 = registers[readRegister1];
  assign readData2 = registers[readRegister2];
						
  						
  always@(posedge clk,  negedge rst) begin : Write_on_register_file_block
	
		integer i;
		// Reset the register file
		if(~rst) begin
			for(i=0; i<32; i = i + 1) registers[i] <= 0; //it was = I changed it to <= for non-blocking assignment ID = 8
		end
		// Write to the register file
		else if(we) begin
			registers[writeRegister] <= writeData;
			registers[0] <= 32'b0; //added this line because writing on register 0 is illegal for MIPS-like architecture ID = 9
		end
		// Defualt to prevent latching
		else;
		
	end

	
	
	assign regs0 = registers[1];
	assign regs1 = registers[2];
	assign regs2 = registers[3];
	assign regs3 = registers[4];
	assign regs4 = registers[5];
	assign regs5 = registers[6];
	
	
	
`ifdef sim
integer i;
initial begin
  #(`timetowait);
  $display("Reading Register File : ");
  for (i = 31; i >= 0; i = i - 1)
    $display("index = %d , reg_out : signed = %d , unsigned = %d",i, $signed(registers[i]), $unsigned(registers[i]));

end 
`endif

endmodule