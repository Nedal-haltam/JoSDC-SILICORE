using System.Text;


namespace Epsilon
{
    internal class Program
    {
        enum TokenType
        {
            // `(` , `)` , `[` , `]` , `,` , (+, -, <, >, &, |, ^, ~|, <<, >>) , `=` , `;` , `\n` (for line increament) , else invalid token
            OpenParen, CloseParen, OpenSquare, CloseSquare, OpenCurly, CloseCurly, Comma, Plus,
            Minus, LessThan, GreaterThan, And, Or, Xor, Nor, Sll, Srl, Equal, SemiColon, NewLine,
            Reg, Mem, Ident, Hlt, For, Iff, Elif, Else, IntLit
        }
        struct Token
        {
            public TokenType Type;
            public string Value;
            public int Line;
        }
        class Tokenizer
        {
            struct Temp { public bool hasvalue; public char value; }
            private string m_thecode;
            private int m_curr_index = 0;
            public Tokenizer(string thecode)
            {
                m_thecode = thecode;
            }
            // TODO: do a peek that accepts the expected the offset and the token type
            Temp peek(int offset = 0)
            {
                bool still = (m_curr_index + offset < m_thecode.Length);
                Temp t = new()
                {
                    hasvalue = still,
                    value = (still) ? m_thecode[m_curr_index + offset] : ' '
                };
                return t;
            }

            char consume()
            {
                return m_thecode.ElementAt(m_curr_index++);
            }

            bool IsComment()
            {
                return peek().value == '/' && peek(1).hasvalue && peek(1).value == '/';
            }
            public List<Token> Tokinze()
            {
                List<Token> tokens = [];
                StringBuilder buffer = new(); // this buffer is for multiple letter tokens
                int line = 1;
                while (peek().hasvalue)
                {
                    // it may be the follwing
                    // letter, digit , // (comment) , `(` , `)` , `[` , `]` , `,` , (+, -, <, >, &, |, ^, ~|, <<, >>) , `=` , `;` , `\n` (for line increament) , ` ` , else invalid token
                    if (char.IsAsciiLetter(peek().value))
                    {
                        buffer.Append(consume());
                        // if it is a letter we will consume until it is not IsAsciiLetterOrDigit
                        while (peek().hasvalue && char.IsAsciiLetterOrDigit(peek().value))
                        {
                            buffer.Append(consume());
                        }
                        // and then check if it is one of the supported keywords or not and it may be the follwing
                        // reg , mem , identifier (aka. var) , hlt (exit), if , elif , else , for , 
                        string word = buffer.ToString();
                        if (word == "reg")
                        {
                            tokens.Add(new() { Value = word, Type = TokenType.Reg, Line = line });
                        }
                        else if (word == "mem")
                        {
                            tokens.Add(new() { Value = word, Type = TokenType.Mem, Line = line });
                        }
                        else if (word == "if")
                        {
                            tokens.Add(new() { Value = word, Type = TokenType.Iff, Line = line });
                        }
                        else if (word == "elif")
                        {
                            tokens.Add(new() { Value = word, Type = TokenType.Elif, Line = line });
                        }
                        else if (word == "else")
                        {
                            tokens.Add(new() { Value = word, Type = TokenType.Else, Line = line });
                        }
                        else if (word == "for")
                        {
                            tokens.Add(new() { Value = word, Type = TokenType.For, Line = line });
                        }
                        else if (word == "hlt")
                        {
                            tokens.Add(new() { Value = word, Type = TokenType.Hlt, Line = line });
                        }
                        else // else it is a variables (identifier)
                        {
                            tokens.Add(new() { Value = word, Type = TokenType.Ident, Line = line });
                        }
                        buffer.Clear();
                    }
                    else if (char.IsDigit(peek().value))
                    {
                        buffer.Append(consume());
                        while (peek().hasvalue && char.IsDigit(peek().value))
                        {
                            buffer.Append(consume());
                        }
                        tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.IntLit, Line = line });
                        buffer.Clear();
                    }
                    else if (IsComment())
                    {
                        consume();
                        consume();
                        while (peek().hasvalue && peek().value != '\n')
                        {
                            consume();
                        }
                    }
                    else if (peek().value == '/' && peek(1).hasvalue && peek(1).value == '*')
                    {
                        consume();
                        consume();
                        while (peek().hasvalue)
                        {
                            if (peek().value == '*' && peek(1).hasvalue && peek(1).value == '/')
                            {
                                break;
                            }
                            consume();
                        }
                        if (peek().hasvalue)
                        {
                            consume();
                        }
                        if (peek().hasvalue)
                        {
                            consume();
                        }
                    }
                    else if (peek().value == '(')
                    {
                        buffer.Append(consume());
                        tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.OpenParen, Line = line });
                    }
                    else if (peek().value == ')')
                    {
                        buffer.Append(consume());
                        tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.CloseParen, Line = line });
                    }
                    else if (peek().value == '[')
                    {
                        buffer.Append(consume());
                        tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.OpenSquare, Line = line });
                    }
                    else if (peek().value == ']')
                    {
                        buffer.Append(consume());
                        tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.CloseSquare, Line = line });
                    }
                    else if (peek().value == ',')
                    {
                        buffer.Append(consume());
                        tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.Comma, Line = line });
                    }
                    // operators
                    else if (peek().value == '+')
                    {
                        buffer.Append(consume());
                        tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.Plus, Line = line });
                    }
                    else if (peek().value == '-')
                    {
                        buffer.Append(consume());
                        tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.Minus, Line = line });
                    }
                    else if (peek().value == '<')
                    {
                        buffer.Append(consume());
                        tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.LessThan, Line = line });
                    }
                    else if (peek().value == '>')
                    {
                        buffer.Append(consume());
                        tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.GreaterThan, Line = line });
                    }
                    else if (peek().value == '&')
                    {
                        buffer.Append(consume());
                        tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.And, Line = line });
                    }
                    else if (peek().value == '|')
                    {
                        buffer.Append(consume());
                        tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.Or, Line = line });
                    }
                    else if (peek().value == '^')
                    {
                        buffer.Append(consume());
                        tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.Xor, Line = line });
                    }
                    else if ((peek().value == '<' && peek(1).hasvalue && peek(1).value == '<'))
                    {
                        buffer.Append(consume());
                        buffer.Append(consume());
                        tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.Sll, Line = line });
                    }
                    else if ((peek().value == '>' && peek(1).hasvalue && peek(1).value == '>'))
                    {
                        buffer.Append(consume());
                        buffer.Append(consume());
                        tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.Srl, Line = line });
                    }
                    else if ((peek().value == '~' && peek(1).hasvalue && peek(1).value == '|'))
                    {
                        buffer.Append(consume());
                        buffer.Append(consume());
                        tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.Nor, Line = line });
                    }
                    // end operators
                    else if (peek().value == '=')
                    {
                        buffer.Append(consume());
                        tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.Equal, Line = line });
                    }
                    else if (peek().value == ';')
                    {
                        buffer.Append(consume());
                        tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.SemiColon, Line = line });
                    }
                    else if (peek().value == '\n')
                    {
                        consume();
                        line++;
                    }
                    else if (char.IsWhiteSpace(peek().value))
                    {
                        consume();
                    }
                    else
                    {
                        Console.ForegroundColor = ConsoleColor.Red;
                        Console.Error.WriteLine($"Invalid token: {peek().value}");
                        Environment.Exit(1);
                        Console.ResetColor();
                    }
                    buffer.Clear();
                }
                m_curr_index = 0;
                return tokens;
            }

        }

        class Parser
        {
            public void Parse()
            {

            }
        }
        class Generator
        {
            public void Generate()
            {

            }
        }

        static void Main()
        {
            string thecode = " / reg\t\nnedal = 123; /* \n\nsdfdsfd\n\\t \t// \t sldkfjds \n  */ // comment \n mem hallah = 34;";
            Tokenizer t = new(thecode);
            List<Token> tokenized = t.Tokinze();



            Console.WriteLine("before:");
            Console.WriteLine(thecode);
            Console.WriteLine("end");

            Console.WriteLine("Tokinzed:");
            tokenized.ForEach(x => Console.WriteLine(x.Value));
            Console.WriteLine("endTokenized");

            Parser parser = new();
            parser.Parse();

            Generator generator = new();
            generator.Generate();
        }
    }
}
