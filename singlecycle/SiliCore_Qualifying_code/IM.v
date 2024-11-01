module IM(address, clock, q);

input [5:0] address;
input clock;

output [31 : 0] q;

reg [5:0] internal_address;
reg [31 : 0] inst_mem [63 : 0];

always @(posedge clock) begin
    internal_address <= address;
end

assign q = inst_mem[internal_address];

initial begin
// here we initialize the instruction memory
inst_mem[0] <= 32'h20010009; 
inst_mem[1] <= 32'h20420001; 
inst_mem[2] <= 32'h10410002; 
inst_mem[3] <= 32'h1021FFFE; 
inst_mem[4] <= 32'hFC000000; 
inst_mem[5] <= 32'h20030003; 







end


endmodule
