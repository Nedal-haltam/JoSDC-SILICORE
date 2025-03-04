

using System.Collections.Generic;
using System.Data;
using System.Net.NetworkInformation;
using System.Security.Cryptography;
using System.Text;
using System.Text.RegularExpressions;
using static System.Formats.Asn1.AsnWriter;




namespace Epsilon
{
    internal class Program
    {
        static void Main()
        {
            string inputcode = File.ReadAllText("./input.e");

            Tokenizer tokenizer = new(inputcode);
            List<Token> TokenizedProgram = tokenizer.Tokenize(); // tokenized program

            Parser parser = new(TokenizedProgram);
            NodeProg ParsedProgram  = parser.ParseProg(); // parsed program

            // TODO: make this as a MIPSCodeGenerator and make a new Generator for x86
            // make such that the codegenerator calls on the generators MIPS, x86, ... using enums for example
            Generator generator = new(ParsedProgram);
            StringBuilder GeneratedProgram = generator.GenProg();

            File.WriteAllText("./output.mips", GeneratedProgram.ToString());
        }
    }
}
