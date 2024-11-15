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
        static List<string> insts = [];
        static string source_filepath = "";
        static string output_filepath = "";
        static void HandleCommand(List<string> args)
        {
            popF(ref args);
            if (args.Count < 2)
            {
                Console.ForegroundColor = ConsoleColor.Red;
                Console.Error.WriteLine("Missing source or output file paths");
                Console.ResetColor();
                Environment.Exit(1);
            }
            //string source_filepath = "D:\\GitHub Repos\\JoSDC-SSOOO-CPU\\OutputFiles\\ASSEMBLERMIPS_MC.txt";
            //string output_filepath = "D:\\GitHub Repos\\JoSDC-SSOOO-CPU\\OutputFiles\\CAS_CPU_CONTENS.txt";
            source_filepath = popF(ref args);
            output_filepath = popF(ref args);

            insts = File.ReadAllLines(source_filepath).ToList();
            for (int i = 0; i < insts.Count; i++)
            {
                insts[i] = insts[i].Remove(insts[i].IndexOf(','));
            }
        }


        static void Main()
        {
            List<string> args = Environment.GetCommandLineArgs().ToList();
            HandleCommand(args);
            
            SingleCycle cpu = new(insts);
            (int cycles, Exceptions excep) = cpu.Run();


            StringBuilder sb = new StringBuilder();
            sb.Append(get_regs(cpu.regs).ToString());
            sb.Append(get_DM(cpu.DM).ToString());
            //sb.Append($"Exception Type : {excep.ToString()}");
            sb.Append($"Number of cycles consumed : {cycles, 10}");

            File.WriteAllText(output_filepath, sb.ToString());
        }
    }
}