



`define MEMORY_SIZE 4096
`define MEMORY_BITS 12 

module DM(address, clock,  data,  rden,  wren,  q);

input clock, rden, wren;
input [31 : 0] address;
input [31 : 0] data;


`ifdef vscode
output reg [31 : 0] q;
reg [31 : 0] DataMem [0 : (`MEMORY_SIZE-1)];
always @(posedge clock) begin
    if (rden)
        q <= DataMem[address[(`MEMORY_BITS-1):0]];
    if (wren)
        DataMem[address] <= data;
end
initial begin
for (i = 0; i <= (`MEMORY_SIZE-1); i = i + 1)
    DataMem[i] <= 0;

`include "DM_INIT.INIT"
end

`else

output [31:0] q;
DataMemory_IP DataMemory
(
	address[(`MEMORY_BITS-1):0],
	clock,
	data,
	wren,
	q
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