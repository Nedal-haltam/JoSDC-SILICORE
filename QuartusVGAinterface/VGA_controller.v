


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

`include "opcodes.txt"

parameter addrw = 19;
parameter width = 640;
parameter height = 480;

reg  [3*`COLORW - 1: 0] RGB_Data;
reg [addrw:0] tempADDRx;
reg [addrw:0] tempADDRy;
reg [addrw:0] ADDR;

reg [0 : 4 * 8 - 1]text_opcode;
reg [0 : 3 * 8 - 1]text_rs;
reg [0 : 3 * 8 - 1]text_rt;
reg [0 : 3 * 8 - 1]text_rd;
reg [0 : 2 * 8 - 1]text_shamt;
reg [0 : 5 * 8 - 1]text_immediate;
reg [0 : 5 * 8 - 1]text_address;
reg [0 : 5 * 8 - 1]text_PC;

wire [addrw:0] FINAL_ADDR;
wire datasource;
wire [3*`COLORW - 1: 0] RGB_Static, RGB_Auto;
wire cBLANK_n,cHS,cVS;

wire [11:0] InstQ_opcode;
wire [4:0] InstQ_rs, InstQ_rt, InstQ_rd, InstQ_shamt;
wire [15:0] InstQ_immediate;
wire [25:0] InstQ_address;
wire [31:0] InstQ_PC;


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

//////////////////////////////////////////////////////////////////////////////
`ifdef DE10LITE
ImageStatic IMG
(
	.address ( FINAL_ADDR ),
	.clock ( iVGA_CLK ),
	.q ( RGB_Static )
);
`endif
//////////////////////////////////////////////////////////////////////////////
autoMAN automan
(
	.iVGA_CLK(iVGA_CLK), 
	.iRST_n(iRST_n), 
	.enable(datasource), 
	.cHS(cHS), 
	.cVS(cVS), 
	.word({text_opcode}),
	// .word({"text opcode", `terminating_char}),
	.RGB_out(RGB_Auto)
);
//////////////////////////////////////////////////////////////////////////////
reg [24:0] clk_divider = 0;
// wire cpuclk;
// CPU_PLL cpupll
// (
// 	.areset(1'b0),
// 	.inclk0(fpga_clk),
// 	.c0(cpuclk)
// );
always@(posedge fpga_clk) begin
	clk_divider <= clk_divider + 1'b1;
end
assign input_clk = clk_divider[20];
// always@(posedge cpuclk) begin
// 	clk_divider <= clk_divider + 1'b1;
// end
// assign input_clk = clk_divider[6];


`define text
`ifndef text
SSOOO_CPU cpu
(
    .input_clk(input_clk), 
	.rst(manual_rst),
	.cycles_consumed(cycles_consumed),
	.PC_out(PC),
	.hlt(hlt)
);
`else
SSOOO_CPU cpu
(
    .input_clk(input_clk), 
	.rst(manual_rst),
    .cycles_consumed(cycles_consumed),
	.PC_out(PC),
	.hlt(hlt),
	.InstQ_opcode(InstQ_opcode),
	.InstQ_rs(InstQ_rs), 
	.InstQ_rt(InstQ_rt), 
	.InstQ_rd(InstQ_rd), 
	.InstQ_shamt(InstQ_shamt),
	.InstQ_immediate(InstQ_immediate),
	.InstQ_address(InstQ_address),
	.InstQ_PC(InstQ_PC)
);
always@(InstQ_opcode) begin
case (InstQ_opcode)
	add      : text_opcode <= "add ";
	addu     : text_opcode <= "addu";
	sub      : text_opcode <= "sub ";
	subu     : text_opcode <= "subu";
	and_     : text_opcode <= "and ";
	or_      : text_opcode <= "or  ";
	xor_     : text_opcode <= "xor ";
	nor_     : text_opcode <= "nor ";
	sll      : text_opcode <= "sll ";
	srl      : text_opcode <= "srl ";
	slt      : text_opcode <= "slt ";
	sgt      : text_opcode <= "sgt ";
	jr       : text_opcode <= "jr  ";
	addi     : text_opcode <= "addi";
	andi     : text_opcode <= "andi";
	ori      : text_opcode <= "ori ";
	xori     : text_opcode <= "xori";
	lw       : text_opcode <= "lw  ";
	sw       : text_opcode <= "sw  ";
	slti     : text_opcode <= "slti";
	beq      : text_opcode <= "beq ";
	bne      : text_opcode <= "bne ";
	j        : text_opcode <= "j   ";
	jal      : text_opcode <= "jal ";
	hlt_inst : text_opcode <= "hlt ";
endcase
end
`endif

/*
next step is to display the current instruction that's being (fetched/commited/executed)
take the info and convert them into indicies directly by decoding them (if-elseif-...) or case statement
if (opcode == sdf)
	opcode_text = `corresponding text`
	
text = {opcode_text, rd_text, rs_text, rt_text, label_text, ☺}
now you have a text you can display it by inserting it into autoMAN


TODO:
	- ability to switch between the modes: 
		- static mode: all from `ImageStatic` memory
		- automatic mode: text from automAN
		- MIX mode: from both and they should be organized we they don't overlap: e.g. autoMAN + current instruction from the CPU
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
 	
















