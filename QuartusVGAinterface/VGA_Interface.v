



`define DE10LITE

// these are the width and height per character (in pixels)
`define CHARW 6
`define CHARH 8
// this is the Rectangle size (RS) which is the ratio we used to scale our image
`define RS 5
// these are the width and height in terms of number of characters
`define WIDTH_CHARS 21
`define HEIGHT_CHARS 2
`define CHAR_COUNT (`WIDTH_CHARS * `HEIGHT_CHARS)


`define ERROR_COND(VAR) if (!iRST_n) VAR <= 0; else if (cHS==1'b0 && cVS==1'b0) VAR <= 0;


`ifdef DE10LITE
`define COLORW 4
`endif

module VGA_Interface(

	//////////// CLOCK //////////
	input 		          		ADC_CLK_10,
	input 		          		MAX10_CLK1_50,
	input 		          		MAX10_CLK2_50,

	//////////// SEG7 //////////
	output		     [7:0]		HEX0,
//	output		     [7:0]		HEX1,
//	output		     [7:0]		HEX2,
//	output		     [7:0]		HEX3,
//	output		     [7:0]		HEX4,
//	output		     [7:0]		HEX5,

	//////////// KEY //////////
//	input 		     [1:0]		KEY,

	//////////// LED //////////
//	output		     [9:0]		LEDR,

	//////////// SW //////////
//	input 		     [9:0]		SW,

	//////////// VGA //////////
	output		     [3:0]		VGA_R,
	output		     [3:0]		VGA_G,
	output		     [3:0]		VGA_B,
	output		          		VGA_HS,
	output		          		VGA_VS
);


wire VGA_CLK, DLY_RST;

bcd7seg sdf(4'd0, HEX0);
	
Reset_Delay reset
(
	.iCLK(MAX10_CLK1_50),
	.oRESET(DLY_RST)
);

VGA_PLL 
(
	.areset(~DLY_RST),
	.inclk0(MAX10_CLK1_50),
	.c0(VGA_CLK)
);
							 
VGA_controller VGA_CTRL
(
	.iVGA_CLK(VGA_CLK), 
	.iRST_n(DLY_RST), 
	
	.r_data(VGA_R),
	.g_data(VGA_G),
	.b_data(VGA_B),
	
	.oHS(VGA_HS),
	.oVS(VGA_VS)
);




endmodule

module	Reset_Delay(iCLK,oRESET);
input		iCLK;
output reg	oRESET;

parameter addrw = 19;

reg [addrw: 0] Cont;

always@(posedge iCLK)
begin
	if(Cont!={20{1'b1}})
	begin
		Cont	<=	Cont+1;
		oRESET	<=	1'b0;
	end
	else
	Cont <= 0;
	oRESET	<=	1'b1;
end

endmodule

module bcd7seg (num, display);
	input [3:0] num;
	output [6 : 0] display;

	reg [6 : 0] display;

	always @ (num)
		case (num)
			4'h0: display = 7'b1000000;
			4'h1: display = 7'b1111001;
			4'h2: display = 7'b0100100;
			4'h3: display = 7'b0110000;
			4'h4: display = 7'b0011001;
			4'h5: display = 7'b0010010;
			4'h6: display = 7'b0000010;
			4'h7: display = 7'b1111000;
			4'h8: display = 7'b0000000;
			4'h9: display = 7'b0010000;
			4'ha: display = 7'b0001000;
			4'hb: display = 7'b0000011;
			4'hc: display = 7'b1000110;
			4'hd: display = 7'b0100001;
			4'he: display = 7'b0000110;
			4'hf: display = 7'b0001110;
			default: display = 7'b1111111;
		endcase
endmodule