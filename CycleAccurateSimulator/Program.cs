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
            bool manual = false;
            List<string> args = Environment.GetCommandLineArgs().ToList();
            if (!manual)
            {
                HandleCommand(args);
            }


            if (manual)
            {
                mcs = [
"00110100000000100000000000000000",
"00111000000010100000000000000000",
"00100000000101000000000000001010",
"00000000000000000010100000100000",
"00100000000000010000000000000001",
"00100000000101101111111111111111",
"00000000001000000010100000100000",
"10001100101011110000000000000000",
"00000001111000000101000000100101",
"00100000001000101111111111111111",
"00000000010000000011000000100000",
"10001100110100000000000000000000",
"00000000010101101100100000101011",
"00000010000010101101000000101011",
"00000011010110011101100000100100",
"00010011011000000000000000000101",
"00100000010001110000000000000001",
"10101100111100000000000000000000",
"00100000010000101111111111111111",
"00001000000000000000000000001010",
"00100000010001110000000000000001",
"10101100111010100000000000000000",
"00100000001000010000000000000001",
"00000000001101001110000000101010",
"00010111100000001111111111101110",
"00000000000000000000000000000000",
"11111100000000000000000000000000",

            ];
                data_mem_init = [
                    "5",
                            "7",
                            "2",
                            "15",
                            "10",
                            "16",
                            "48",
                            "1",
                            "255",
                            "85",
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
            if (!manual)
            {
                File.WriteAllText(output_filepath, sb.ToString());
            }

        }
    }
}