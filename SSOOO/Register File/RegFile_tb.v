`include "RegFile.v"

`define HALF_CYCLE 1
`define ONE_CLK (2 * `HALF_CYCLE)
`define ADVANCE_N_CYCLE(N) #(2 * `HALF_CYCLE * N);

`define DISPLAYVALS(msg, index, data, N) \
clk_en = 0; \
    for (i = 0; i < N; i++) begin \
        index = i; \
        $sformat(temp, msg, index, data); \
        $display("%-100s", temp); \
    end \
clk_en = 1;

module RegFile_tb;

reg clk = 1, rst = 0;
reg WP1_Wen = 0, Decoded_WP1_Wen = 0;
reg [4:0] WP1_ROBEN = 0, Decoded_WP1_ROBEN = 0;
reg [4:0]                   WP1_DRindex = 0, Decoded_WP1_DRindex = 0;
reg [31:0]                  WP1_Data;
reg [4:0]   RP1_index1, RP1_index2;
wire [31:0] RP1_Reg1, RP1_Reg2;
wire [4 : 0] RP1_Reg1_ROBEN, RP1_Reg2_ROBEN;


reg [4:0] input_WP1_DRindex_test;
wire [4 : 0] output_ROBEN_test;

RegFile dut  
(
.clk(clk),
.rst(rst),

.WP1_Wen(WP1_Wen),
.Decoded_WP1_Wen(Decoded_WP1_Wen),
.WP1_ROBEN(WP1_ROBEN), 
.WP1_DRindex(WP1_DRindex), 
.WP1_Data(WP1_Data),
.Decoded_WP1_ROBEN(Decoded_WP1_ROBEN),
.Decoded_WP1_DRindex(Decoded_WP1_DRindex),

.RP1_index1(RP1_index1), 
.RP1_index2(RP1_index2),
.RP1_Reg1(RP1_Reg1),
.RP1_Reg2(RP1_Reg2),
.RP1_Reg1_ROBEN(RP1_Reg1_ROBEN),
.RP1_Reg2_ROBEN(RP1_Reg2_ROBEN)


, .input_WP1_DRindex_test(input_WP1_DRindex_test)
, .output_ROBEN_test(output_ROBEN_test)
);

reg clk_en = 0;
always begin
        #(`HALF_CYCLE) clk <= (~clk_en & clk) | (clk_en & ~clk);
end

integer i;

reg [1024*8:0] temp = "";
reg [1024*8:0] msg_RP1_Reg1 = "RP1_index1 = %d , RP1_Reg1 = %d";
reg [1024*8:0] msg_ROB_read = "Decoded_WP1_DRindex = %d , output_ROBEN_test = %d";
initial begin
$dumpfile("testout.vcd");
$dumpvars;
clk_en = 1;
rst = 1; `ADVANCE_N_CYCLE(1); rst = 0;

`DISPLAYVALS(msg_RP1_Reg1, RP1_index1, RP1_Reg1, 10);
`DISPLAYVALS(msg_ROB_read, input_WP1_DRindex_test, output_ROBEN_test, 10);

WP1_Wen = 1'b1;
WP1_Data = 32'd123;
WP1_DRindex = 5'd1; 
WP1_ROBEN = 2;

Decoded_WP1_Wen = 1'b1;
Decoded_WP1_ROBEN = 2;
Decoded_WP1_DRindex = 5'd1;
`ADVANCE_N_CYCLE(1); // after one positive edge and one negative edge, respectively
// it first tries to update the register file but it could not 
// because the ROB entry is not updated yet
`DISPLAYVALS(msg_RP1_Reg1, RP1_index1, RP1_Reg1, 10);
`DISPLAYVALS(msg_ROB_read, input_WP1_DRindex_test, output_ROBEN_test, 10);

Decoded_WP1_ROBEN = 0;
`ADVANCE_N_CYCLE(1); // after one positive edge and one negative edge, respectively
// here the ROB entry is updated so it will try to udpate the register file 
// and it will succeed because there is a match in the ROB entry numbers
`DISPLAYVALS(msg_RP1_Reg1, RP1_index1, RP1_Reg1, 10);
`DISPLAYVALS(msg_ROB_read, input_WP1_DRindex_test, output_ROBEN_test, 10);

// TODO: testing to be continued for sure but this is a good indicator that the thing works


// it is important to put $stop or $finish to terminate the simulation because 
// the line: always #1 clk = ~clk;, will force the simulation to cotinue and you should terminate manually
$finish;
end


endmodule