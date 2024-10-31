module IM(addr , Data_Out);

parameter bit_width = 32;
input [bit_width - 1:0] addr;
output [bit_width - 1:0] Data_Out;

(* ram_style = "block" *) reg [bit_width - 1:0] inst_mem [255 : 0];

assign Data_Out = inst_mem[addr];

 
initial begin

inst_mem[0] <= 32'h2021000A; 
inst_mem[1] <= 32'h20420001; 
inst_mem[2] <= 32'hAC210000; 
inst_mem[3] <= 32'h220822; 
inst_mem[4] <= 32'hFC000000; 
inst_mem[5] <= 32'h1420FFFD; 




end

/*
addi x1, x1, 10
addi x2, x2, 1

l:

sw x1, x1, 0
sub x1, x1, x2
hlt
bne x1, x0, l
*/
      
endmodule