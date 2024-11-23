

namespace Epsilon
{
    internal class Program
    {
        static void Main()
        {
            //string thecode = " / reg\t\nnedal = 123; /* \n\nsdfdsfd\n\\t \t// \t sldkfjds \n  */ // comment \n mem hallah = 34;";
            //Console.WriteLine("Tokinzed:");
            //tokenized.ForEach(x => Console.WriteLine($"Token: {x.Value} , Token Type: {x.Type}"));

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
