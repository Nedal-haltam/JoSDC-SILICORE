`ifdef vscode
module DM(addr , Data_In , Data_Out , WR , clk);

parameter bit_width = 32;
input [bit_width - 1:0] addr , Data_In;
input WR , clk;
// output [bit_width - 1:0] Data_Out;
output reg [bit_width - 1:0] Data_Out;

reg [bit_width - 1:0] data_mem [1023 : 0];
  
always@ (posedge clk)  
  if (WR == 1'b1)
    data_mem[addr] <= Data_In;


always@ (posedge clk) 
  Data_Out <= data_mem[addr];




`ifdef vscode
initial begin
  #(`MAX_CLOCKS + `reset);
  // iterating through some of the addresses of the memory to check if the program loaded and stored the values properly
  $display("Data Memory Content : ");
  for (integer i = 0; i <= 19; i = i + 1)
    $display("Mem[%d] = %d",i[4:0],$signed(data_mem[i]));

end 
`endif
      
endmodule
`else
module DM(addr , Data_In , Data_Out , WR , clk);

parameter bit_width = 32;
input [bit_width - 1:0] addr , Data_In;
input WR , clk;
// output [bit_width - 1:0] Data_Out;
output reg [bit_width - 1:0] Data_Out;

reg [bit_width - 1:0] data_mem [1023 : 0];
  
always@ (posedge clk)  
  if (WR == 1'b1)
    data_mem[addr] <= Data_In;


always@ (posedge clk) 
  Data_Out <= data_mem[addr];




`ifdef vscode
initial begin
  #(`MAX_CLOCKS + `reset);
  // iterating through some of the addresses of the memory to check if the program loaded and stored the values properly
  $display("Data Memory Content : ");
  for (integer i = 0; i <= 19; i = i + 1)
    $display("Mem[%d] = %d",i[4:0],$signed(data_mem[i]));

end 
`endif
      
endmodule
`endif