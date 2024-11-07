module programCounter (clk, rst, PCin, PCout);
	
	//inputs
	input clk, rst;
	input [31:0] PCin;
	
	//outputs 
	output reg [31:0] PCout;
	
	parameter initialaddr = -1;
	//Counter logic
	always@(posedge clk, negedge rst) begin
		if(~rst) begin
			PCout <= initialaddr;
		end
		else begin
			PCout <= PCin;
		end
	end
	
endmodule
