using ProjectCPUCL;
using static ProjectCPUCL.Macros;

namespace main
{
    internal class Program
    {
        static void Main()
        {

            List<string> insts = [
Convert.ToString(0x20010064, 2).PadLeft(32, '0'), // addi x1 x0 100       
Convert.ToString(0xAC010001, 2).PadLeft(32, '0'), // sw x1 x0 1           
Convert.ToString(0x2020007B, 2).PadLeft(32, '0'), // addi x0 x1 123       
Convert.ToString(0x2002FFFE, 2).PadLeft(32, '0'), // addi x2 x0 -2        
Convert.ToString(0xAC420002, 2).PadLeft(32, '0'), // sw x2 x2 2           
Convert.ToString(0x00221820, 2).PadLeft(32, '0'), // add x3 x1 x2         
Convert.ToString(0xAC63FFA0, 2).PadLeft(32, '0'), // sw x3 x3 -96         
Convert.ToString(0x00220020, 2).PadLeft(32, '0'), // add x0 x1 x2         
Convert.ToString(0x00622022, 2).PadLeft(32, '0'), // sub x4 x3 x2         
Convert.ToString(0x00822022, 2).PadLeft(32, '0'), // sub x4 x4 x2         
Convert.ToString(0xAC040003, 2).PadLeft(32, '0'), // sw x4 x0 3           
Convert.ToString(0x00622823, 2).PadLeft(32, '0'), // subu x5 x3 x2        
Convert.ToString(0x00223021, 2).PadLeft(32, '0'), // addu x6 x1 x2        
Convert.ToString(0x00C23022, 2).PadLeft(32, '0'), // sub x6 x6 x2         
Convert.ToString(0x3407B676, 2).PadLeft(32, '0'), // ori x7 x0 -18826     
Convert.ToString(0xAC070004, 2).PadLeft(32, '0'), // sw x7 x0 4           
Convert.ToString(0x00E34024, 2).PadLeft(32, '0'), // and x8 x7 x3         
Convert.ToString(0x31090020, 2).PadLeft(32, '0'), // andi x9 x8 32        
Convert.ToString(0x01095026, 2).PadLeft(32, '0'), // xor x10 x8 x9        
Convert.ToString(0x394BFFFF, 2).PadLeft(32, '0'), // xori x11 x10 -1      
Convert.ToString(0x356C0042, 2).PadLeft(32, '0'), // ori x12 x11 66       
Convert.ToString(0x396D0042, 2).PadLeft(32, '0'), // xori x13 x11 66      
Convert.ToString(0x000A7040, 2).PadLeft(32, '0'), // sll x14 x10 1        
Convert.ToString(0x000E7882, 2).PadLeft(32, '0'), // srl x15 x14 2        
Convert.ToString(0x0022802A, 2).PadLeft(32, '0'), // slt x16 x1 x2        
Convert.ToString(0x0041882A, 2).PadLeft(32, '0'), // slt x17 x2 x1        
Convert.ToString(0x0109902A, 2).PadLeft(32, '0'), // slt x18 x8 x9        
Convert.ToString(0x0128982A, 2).PadLeft(32, '0'), // slt x19 x9 x8        
Convert.ToString(0x0252A027, 2).PadLeft(32, '0'), // nor x20 x18 x18      
Convert.ToString(0x0273A827, 2).PadLeft(32, '0'), // nor x21 x19 x19      
Convert.ToString(0x20160016, 2).PadLeft(32, '0'), // addi x22 x0 22       
Convert.ToString(0x8C160004, 2).PadLeft(32, '0'), // lw x22 x0 4          
Convert.ToString(0x22D70000, 2).PadLeft(32, '0'), // addi x23 x22 0       
Convert.ToString(0x16F60002, 2).PadLeft(32, '0'), // bne x23 x22 l1       
Convert.ToString(0x22F7FFF6, 2).PadLeft(32, '0'), // addi x23 x23 -10     
Convert.ToString(0x0C000026, 2).PadLeft(32, '0'), // jal func             
Convert.ToString(0x23190001, 2).PadLeft(32, '0'), // addi x25 x24 1       
Convert.ToString(0x08000028, 2).PadLeft(32, '0'), // j end                
Convert.ToString(0x20180018, 2).PadLeft(32, '0'), // addi x24 x0 24       
Convert.ToString(0x03E00008, 2).PadLeft(32, '0'), // jr x31               
Convert.ToString(0xFC000000, 2).PadLeft(32, '0'), // hlt                  
                ];
            CPU5STAGE cpu = new(insts);
            int cycles = cpu.Run();
            cout($"Number of cycles consumed is : {cycles}");
            cpu.print_regs();
            cpu.print_DM();
        }
    }
}
/*
addi x1, x0, 10
addi x2, x0, 1
l:
sw x1, x1, 0
sub x1, x1, x2
beq x1, x0, exit
beq x0, x0, l

exit:
addi x3, x0, 3
*/