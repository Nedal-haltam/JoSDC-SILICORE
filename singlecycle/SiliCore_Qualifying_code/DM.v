`ifdef vscode
module DM(address, clock,  data,  rden,  wren,  q);

    input clock, rden, wren;
    input [7 : 0] address;
    input [31 : 0] data;

    output reg [31 : 0] q;

    reg [31 : 0] data_mem [1023 : 0];

    always @(negedge clock) begin
        if (rden)
            q <= data_mem[address];
        if (wren)
            data_mem[address] <= data;
    end


`ifdef vscode
integer i;
initial begin
  #(`MAX_CLOCKS + `reset);
  // iterating through some of the addresses of the memory to check if the program loaded and stored the values properly
  $display("Data Memory Content : ");
  for (i = 0; i <= 19; i = i + 1)
    $display("Mem[%d] = %d",i[4:0],$signed(data_mem[i]));
end 
`endif


endmodule
`endif