


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

module VGA_controller
(
	input iVGA_CLK,
	input iRST_n,
	
	output [`COLORW - 1:0] r_data,
	output [`COLORW - 1:0] g_data,
	output [`COLORW - 1:0] b_data,
	
	output reg oHS,
	output reg oVS
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
wire [3*`COLORW - 1: 0] RGB_Static;
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


//////latch valid data at falling edge;
always@(negedge iVGA_CLK) begin

//if (datasource == 1'b1)
//	RGB_Data <= rgb_from_cpu;
//else
	RGB_Data <= RGB_Static;

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
 	
















