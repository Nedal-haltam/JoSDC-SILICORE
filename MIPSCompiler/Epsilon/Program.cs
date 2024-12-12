

using System.Net.WebSockets;
using System.Text;

namespace Epsilon
{
    internal class Program
    {
        static void Main()
        {
            string inputcode = File.ReadAllText("./input.e");

            Tokenizer tokenizer = new(inputcode);
            List<Token> Tprog = tokenizer.Tokinze(); // tokenized program

            Parser parser = new(Tprog);
            NodeProg Pprog = parser.ParseProg(); // parsed program

            Generator generator = new(Pprog);
            StringBuilder outputcode = generator.GenProg();

            File.WriteAllText("./output.mips", outputcode.ToString());
        }
    }
}
