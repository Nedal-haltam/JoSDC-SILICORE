


`include "Defs.txt"

module VGA_controller
(
	input iVGA_CLK,
	input iRST_n,
	input word_RunTimeData_FLAG_SW,

	output [`COLORW - 1:0] r_data,
	output [`COLORW - 1:0] g_data,
	output [`COLORW - 1:0] b_data,
	
	output reg oHS,
	output reg oVS,
	
	
	input manual_rst,
	input input_clk,
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

reg [0 : `length * 8 - 1] TextCurrentInst;

wire [addrw:0] FINAL_ADDR;
wire datasource;
wire [3*`COLORW - 1: 0] RGB_Static, RGB_Auto;
wire cBLANK_n,cHS,cVS;

wire [11:0] InstQ_opcode;
wire [4:0] InstQ_rs, InstQ_rt, InstQ_rd, InstQ_shamt;
wire [15:0] InstQ_immediate;
wire [25:0] InstQ_address;
wire [31:0] InstQ_PC;
wire [10:0] VGA_address;
wire VGA_clk;
wire [31:0] VGA_data;
wire word_RunTimeData_FLAG;

wire [0 : 2 * 8 - 1] text_rs;
wire [0 : 2 * 8 - 1] text_rt;
wire [0 : 2 * 8 - 1] text_rd;
wire [0 : 2 * 8 - 1] text_shamt;
wire [0 : 6 * 8 - 1] text_signed_immediate;
wire [0 : 6 * 8 - 1] text_unsigned_immediate;
wire [0 : 5 * 8 - 1] text_address;




////
video_sync_generator VSG 
(
	.vga_clk(iVGA_CLK),
	.reset(~iRST_n),
	.blank_n(cBLANK_n),
	.HS(cHS),
	.VS(cVS),
	.datasource(datasource)
);

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
	.address(VGA_address[7:0]),
	.word_RunTimeData_FLAG(word_RunTimeData_FLAG),
	.RunTimeData(VGA_data),
	.word({TextCurrentInst}),
	.RGB_out(RGB_Auto)
);
//////////////////////////////////////////////////////////////////////////////
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
	.InstQ_PC(InstQ_PC),
	.VGA_address(11'd500 - VGA_address),
    .VGA_clk(VGA_clk),
    .VGA_data(VGA_data)
);
FiveBit2text I2Trd
(
	.index(InstQ_rd),
	.text_index(text_rd)
);
FiveBit2text I2Trs
(
	.index(InstQ_rs),
	.text_index(text_rs)
);
FiveBit2text I2Trt
(
	.index(InstQ_rt),
	.text_index(text_rt)
);
FiveBit2text I2Tshamt
(
	.index(InstQ_shamt),
	.text_index(text_shamt)
);
SixTeenBit2text_signed immediate_signed
(
	.index(InstQ_immediate),
	.text_index(text_signed_immediate)
);
SixTeenBit2text_unsigned immediate_unsigned
(
	.index(InstQ_immediate),
	.text_index(text_unsigned_immediate)
);
TwentySixBit2text_unsigned address
(
	.index(InstQ_address),
	.text_index(text_address)
);

`define reg_char "X"
`define open_paren " " 
`define close_paren " " 
`define TEXT_RTYPE(mnemonic) TextCurrentInst <= {mnemonic, `reg_char, text_rd, `reg_char, text_rs, `reg_char, text_rt, `terminating_char}
always@(InstQ_opcode, InstQ_rt, InstQ_rs, InstQ_rd, InstQ_immediate) begin
case (InstQ_opcode)
	add :
	begin
	`TEXT_RTYPE("add ");
	end
	addu :
	begin
	`TEXT_RTYPE("addu ");
	end
	sub :
	begin
	`TEXT_RTYPE("sub ");
	end
	subu :
	begin
	`TEXT_RTYPE("subu ");
	end
	and_ :
	begin
	`TEXT_RTYPE("and ");
	end
	or_ :
	begin
	`TEXT_RTYPE("or  ");
	end
	xor_ :
	begin
	`TEXT_RTYPE("xor ");
	end
	nor_ :
	begin
	`TEXT_RTYPE("nor ");
	end
	sll :
	begin
	TextCurrentInst <= {"sll ", `reg_char, text_rd, `reg_char, text_rt, " ", text_shamt, `terminating_char};
	end
	srl :
	begin
	TextCurrentInst <= {"srl ", `reg_char, text_rd, `reg_char, text_rt, " ", text_shamt, `terminating_char};
	end
	slt :
	begin
	`TEXT_RTYPE("slt ");
	end
	sgt :
	begin
	`TEXT_RTYPE("sgt ");
	end
	jr :
	begin
	TextCurrentInst <= {"jr ", `reg_char, text_rs, `terminating_char}; 
	end
	addi :
	begin
	TextCurrentInst <= {"addi ", `reg_char, text_rt, `reg_char, text_rs, " ", text_signed_immediate, `terminating_char};
	end
	andi :
	begin
	TextCurrentInst <= {"andi ", `reg_char, text_rt, `reg_char, text_rs, " ", text_unsigned_immediate, `terminating_char}; 
	end
	ori :
	begin
	TextCurrentInst <= {"ori ", `reg_char, text_rt, `reg_char, text_rs, " ", text_unsigned_immediate, `terminating_char}; 
	end
	xori :
	begin
	TextCurrentInst <= {"xori ", `reg_char, text_rt, `reg_char, text_rs, " ", text_unsigned_immediate, `terminating_char}; 
	end
	lw :
	begin
	TextCurrentInst <= {"lw ", `reg_char, text_rt, " ", text_signed_immediate, `open_paren, `reg_char, text_rs, `close_paren}; 
	end
	sw :
	begin
	TextCurrentInst <= {"sw ", `reg_char, text_rt, " ", text_signed_immediate, `open_paren, `reg_char, text_rs, `close_paren}; 
	end
	slti :
	begin
	TextCurrentInst <= {"slti ", `reg_char, text_rt, `reg_char, text_rs, " ", text_signed_immediate, `terminating_char};
	end
	beq :
	begin
	TextCurrentInst <= {"beq ", `reg_char, text_rs, `reg_char, text_rt, " ", text_signed_immediate, `terminating_char};
	end
	bne :
	begin
	TextCurrentInst <= {"bne ", `reg_char, text_rs, `reg_char, text_rt, " ", text_signed_immediate, `terminating_char};
	end
	j :
	begin
	TextCurrentInst <= {"j ", text_address, `terminating_char}; 
	end
	jal :
	begin
	TextCurrentInst <= {"jal ", text_address, `terminating_char}; 
	end
	hlt_inst :
	begin
	TextCurrentInst <= {"hlt ", `terminating_char};
	end

endcase
end
//////////////////////////////////////////////////////////////////////////////







/*
TODO:
	- parenthesis
	- ability to switch between modes

- done: static mode: all from `ImageStatic` memory, (datasource = 1'b0)
- done: automatic mode: text from automAN, (datasource = 1'b1)
- done: MIX mode: from both (static image & autoMAN which is the current instruction from the CPU), (datasource = (boundary set in video_sync_generator))
- done: dualport mode: the VGA reads and the CPU writes
*/







//////latch valid data at falling edge;
always@(negedge iVGA_CLK) begin
	RGB_Data <= (datasource) ? RGB_Auto : RGB_Static;
end

assign r_data = (cBLANK_n == 1'b0) ? 0 : RGB_Data[1*`COLORW - 1: 0*`COLORW];
assign g_data = (cBLANK_n == 1'b0) ? 0 : RGB_Data[2*`COLORW - 1: 1*`COLORW];
assign b_data = (cBLANK_n == 1'b0) ? 0 : RGB_Data[3*`COLORW - 1: 2*`COLORW];
assign FINAL_ADDR = (tempADDRx / `RS) + (tempADDRy / `RS)*(128);
assign VGA_clk = iVGA_CLK;
assign VGA_address[10:8] = 3'd0;
assign word_RunTimeData_FLAG = word_RunTimeData_FLAG_SW;
///////////////////////////////////////////////////////////////////////////////////////////////////

//////Delay the iHD, iVD,iDEN for one clock cycle;
always@(negedge iVGA_CLK)
begin
  oHS<=cHS;
  oVS<=cVS;
end

endmodule
 	


module FiveBit2text
(
	input [4:0] index,
	output [0 : 2 * 8 - 1] text_index
);

wire [7:0] dig0;
wire [7:0] dig1;
assign dig0 = (index % 10) + 8'd48;
assign dig1 = ((index / 10) % 10) + 8'd48;
assign text_index = { dig1, dig0 };

endmodule

module SixTeenBit2text_signed
(
	input [15:0] index,
	output [0 : 6 * 8 - 1] text_index
);


wire [15:0] twoscomp;
assign twoscomp = ~index + 1'b1;


wire [7:0] dig0;
wire [7:0] dig1;
wire [7:0] dig2;
wire [7:0] dig3;
wire [7:0] dig4;
assign dig0 = (index       % 10     ) + 8'd48;
assign dig1 = ((index / 10) % 10    ) + 8'd48;
assign dig2 = ((index / 100) % 10   ) + 8'd48;
assign dig3 = ((index / 1000) % 10  ) + 8'd48;
assign dig4 = ((index / 10000) % 10 ) + 8'd48;

wire [7:0] twoscomp_dig0;
wire [7:0] twoscomp_dig1;
wire [7:0] twoscomp_dig2;
wire [7:0] twoscomp_dig3;
wire [7:0] twoscomp_dig4;
assign twoscomp_dig0 = (twoscomp       % 10     ) + 8'd48;
assign twoscomp_dig1 = ((twoscomp / 10) % 10    ) + 8'd48;
assign twoscomp_dig2 = ((twoscomp / 100) % 10   ) + 8'd48;
assign twoscomp_dig3 = ((twoscomp / 1000) % 10  ) + 8'd48;
assign twoscomp_dig4 = ((twoscomp / 10000) % 10 ) + 8'd48;

assign text_index = (index[15]) ? { "-", twoscomp_dig4, twoscomp_dig3, twoscomp_dig2, twoscomp_dig1, twoscomp_dig0 } : { " ", dig4, dig3, dig2, dig1, dig0 };

endmodule

module SixTeenBit2text_unsigned
(
	input [15:0] index,
	output [0 : 6 * 8 - 1] text_index
);

wire [7:0] dig0;
wire [7:0] dig1;
wire [7:0] dig2;
wire [7:0] dig3;
wire [7:0] dig4;

assign dig0 = (index       % 10     ) + 8'd48;
assign dig1 = ((index / 10) % 10    ) + 8'd48;
assign dig2 = ((index / 100) % 10   ) + 8'd48;
assign dig3 = ((index / 1000) % 10  ) + 8'd48;
assign dig4 = ((index / 10000) % 10 ) + 8'd48;
assign text_index = { " ", dig4, dig3, dig2, dig1, dig0 };

endmodule


module TwentySixBit2text_unsigned
(
	input [25:0] index,
	output [0 : 6 * 8 - 1] text_index
);

wire [7:0] dig0;
wire [7:0] dig1;
wire [7:0] dig2;
wire [7:0] dig3;
wire [7:0] dig4;

assign dig0 = (index       % 10     ) + 8'd48;
assign dig1 = ((index / 10) % 10    ) + 8'd48;
assign dig2 = ((index / 100) % 10   ) + 8'd48;
assign dig3 = ((index / 1000) % 10  ) + 8'd48;
assign dig4 = ((index / 10000) % 10 ) + 8'd48;
assign text_index = { " ", dig4, dig3, dig2, dig1, dig0 };

endmodule

