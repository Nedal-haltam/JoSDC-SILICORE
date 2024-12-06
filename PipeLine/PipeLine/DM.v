module DM(addr , Data_In , Data_Out , WR , clk);

parameter bit_width = 32;
input [bit_width - 1:0] addr , Data_In;
input WR , clk;



`ifdef vscode

reg [31:0] DataMem [0:1023];
output reg [bit_width - 1:0] Data_Out;
always@ (posedge clk)  
    if (WR == 1'b1)
        DataMem[addr[9:0]] <= Data_In;
always@ (posedge clk) 
    Data_Out <= DataMem[addr[9:0]];
initial begin
`include "DM_INIT.INIT"
end

`else

output [bit_width - 1:0] Data_Out;
DataMemory_IP DataMemory
(
	addr[9:0],
	clk,
	Data_In,
	WR,
	Data_Out
);
	
`endif


`ifdef vscode
integer i;
initial begin
  #(`MAX_CLOCKS + `reset);
  // iterating through some of the addresses of the memory to check if the program loaded and stored the values properly
  $display("Data Memory Content : ");
  for (i = 0; i <= 50; i = i + 1)
    $display("Mem[%d] = %d",i[5:0],$signed(DataMem[i]));
end 
`endif
endmodule