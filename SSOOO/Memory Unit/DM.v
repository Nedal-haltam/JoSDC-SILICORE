

module DM
(
    input clk, 
    input [4:0] ROBEN,
    input Read_en, Write_en,
    input [31 : 0] address,
    input [31 : 0] data,
    output reg MEMU_invalid_address,
    output reg [4:0] MEMU_ROBEN,
`ifdef vscode
    output reg [31:0] MEMU_Result
`else
    output [31:0] MEMU_Result
`endif
);
integer i;



`ifdef vscode

reg [31 : 0] DataMem [0 : 1023];
always @(negedge clk) begin
    if (~MEMU_invalid_address) begin
        if (Read_en) begin
            MEMU_Result <= DataMem[address[9:0]];
        end
        if (Write_en) begin
            DataMem[address] <= data;
        end
        MEMU_ROBEN <= ROBEN;
    end
end
initial begin
for (i = 0; i < 1024; i = i + 1)
    DataMem[i] = 0;

`ifdef test
`include "./Memory Unit/DM_INIT.INIT"
`else
`include "DM_INIT.INIT"
`endif 
end

`else

always@(negedge clk) begin
    MEMU_ROBEN <= ROBEN;
//    MEMU_invalid_address <= ~(32'd0 <= address && address <= 32'd1023);
end
DataMemory_IP DataMemory
(
	address[9:0],
	~clk,
	data,
	Write_en,
	MEMU_Result
);

`endif

always@(posedge clk) begin
    MEMU_invalid_address <= ~(0 <= address && address <= 1023);
    // MEMU_invalid_address <= 1'b0;
end




`ifdef vscode
initial begin
  #(`MAX_CLOCKS + `reset);
  // iterating through some of the addresses of the memory to check if the program loaded and stored the values properly
  $display("Data Memory Content : ");
  for (i = 0; i <= 50; i = i + 1)
    $display("Mem[%d] = %d",i[5:0],$signed(DataMem[i]));
end 
`endif
endmodule
