

module DM
(
    input clk, 
    input [4:0] ROBEN,
    input Read_en, Write_en,
    input [31 : 0] address,
    input [31 : 0] data,

    output reg [4:0] MEMU_ROBEN,
    output reg [31:0] MEMU_Result

);



integer i;
reg [31 : 0] DataMem [1023 : 0];
always @(negedge clk) begin
    if (Read_en) begin
        MEMU_Result <= DataMem[address[9:0]];
    end
    if (Write_en) begin
        DataMem[address] <= data;
    end
    MEMU_ROBEN <= ROBEN;
end
initial begin
for (i = 0; i < 1024; i = i + 1)
    DataMem[i] = 0;

`ifndef test
`include "DM_INIT.INIT"
`endif 


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