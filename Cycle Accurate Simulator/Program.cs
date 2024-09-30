using ProjectCPUCL;
using static ProjectCPUCL.Macros;

namespace main
{
    internal class Program
    {
        static void Main()
        {
            List<string> insts = [
"00100000000000010000000000001010",
"00100000000000100000000000000001",
"10101100001000010000000000000000",
"00000000001000100000100000100010",
"00010000001000000000000000000010",
"00010000000000001111111111111101",
"00100000000000110000000000000011",
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