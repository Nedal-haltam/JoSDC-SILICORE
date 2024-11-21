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
            List<string> args = Environment.GetCommandLineArgs().ToList();
            HandleCommand(args);
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
            File.WriteAllText(output_filepath, sb.ToString());
        }
    }
}