module DM(address, clock,  data,  rden,  wren,  q);

input clock, rden, wren;
input [31 : 0] address;
input [31 : 0] data;


integer i;
output reg [31 : 0] q;
reg [31 : 0] DataMem [1023 : 0];
always @(posedge clock) begin
    if (rden)
        q <= DataMem[address[9:0]];
    if (wren)
        DataMem[address] <= data;
end
initial begin
for (i = 0; i < 1024; i = i + 1)
    DataMem[i] <= 0;

// `include "DM_INIT.INIT"
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