module DM(address, clock,  data,  rden,  wren,  q);

    input clock, rden, wren;
    input [7 : 0] address;
    input [31 : 0] data;

    output reg [31 : 0] q;

    reg [31 : 0] datamem [255 : 0];

    always @(posedge clock) begin
        if (rden)
            q <= datamem[address];
        if (wren)
            datamem[address] <= data;
    end


`ifdef sim
integer i;
initial begin
  #(`timetowait + 4);
  // iterating through some of the addresses of the memory to check if the program loaded and stored the values properly
  $display("Reading Data Memory Content : ");
  for (i = 30; i >= 0; i = i - 1)
    $display("Mem[%d] = %d",i[4:0],$signed(datamem[i]));
end 
`endif


endmodule