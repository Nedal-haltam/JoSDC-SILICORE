module IM(addr , Data_Out);

parameter bit_width = 32;
input [bit_width - 1:0] addr;
output [bit_width - 1:0] Data_Out;

(* ram_style = "block" *) reg [bit_width - 1:0] InstMem [255 : 0];

assign Data_Out = InstMem[addr];

 
initial begin

InstMem[  0] <= 32'h20010064; // addi x1 x0 100       
InstMem[  1] <= 32'hAC010001; // sw x1 x0 1           
InstMem[  2] <= 32'h2020007B; // addi x0 x1 123       
InstMem[  3] <= 32'h2002FFFE; // addi x2 x0 -2        
InstMem[  4] <= 32'hAC420002; // sw x2 x2 2           
InstMem[  5] <= 32'h00221820; // add x3 x1 x2         
InstMem[  6] <= 32'hAC63FFA0; // sw x3 x3 -96         
InstMem[  7] <= 32'h00220020; // add x0 x1 x2         
InstMem[  8] <= 32'h00622022; // sub x4 x3 x2         
InstMem[  9] <= 32'h00822022; // sub x4 x4 x2         
InstMem[ 10] <= 32'hAC040003; // sw x4 x0 3           
InstMem[ 11] <= 32'h00622823; // subu x5 x3 x2        
InstMem[ 12] <= 32'h00223021; // addu x6 x1 x2        
InstMem[ 13] <= 32'h00C23022; // sub x6 x6 x2         
InstMem[ 14] <= 32'h3407B676; // ori x7 x0 -18826     
InstMem[ 15] <= 32'hAC070004; // sw x7 x0 4           
InstMem[ 16] <= 32'h00E34024; // and x8 x7 x3         
InstMem[ 17] <= 32'h31090020; // andi x9 x8 32        
InstMem[ 18] <= 32'h01095026; // xor x10 x8 x9        
InstMem[ 19] <= 32'h394BFFFF; // xori x11 x10 -1      
InstMem[ 20] <= 32'h356C0042; // ori x12 x11 66       
InstMem[ 21] <= 32'h396D0042; // xori x13 x11 66      
InstMem[ 22] <= 32'h000A7040; // sll x14 x10 1        
InstMem[ 23] <= 32'h000E7882; // srl x15 x14 2        
InstMem[ 24] <= 32'h0022802A; // slt x16 x1 x2        
InstMem[ 25] <= 32'h0041882A; // slt x17 x2 x1        
InstMem[ 26] <= 32'h0109902A; // slt x18 x8 x9        
InstMem[ 27] <= 32'h0128982A; // slt x19 x9 x8        
InstMem[ 28] <= 32'h0252A027; // nor x20 x18 x18      
InstMem[ 29] <= 32'h0273A827; // nor x21 x19 x19      
InstMem[ 30] <= 32'h20160016; // addi x22 x0 22       
InstMem[ 31] <= 32'h8C160004; // lw x22 x0 4          
InstMem[ 32] <= 32'h22D70000; // addi x23 x22 0       
InstMem[ 33] <= 32'h16F60004; // bne x23 x22 l1       
InstMem[ 34] <= 32'h22F7FFF6; // addi x23 x23 -10     
InstMem[ 35] <= 32'h42F60002; // bltz x23 x22 l1      
InstMem[ 36] <= 32'h22F7FFF6; // addi x23 x23 -10     
InstMem[ 37] <= 32'h0C000028; // jal func             
InstMem[ 38] <= 32'h23190001; // addi x25 x24 1       
InstMem[ 39] <= 32'h0800002A; // j end                
InstMem[ 40] <= 32'h20180018; // addi x24 x0 24       
InstMem[ 41] <= 32'h03E00008; // jr x31               




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