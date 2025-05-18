

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

            // TODO: make a new Generator for x86 or 
            // you can edd it when you generate as an extra if condition that chacks the deisred target 
            // to see the symmetry in the generation of the assembly instructions
            MIPSGenerator generator = new(ParsedProgram);
            StringBuilder GeneratedProgram = generator.GenProg();

            File.WriteAllText("./output.mips", GeneratedProgram.ToString());
        }
    }
}
