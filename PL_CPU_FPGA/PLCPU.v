 module PLCPU(

 	//////////// CLOCK //////////
 	input 		          		ADC_CLK_10,
 	input 		          		MAX10_CLK1_50,
 	input 		          		MAX10_CLK2_50,

 	//////////// SEG7 //////////
 	output		     [7:0]		HEX0,
 	output		     [7:0]		HEX1,
 	output		     [7:0]		HEX2,
 	output		     [7:0]		HEX3,
 	output		     [7:0]		HEX4,
 	output		     [7:0]		HEX5,

 	//////////// KEY //////////
 	input 		     [1:0]		KEY,

 	//////////// LED //////////
 	output		     [9:0]		LEDR,

 	//////////// SW //////////
 	input 		     [9:0]		SW,

 	//////////// VGA //////////
 	output		     [3:0]		VGA_B,
 	output		     [3:0]		VGA_G,
 	output		          		VGA_HS,
 	output		     [3:0]		VGA_R,
 	output		          		VGA_VS
 );
 wire input_clk, hlt_c, rst;
 wire [31:0] dataout;
 
 CPU5STAGE cpu(input_clk, hlt_c, rst, dataout);
 
 assign input_clk = SW[0]; // LE: 11,504
// assign input_clk = ADC_CLK_10; // LE: 11,530
// assign input_clk = MAX10_CLK1_50; // LE: 12,331
 assign hlt_c     = SW[1];
 assign rst       = SW[2];

 
 bcd7seg b(dataout[3:0] , HEX1[6:0]);
 
 endmodule 

 
 
 
 
//module PLCPU(
// input  [3:0] KEY, 
// output [8:0] LEDG,
// output [6:0] HEX0,
// output [6:0] HEX1,
// output [6:0] HEX2,
// output [6:0] HEX3,
// output [6:0] HEX4,
// output [6:0] HEX5,
// output [6:0] HEX7
//);
//
// wire clk, rst, hlt;
// wire [5:0] PC;
// wire [31 : 0] data;
//// wire [31 : 0] regs0;
//// wire [31 : 0] regs1;
//// wire [31 : 0] regs2;
//// wire [31 : 0] regs3;
//// wire [31 : 0] regs4;
//// wire [31 : 0] regs5;
//
// CPU5STAGE cpu(PC, clk, hlt, rst, data);
//
//
//assign rst = ~KEY[0];
//assign clk = ~KEY[1];
//assign LEDG[0] = rst;
//assign LEDG[1] = clk;
//
//assign hlt = ~KEY[2];
//
// bcd7seg pccounter(PC[3 : 0], HEX7);
// bcd7seg dataa(data[3:0], HEX0);
// 
// 
//// bcd7seg (regs0[3 : 0], HEX0);
//// bcd7seg (regs1[3 : 0], HEX1);
//// bcd7seg (regs2[3 : 0], HEX2);
//// bcd7seg (regs3[3 : 0], HEX3);
//// bcd7seg (regs4[3 : 0], HEX4);
//// bcd7seg (regs5[3 : 0], HEX5);
// 
// endmodule 
//
//
//
