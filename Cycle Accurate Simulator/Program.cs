using ProjectCPUCL;
using static ProjectCPUCL.Macros;

namespace main
{
    internal class Program
    {
        static void Main()
        {

            List<string> insts = [
"00100000000000010000000001111011", // addi x1 x0 123

                ];
            CPU5STAGE cpu = new(insts);
            int cycles = cpu.Run();
            cout($"Number of cycles consumed is : {cycles}");
            cpu.print_regs();
            cpu.print_DM();
        }
    }
}