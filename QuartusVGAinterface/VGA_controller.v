


`include "Defs.txt"

module VGA_controller
(
	input fpga_clk,
	input iVGA_CLK,
	input iRST_n,
	
	output [`COLORW - 1:0] r_data,
	output [`COLORW - 1:0] g_data,
	output [`COLORW - 1:0] b_data,
	
	output reg oHS,
	output reg oVS,
	
	
	input manual_rst,
	output input_clk,
	output [31:0] cycles_consumed,
	output [31:0] PC,
	output hlt
);

parameter addrw = 19;
parameter width = 640;
parameter height = 480;

reg  [3*`COLORW - 1: 0] RGB_Data;
reg [addrw:0] tempADDRx;
reg [addrw:0] tempADDRy;
reg [addrw:0] ADDR;

wire [addrw:0] FINAL_ADDR;
wire datasource;
wire [3*`COLORW - 1: 0] RGB_Static, RGB_Auto;
wire cBLANK_n,cHS,cVS;

////
video_sync_generator VSG (.vga_clk(iVGA_CLK),
                              .reset(~iRST_n),
                              .blank_n(cBLANK_n),
                              .HS(cHS),
                              .VS(cVS),
										.datasource(datasource));
////
////Addresss generator
always@(posedge iVGA_CLK , negedge iRST_n) 
begin

if (!iRST_n) 
	ADDR <= 0; 
else if (cHS==1'b0 && cVS==1'b0) 
	ADDR <= 0;
else if (cBLANK_n==1'b1)
	ADDR <= ADDR + 1;

end

always@(posedge iVGA_CLK , negedge iRST_n) begin
// ADDR = 0 -> 307200
// tempADDRx = 0 -> 127
// tempADDRy = 0 -> 95
if (!iRST_n)
begin
   tempADDRx <= 0;
   tempADDRy <= 0;
end	
else if (cHS==1'b0 && cVS==1'b0)
begin
   tempADDRx <= 0;
   tempADDRy <= 0;
end	

else if (cBLANK_n == 1'b1)
begin
  if (tempADDRx == width - 1)
  begin 
     tempADDRx <= 0;
     if (tempADDRy == height - 1)
        tempADDRy <= 0;
     else
        tempADDRy <= tempADDRy + 1;
  end
  else
     tempADDRx <= tempADDRx + 1;
end

end


assign FINAL_ADDR = (tempADDRx / `RS) + (tempADDRy / `RS)*(128);

//////////////////////////
//////INDEX addr.
// here is where our image is stored
`ifdef DE10LITE
ImageStatic IMG
(
	.address ( FINAL_ADDR ),
	.clock ( iVGA_CLK ),
	.q ( RGB_Static )
);
`endif

autoMAN automan
(
	.iVGA_CLK(iVGA_CLK), 
	.iRST_n(iRST_n), 
	.enable(datasource), 
	.cHS(cHS), 
	.cVS(cVS), 
	.RGB_out(RGB_Auto)
);

reg [24:0] clk_divider = 0;
always@(posedge fpga_clk) begin
		clk_divider <= clk_divider + 1'b1;
end
assign input_clk = clk_divider[20];
SSOOO_CPU cpu
(
    .input_clk(input_clk), 
	 .rst(manual_rst),
    .cycles_consumed(cycles_consumed),
	 .PC_out(PC),
	 .hlt(hlt)
);



/*
TODO:
	- ability to switch between the modes: 
		- static mode: all from `ImageStatic` memory
		- automatic mode: text from automAN
		- MIX mode: from both and they should be organized we they don't overlap: e.g. static text + current instruction from the CPU
		- dualport mode: the VGA reads and the CPU writes
*/







//////latch valid data at falling edge;
always@(negedge iVGA_CLK) begin

RGB_Data <= (datasource) ? RGB_Auto : RGB_Static;

end

assign r_data = (cBLANK_n == 1'b0) ? 0 : RGB_Data[1*`COLORW - 1: 0*`COLORW];
assign g_data = (cBLANK_n == 1'b0) ? 0 : RGB_Data[2*`COLORW - 1: 1*`COLORW];
assign b_data = (cBLANK_n == 1'b0) ? 0 : RGB_Data[3*`COLORW - 1: 2*`COLORW];

///////////////////
//////Delay the iHD, iVD,iDEN for one clock cycle;
always@(negedge iVGA_CLK)
begin
  oHS<=cHS;
  oVS<=cVS;
end

endmodule
 	
















