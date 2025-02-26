
`define MEMORY_SIZE 4096
`define MEMORY_BITS 12

module DM(addr , Data_In , Data_Out , Write_en , clk);

input [31:0] addr , Data_In;
input Write_en , clk;



`ifdef vscode

reg [31:0] DataMem [0 : (`MEMORY_SIZE-1)];
output reg [31:0] Data_Out;

always@ (posedge clk)  
    if (Write_en == 1'b1)
        DataMem[addr[(`MEMORY_BITS-1):0]] <= Data_In;
always@ (posedge clk) 
    Data_Out <= DataMem[addr[(`MEMORY_BITS-1):0]];

initial begin
for (i = 0; i <= (`MEMORY_SIZE-1); i = i + 1)
    DataMem[i] <= 0;

`include "DM_INIT.INIT"
end

`else

output [31:0] Data_Out;
DataMemory_IP DataMemory
(
	addr[(`MEMORY_BITS-1):0],
	clk,
	Data_In,
	Write_en,
	Data_Out
);
	
`endif


`ifdef vscode
integer i;
initial begin
  #(`MAX_CLOCKS + `reset);
  // iterating through some of the addresses of the memory to check if the program loaded and stored the values properly
  $display("Data Memory Content : ");
  for (i = 0; i <= (`MEMORY_SIZE-1); i = i + 1)
    $display("Mem[%d] = %d",i[(`MEMORY_BITS-1):0],$signed(DataMem[i]));
end 
`endif
endmodule