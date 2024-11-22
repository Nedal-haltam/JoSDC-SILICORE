using System.Text;






namespace Epsilon
{
    struct Token
    {
        public TokenType Type;
        public string Value;
        public int Line;
    }
    enum TokenType
    {
        // `(` , `)` , `[` , `]` , `,` , (+, -, <, >, &, |, ^, ~|, <<, >>) , `=` , `;` , `\n` (for line increament) , else invalid token
        OpenParen, CloseParen, OpenSquare, CloseSquare, OpenCurly, CloseCurly, Comma, Plus,
        Minus, And, Or, Xor, Nor, Sll, Srl, Equal, SemiColon, NewLine,
        Reg, Mem, Ident, Hlt, For, Iff, Elif, Else, IntLit
    }
    struct Temp<T> { public bool hasvalue; public T value; }
    internal class Program
    {
        static void Main()
        {
            string thecode = " / reg\t\nnedal = 123; /* \n\nsdfdsfd\n\\t \t// \t sldkfjds \n  */ // comment \n mem hallah = 34;";
            Tokenizer t = new(thecode);
            List<Token> tokenized = t.Tokinze();


            Console.WriteLine("Tokinzed:");
            tokenized.ForEach(x => Console.WriteLine($"Token: {x.Value} , Token Type: {x.Type}"));

            Parser parser = new(tokenized);
            parser.Parse();

            Generator generator = new();
            generator.Generate();
        }
    }
}
