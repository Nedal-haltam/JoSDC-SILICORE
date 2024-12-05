

using System.Net.WebSockets;

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
            NodeProg Pprog = parser.Parse(); // parsed program

            Generator generator = new(Pprog);
            string outputcode = generator.Generate();

            File.WriteAllText("./output.mips", outputcode);




        }
    }
}
