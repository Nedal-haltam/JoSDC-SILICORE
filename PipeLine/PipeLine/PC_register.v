
module PC_register(DataIn, DataOut, PC_Write, clk, rst);
	
input [31:0] DataIn;
input clk, rst;
input PC_Write;

output reg [31:0] DataOut;
	

parameter initialaddr = -1;

always@(posedge clk, posedge rst) begin 

if (rst)
	DataOut <= initialaddr;      
else if (PC_Write)
	DataOut <= DataIn;		

end
	
endmodule