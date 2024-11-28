using ProjectCPUCL;
using System.Text;
using static ProjectCPUCL.MIPS;

namespace main
{
    internal class Program
    {
        static T popF<T>(ref List<T> vals)
        {
            T val = vals.First();
            vals.RemoveAt(0);
            return val;
        }
        static void assert(string msg)
        {
            Console.ForegroundColor = ConsoleColor.Red;
            Console.Error.WriteLine(msg);
            Console.ResetColor();
            Environment.Exit(1);
        }

        static string mc_filepath = "";
        static List<string> mcs = [];
        static string dm_filepath = "";
        static List<string> data_mem_init = [];
        static string output_filepath = "";
        static CPU_type cpu_type = CPU_type.SingleCycle;
        static void HandleCommand(List<string> args)
        {
            popF(ref args);
            if (args.Count != 5)
            {
                assert("Missing arguments");
            }

            string arg = popF(ref args).ToLower();
            if (arg == "sim")
            {
                string cputype = popF(ref args).ToLower();
                mc_filepath = popF(ref args);
                dm_filepath = popF(ref args);
                output_filepath = popF(ref args);
                
                mcs = File.ReadAllLines(mc_filepath).ToList();
                data_mem_init = File.ReadAllLines(dm_filepath).ToList();
                if (cputype == "singlecycle")
                {
                    cpu_type = CPU_type.SingleCycle;
                }
                else if (cputype == "pipeline")
                {
                    cpu_type = CPU_type.PipeLined;
                }
                else
                {
                    assert($"invalid cpu type {cputype}");
                }

            }
            else
            {
                assert($"Invalid argument {arg}");
            }
        }


        static void Main()
        {
            bool command = true;

            List<string> args = Environment.GetCommandLineArgs().ToList();
            if (command)
                HandleCommand(args);


            if (!command)
            {
                mcs = [

"00100000000000011111111111111011", // addi $1 $0 -5
"00100000000000100000000000000101", // addi $2 $0 5
"00100000000000110000000000000101", // addi $3 $0 5
"00100000000001000000000000010101", // addi $4 $0 21
"00010000010000110000000000000011", // beq $2 $3 l2
"00000000000000000000000000000000", // nop
"00001100000000000000000000000100", // jal l1
"00010100010000110000000000000001", // bne $2 $3 l3
"00000000000000000000000000000000", // nop
"00000000001000001111100000101010", // slt x31 $1 x0
"00010111111000000000000000000011", // bne x31 x0 l5
"00000000000000000000000000000000", // nop
"00001100000000000000000000001001", // jal l4
"00000000010000001111100000101010", // slt x31 $2 x0
"00010011111000000000000000000011", // beq x31 x0 l6
"00000000000000000000000000000000", // nop
"00001100000000000000000000001101", // jal l5
"00001100000000000000000000010100", // jal l7
"00000000000000000000000000000000", // nop
"00001100000000000000000000010001", // jal l6
"00000000100000000000000000001000", // jr $4
"00000000000000000000000000000000", // nop
"00001100000000000000000000010100", // jal l7
"00000000000000000000000000000000", // nop
"11111100000000000000000000000000", // hlt

                ];
            }
            
            StringBuilder sb = new StringBuilder();
            if (cpu_type == CPU_type.SingleCycle)
            {
                SingleCycle cpu = new(mcs, data_mem_init);
                (int cycles, Exceptions excep) = cpu.Run();
                sb.Append(get_regs(cpu.regs).ToString());
                sb.Append(get_DM(cpu.DM).ToString());
                //sb.Append($"Exception Type : {excep.ToString()}");
                sb.Append($"Number of cycles consumed : {cycles,10}\n");
            }
            else if (cpu_type == CPU_type.PipeLined)
            {
                CPU5STAGE cpu = new(mcs, data_mem_init);
                (int cycles, Exceptions excep) = cpu.Run();
                sb.Append(get_regs(cpu.regs).ToString());
                sb.Append(get_DM(cpu.DM).ToString());
                //sb.Append($"Exception Type : {excep.ToString()}");
                sb.Append($"Number of cycles consumed : {cycles,10}\n");
            }
            if (!command)
                Console.WriteLine( sb.ToString() );

            if (command)
                File.WriteAllText(output_filepath, sb.ToString());
        }
    }
}