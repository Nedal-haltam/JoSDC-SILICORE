
using System.Collections.Concurrent;
using System.Text;


namespace Epsilon
{
    internal class Program
    {
        struct TokenType
        {
            // letter, digit , // (comment) , `(` , `)` , `[` , `]` , `,` , (+, -, <, >, &, |, ^, ~|, <<, >>) , `=` , `;` , `\n` (for line increament) , ` ` , else invalid token
        }

        struct Token
        {
            public TokenType Type;
            public string Value;
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

            Temp peek(int offset = 0)
            {
                bool still = (m_curr_index + offset < m_thecode.Length);
                Temp t = new Temp()
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
                return peek().value == '/' && peek(1).value == '/';
            }
            public List<Token> Tokinze()
            {
                List<Token> tokens = [];
                StringBuilder buffer = new();
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
                    }
                    else if (char.IsDigit(peek().value))
                    {
                        buffer.Append(consume());
                        while (peek().hasvalue && char.IsDigit(peek().value))
                        {
                            buffer.Append(consume());
                        }
                        //tokens.push_back({ TokenType::int_lit, line_count, buf });
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
                    else if (peek().value == '(')
                    {

                    }
                    else if (peek().value == ')')
                    {

                    }
                    else if (peek().value == '[')
                    {

                    }
                    else if (peek().value == ']')
                    {

                    }
                    else if (peek().value == ',')
                    {

                    }
                    // operators
                    else if (peek().value == '+')
                    {

                    }
                    else if (peek().value == '-')
                    {

                    }
                    else if ((peek().value == '<' && peek(1).value == '<'))
                    {

                    }
                    else if ((peek().value == '>' && peek(1).value == '>'))
                    {

                    }
                    else if (peek().value == '<')
                    {

                    }
                    else if (peek().value == '>')
                    {

                    }
                    else if (peek().value == '&')
                    {

                    }
                    else if (peek().value == '|')
                    {

                    }
                    else if (peek().value == '^')
                    {

                    }
                    else if ((peek().value == '~' && peek(1).value == '|'))
                    {

                    }
                    // end operators
                    else if (peek().value == '=')
                    {

                    }
                    else if (peek().value == ';')
                    {

                    }
                    else if (peek().value == '\n')
                    {

                    }
                    else if (char.IsWhiteSpace(peek().value))
                    {

                    }
                    else
                    {
                        Console.Error.WriteLine($"Invalid token: {peek().value}");
                    }
                }

                return tokens;
            }

        }

        static void Main()
        {
            string thecode = 
                "reg nedal = 123;      \n\r\t\t\n\n\r \n\r  sd fhallah    wallah";
            Tokenizer t = new(thecode);
            List<Token> tokenized = t.Tokinze();
            Console.WriteLine("before:");
            Console.WriteLine(thecode);
            Console.WriteLine("end");

            Console.WriteLine("after:");
            tokenized.ForEach(x => Console.WriteLine(x.Value));
            Console.WriteLine("end");
        }
    }
}
