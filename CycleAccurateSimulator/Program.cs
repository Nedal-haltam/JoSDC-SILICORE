using System.Text;
using static LibCPU.MIPS;
using LibAN;

namespace main {
    internal class Program {
        static void assert(string msg) {
            Console.ForegroundColor = ConsoleColor.Red;
            Console.Error.WriteLine(msg);
            Console.ResetColor();
            Environment.Exit(1);
        }
        static T popF<T>(ref List<T> vals) {
            if (vals.Count == 0)
                assert("Missing arguments");
            T val = vals.First();
            vals.RemoveAt(0);
            return val;
        }

        static string mc_filepath = "";
        static List<string> mcs = [];
        static string dm_filepath = "";
        static string dataset_filepath = "";
        static List<string> BranchPredictorDataSet = [];
        static List<string> data_mem_init = [];
        static string output_filepath = "";
        static LibCPU.CPU_type cpu_type = LibCPU.CPU_type.OOO;
        static void HandleCommand(List<string> args) {
            popF(ref args); // path of the executable

            string arg = popF(ref args).ToLower(); // sim
            if (arg == "sim") {
                string cputype = popF(ref args).ToLower();
                if (cputype == "singlecycle")   { cpu_type = LibCPU.CPU_type.SingleCycle; }
                else if (cputype == "pipeline") { cpu_type = LibCPU.CPU_type.PipeLined; }
                else if (cputype == "ooo")      { cpu_type = LibCPU.CPU_type.OOO; }
                else
                { assert($"invalid cpu type {cputype}"); }
                if (cpu_type == LibCPU.CPU_type.PipeLined)
                {
                    dataset_filepath = popF(ref args);
                }
                mc_filepath = popF(ref args);
                dm_filepath = popF(ref args);
                output_filepath = popF(ref args);
                
                mcs = File.ReadAllLines(mc_filepath).ToList();
                data_mem_init = File.ReadAllLines(dm_filepath).ToList();
            }
            else { assert($"Invalid argument {arg}"); }
        }


        static void Main() {
            List<string> args = Environment.GetCommandLineArgs().ToList();
            bool command = args.Count > 1;

            if (command) HandleCommand(args);
            
            if (!command) {
                mcs = 
                [
"00100000000000010000000000001010",
"00000000000000010101100010000000",
"00100001011010110000000000000001",
"00100000000000100000000000000000",
"00000000000000010001100000100000",
"00000000010010110100000000100010",
"00000001000000000000100000101010",
"00010000001000000000000000000110",
"10101100010000110000000000000000",
"10101100010000110000000000000001",
"00100000010000100000000000000010",
"00100000011000111111111111111111",
"00010000000000001111111111111001",
"00100000000000110000000000000000",
"00010000011010110000000000010000",
"00100000000001000000000000000000",
"00000000000010110011100000100000",
"00000000111000110011100000100010",
"00010000100001110000000000001010",
"10001100100001010000000000000000",
"10001100100001100000000000000001",
"00000000101001100100000000100010",
"00000001000000000000100000101010",
"00010100001000000000000000000011",
"10101100100001010000000000000001",
"10101100100001100000000000000000",
"00100000100001000000000000000001",
"00010000000000001111111111110111",
"00100000011000110000000000000001",
"00010000000000001111111111110001",
"11111100000000000000000000000000",
                    ];
            }
            Dictionary<int, bool> LUT = [];

            if (!command) 
            {
                //LUT = LibAN.LibAN.ReadMLPrediction(filepath); 
            }
            if (!command) cpu_type = LibCPU.CPU_type.PipeLined;

            StringBuilder sb = new StringBuilder();
            if (cpu_type == LibCPU.CPU_type.SingleCycle) {
                LibCPU.SingleCycle cpu = new(mcs, data_mem_init);
                (int cycles, LibCPU.MIPS.Exceptions excep) = cpu.Run();
                sb.Append(LibCPU.MIPS.get_regs(cpu.regs));
                sb.Append(LibCPU.MIPS.get_DM(cpu.DM));
                //sb.Append($"Exception Type : {excep.ToString()}");
                sb.Append($"Number of cycles consumed : {cycles,10}\n");
            }
            else if (cpu_type == LibCPU.CPU_type.PipeLined) {
                LibCPU.CPU6STAGE cpu = new(mcs, data_mem_init);
                if (!command) cpu.BranchLUT = LUT;
                (int cycles, LibCPU.MIPS.Exceptions excep) = cpu.Run();
                sb.Append(LibCPU.MIPS.get_regs(cpu.regs));
                sb.Append(LibCPU.MIPS.get_DM(cpu.DM));
                //sb.Append($"Exception Type : {excep.ToString()}");
                sb.Append($"Number of cycles consumed : {cycles,10}\n");
                BranchPredictorDataSet.Add("program counter, branch history, branch outcome\n");
                BranchPredictorDataSet.AddRange(cpu.GetDataSet());
            }
            else if (cpu_type == LibCPU.CPU_type.OOO) {
                LibCPU.OOO cpu = new(mcs, data_mem_init);
                cpu.BranchLUT = LUT;
                (int cycles, LibCPU.MIPS.Exceptions excep) = cpu.Run();
                sb.Append(LibCPU.MIPS.get_regs(cpu.regs));
                sb.Append(LibCPU.MIPS.get_DM(cpu.DM));
                //sb.Append($"Exception Type : {excep.ToString()}");
                sb.Append($"Number of cycles consumed : {cycles,10}\n");
            }

            if (!command) Console.WriteLine( sb.ToString() );

            if (command)
            {
                File.WriteAllText(output_filepath, sb.ToString());
                if (cpu_type == LibCPU.CPU_type.PipeLined )
                {
                    File.WriteAllLines(dataset_filepath, BranchPredictorDataSet);
                }
            }
        }
    }
}
