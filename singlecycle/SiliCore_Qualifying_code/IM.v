
module IM(address, q);

input [5:0] address;

output [31 : 0] q;

reg [31 : 0] InstMem [63 : 0];

assign q = InstMem[address];

initial begin
// here we initialize the instruction memory

InstMem[ 0] <= 32'hFC000000; // hlt


end


endmodule

// module IM(address, clock, q);

// input [5:0] address;
// input clock;

// output [31 : 0] q;

// reg [5:0] internal_address;
// reg [31 : 0] InstMem [63 : 0];

// always @(posedge clock) begin
//     internal_address <= address;
// end

// assign q = InstMem[internal_address];

// initial begin
// // here we initialize the instruction memory

// InstMem[0] <= 32'hFC000000; // hlt                  

// end


// endmodule

