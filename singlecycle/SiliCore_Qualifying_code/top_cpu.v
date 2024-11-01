



 // this module is for FPGA testing
 module top_cpu(
 input        CLOCK_ADC_10,
 input  [3:0] KEY,
 output [9:0] LEDR,
 output [6:0] HEX0,
 output [6:0] HEX1,
 output [6:0] HEX2,
 output [6:0] HEX3,
 output [6:0] HEX4,
 output [6:0] HEX5,
 input  [8:0] SW
// ,output [6:0] HEX7

 );

 reg [23 : 0] clk_counter;
 wire clk, rst, clkout;
 wire [5:0] PC;
 wire [31 : 0] cycles_consumed;
 wire [31 : 0] regs0;
 wire [31 : 0] regs1;
 wire [31 : 0] regs2;
 wire [31 : 0] regs3;
 wire [31 : 0] regs4;
 wire [31 : 0] regs5;
 
 
 
 
 always@ (posedge CLOCK_ADC_10 , negedge rst) begin
 
 
	if (~rst)
		clk_counter <= 0;
	else begin
		if (clk_counter == {24{1'b1}})
			clk_counter <= 0;
		else
			clk_counter <= clk_counter + 1;
	end
 
 
 
 end
 

 processor cpu(clk, rst, PC, regs0, regs1, regs2, regs3, regs4, regs5, cycles_consumed, clkout);


assign rst = KEY[0];
//assign clk = ~KEY[1]; 
assign clk = clk_counter[23];
//assign clk = SW[0];
assign LEDR[0] = rst;
assign LEDR[1] = clk;
assign LEDR[2] = clkout;
assign LEDR[9:5] = cycles_consumed[4:0];


 
 bcd7seg (regs0[3 : 0], HEX0);
 bcd7seg (regs1[3 : 0], HEX1);
 bcd7seg (regs2[3 : 0], HEX2);
 bcd7seg (regs3[3 : 0], HEX3);
 bcd7seg (regs4[3 : 0], HEX4);
 bcd7seg pccounter(PC[3 : 0], HEX5);
// bcd7seg (regs5[3 : 0], HEX5);
// bcd7seg pccounter(PC[3 : 0], HEX7);


 endmodule