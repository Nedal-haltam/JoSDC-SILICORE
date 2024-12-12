using System.Text;
#pragma warning disable CS8629 // Nullable value type may be null.



namespace Epsilon
{
    public struct Token
    {
        public TokenType Type;
        public string Value;
        public int Line;
    }
    public enum TokenType
    {
        // `(` , `)` , `[` , `]` , `,` , (+, -, <, >, &, |, ^, ~|, <<, >>) , `=` , `;` , `\n` (for line increament) , else invalid token
        OpenParen, CloseParen, OpenSquare, CloseSquare, OpenCurly, CloseCurly, Comma, Plus,
        Minus, And, Or, Xor, Nor, Sll, Srl, EqualEqual, NotEqual, Equal, SemiColon, NewLine,
        Int, Ident, For, Iff, Elif, Else, IntLit, Exit, fslash, star
    }
    class Tokenizer(string thecode)
    {
        private readonly string m_thecode = thecode;
        private int m_curr_index = 0;

        char? Peek(int offset = 0)
        {
            if (m_curr_index + offset < m_thecode.Length)
            {
                return m_thecode[m_curr_index + offset];
            }
            return null;
        }
        char? Peek(char type, int offset = 0)
        {
            char? token = Peek(offset);
            if (token.HasValue && token.Value == type)
            {
                return token;
            }
            return null;
        }
        char Consume()
        {
            return m_thecode.ElementAt(m_curr_index++);
        }

        bool IsComment()
        {
            return Peek('/').HasValue && Peek('/', 1).HasValue;
        }
        public List<Token> Tokinze()
        {
            List<Token> tokens = [];
            StringBuilder buffer = new(); // this buffer is for multiple letter tokens
            int line = 1;
            while (Peek().HasValue)
            {
                char curr_token = Peek().Value;
                // it may be the follwing
                if (char.IsAsciiLetter(curr_token) || curr_token == '_')
                {
                    buffer.Append(Consume());
                    // if it is a letter we will consume until it is not IsAsciiLetterOrDigit
                    while (Peek().HasValue && (char.IsAsciiLetterOrDigit(Peek().Value) || Peek('_').HasValue))
                    {
                        buffer.Append(Consume());
                    }
                    // and then check if it is one of the supported keywords or not and it may be the follwing
                    // reg , mem , identifier (aka. var) , hlt (exit), if , elif , else , for , 
                    string word = buffer.ToString();
                    if (word == "int")
                    {
                        tokens.Add(new() { Value = word, Type = TokenType.Int, Line = line });
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
                    //else if (word == "for")
                    //{
                    //    tokens.Add(new() { Value = word, Type = TokenType.For, Line = line });
                    //}
                    else if (word == "exit")
                    {
                        tokens.Add(new() { Value = word, Type = TokenType.Exit, Line = line });
                    }
                    else // else it is a variable (identifier)
                    {
                        tokens.Add(new() { Value = word, Type = TokenType.Ident, Line = line });
                    }
                    buffer.Clear();
                }
                else if (char.IsDigit(curr_token))
                {
                    buffer.Append(Consume());
                    while (Peek().HasValue && char.IsDigit(Peek().Value))
                    {
                        buffer.Append(Consume());
                    }
                    tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.IntLit, Line = line });
                    buffer.Clear();
                }
                else if (IsComment())
                {
                    Consume();
                    Consume();
                    while (!Peek('\n').HasValue)
                    {
                        Consume();
                    }
                }
                else if (Peek('/').HasValue && Peek('*', 1).HasValue)
                {
                    Consume();
                    Consume();
                    while (Peek().HasValue)
                    {
                        if (Peek('*').HasValue && Peek('/', 1).HasValue)
                        {
                            break;
                        }
                        if (Peek('\n').HasValue)
                        {
                            line++;
                        }
                        Consume();
                    }
                    if (Peek().HasValue)
                    {
                        Consume();
                    }
                    if (Peek().HasValue)
                    {
                        Consume();
                    }
                }
                else if (curr_token == '(')
                {
                    buffer.Append(Consume());
                    tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.OpenParen, Line = line });
                }
                else if (curr_token == ')')
                {
                    buffer.Append(Consume());
                    tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.CloseParen, Line = line });
                }
                else if (curr_token == '[')
                {
                    buffer.Append(Consume());
                    tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.OpenSquare, Line = line });
                }
                else if (curr_token == ']')
                {
                    buffer.Append(Consume());
                    tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.CloseSquare, Line = line });
                }
                else if (curr_token == '{')
                {
                    buffer.Append(Consume());
                    tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.OpenCurly, Line = line });
                }
                else if (curr_token == '}')
                {
                    buffer.Append(Consume());
                    tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.CloseCurly, Line = line });
                }
                else if (curr_token == ',')
                {
                    buffer.Append(Consume());
                    tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.Comma, Line = line });
                }
                // operators
                else if (curr_token == '+')
                {
                    buffer.Append(Consume());
                    tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.Plus, Line = line });
                }
                else if (curr_token == '-')
                {
                    buffer.Append(Consume());
                    tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.Minus, Line = line });
                }
                else if (curr_token == '*')
                {
                    buffer.Append(Consume());
                    tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.star, Line = line });
                }
                else if (curr_token == '/')
                {
                    buffer.Append(Consume());
                    tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.fslash, Line = line });
                }
                else if (curr_token == '&')
                {
                    buffer.Append(Consume());
                    tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.And, Line = line });
                }
                else if (curr_token == '|')
                {
                    buffer.Append(Consume());
                    tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.Or, Line = line });
                }
                else if (curr_token == '^')
                {
                    buffer.Append(Consume());
                    tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.Xor, Line = line });
                }
                else if ((Peek('<').HasValue && Peek('<', 1).HasValue))
                {
                    buffer.Append(Consume());
                    buffer.Append(Consume());
                    tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.Sll, Line = line });
                }
                else if ((Peek('>').HasValue && Peek('>', 1).HasValue))
                {
                    buffer.Append(Consume());
                    buffer.Append(Consume());
                    tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.Srl, Line = line });
                }
                else if ((Peek('~').HasValue && Peek('|', 1).HasValue))
                {
                    buffer.Append(Consume());
                    buffer.Append(Consume());
                    tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.Nor, Line = line });
                }
                else if (Peek('=').HasValue && Peek('=', 1).HasValue)
                {
                    buffer.Append(Consume());
                    buffer.Append(Consume());
                    tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.EqualEqual, Line = line });
                }
                else if (Peek('!').HasValue && Peek('=', 1).HasValue)
                {
                    buffer.Append(Consume());
                    buffer.Append(Consume());
                    tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.NotEqual, Line = line });
                }
                // end operators
                else if (curr_token == '=')
                {
                    buffer.Append(Consume());
                    tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.Equal, Line = line });
                }

                else if (curr_token == ';')
                {
                    buffer.Append(Consume());
                    tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.SemiColon, Line = line });
                }
                else if (curr_token == '\n')
                {
                    Consume();
                    line++;
                }
                else if (char.IsWhiteSpace(curr_token))
                {
                    Consume();
                }
                else
                {
                    Console.ForegroundColor = ConsoleColor.Red;

                    Console.Error.WriteLine($"Invalid token: {curr_token}");
                    Environment.Exit(1);
                    Console.ResetColor();
                }
                buffer.Clear();
            }
            m_curr_index = 0;
            return tokens;
        }

    }
}


#pragma warning restore CS8629 // Nullable value type may be null.