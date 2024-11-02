
module PC_register(addr_in, addr_out, PC_Write, clk, rst);
	
	input [31:0] addr_in;
	input clk, rst;
	input PC_Write;
	
  output reg [31:0] addr_out;
	

parameter initialaddr = -1;

	always@(posedge clk, posedge rst) begin 

    if (rst)
        addr_out <= initialaddr;
      
	else if (PC_Write)
		addr_out <= addr_in;
		
	end
	
endmodule