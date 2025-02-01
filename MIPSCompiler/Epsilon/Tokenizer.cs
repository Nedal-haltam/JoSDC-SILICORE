using System.Linq.Expressions;
using System.Net.NetworkInformation;
using System.Runtime.InteropServices;
using System.Text;
using System.Text.RegularExpressions;
using System.Xml.Schema;
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
        Int, Ident, For, Iff, Elif, Else, IntLit, Exit, fslash, star, LessThan, GreaterThan, breakk, continuee
    }
    class Tokenizer(string thecode)
    {
        private string m_thecode = thecode;
        private int m_curr_index = 0;
        private List<Token> m_tokens = [];
        void Error(char curr_token)
        {
            Console.ForegroundColor = ConsoleColor.Red;
            Console.Error.WriteLine($"Invalid token: {curr_token}");
            Environment.Exit(1);
            Console.ResetColor();
        }
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
        bool IsMacro()
        {
            if (Peek('#', 0).HasValue && Peek('d', 1).HasValue && Peek('e', 2).HasValue && Peek('f', 3).HasValue && Peek('i', 4).HasValue && Peek('n', 5).HasValue && Peek('e', 6).HasValue)
            {
                Consume();
                Consume();
                Consume();
                Consume();
                Consume();
                Consume();
                Consume();
                return true;
            }
            return false;
        }
        private Dictionary<string, List<Token>> macro = [];
        public List<Token> Tokenize()
        {
            m_tokens = [];
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
                    if (macro.ContainsKey(word))
                    {
                        List<Token> tokens = macro[word];
                        m_tokens.AddRange(tokens);
                    }
                    else if (word == "int")
                    {
                        m_tokens.Add(new() { Value = word, Type = TokenType.Int, Line = line });
                    }
                    else if (word == "if")
                    {
                        m_tokens.Add(new() { Value = word, Type = TokenType.Iff, Line = line });
                    }
                    else if (word == "elif")
                    {
                        m_tokens.Add(new() { Value = word, Type = TokenType.Elif, Line = line });
                    }
                    else if (word == "else")
                    {
                        m_tokens.Add(new() { Value = word, Type = TokenType.Else, Line = line });
                    }
                    else if (word == "for")
                    {
                        m_tokens.Add(new() { Value = word, Type = TokenType.For, Line = line });
                    }
                    else if (word == "break")
                    {
                        m_tokens.Add(new() { Value = word, Type = TokenType.breakk, Line = line });
                    }
                    else if (word == "continue")
                    {
                        m_tokens.Add(new() { Value = word, Type = TokenType.continuee, Line = line });
                    }
                    else if (word == "exit")
                    {
                        m_tokens.Add(new() { Value = word, Type = TokenType.Exit, Line = line });
                    }
                    else // else it is a variable (identifier)
                    {
                        m_tokens.Add(new() { Value = word, Type = TokenType.Ident, Line = line });
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
                    m_tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.IntLit, Line = line });
                    buffer.Clear();
                }
                else if (IsComment())
                {
                    Consume();
                    Consume();
                    while (Peek().HasValue && !Peek('\n').HasValue)
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
                    m_tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.OpenParen, Line = line });
                }
                else if (curr_token == ')')
                {
                    buffer.Append(Consume());
                    m_tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.CloseParen, Line = line });
                }
                else if (curr_token == '[')
                {
                    buffer.Append(Consume());
                    m_tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.OpenSquare, Line = line });
                }
                else if (curr_token == ']')
                {
                    buffer.Append(Consume());
                    m_tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.CloseSquare, Line = line });
                }
                else if (curr_token == '{')
                {
                    buffer.Append(Consume());
                    m_tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.OpenCurly, Line = line });
                }
                else if (curr_token == '}')
                {
                    buffer.Append(Consume());
                    m_tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.CloseCurly, Line = line });
                }
                else if (curr_token == ',')
                {
                    buffer.Append(Consume());
                    m_tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.Comma, Line = line });
                }
                else if (curr_token == '#')
                {
                    if (IsMacro())
                    {
                        // aready consumed, now we get the name and the value
                        while (Peek(' ').HasValue) Consume();
                        while (!Peek(' ').HasValue)
                        {
                            buffer.Append(Consume());
                        }
                        Consume();
                        string macroname = buffer.ToString();
                        buffer.Clear();
                        while (!Peek('\n').HasValue)
                        {
                            buffer.Append(Consume());
                        }
                        Consume();
                        Tokenizer temp = new(buffer.ToString());
                        List<Token> macrovalue = temp.Tokenize();
                        for (int i = 0; i < macrovalue.Count; i++)
                        {
                            if (macro.ContainsKey(macrovalue[i].Value))
                            {
                                Token t = macrovalue[i];
                                macrovalue.RemoveAt(i);
                                macrovalue.InsertRange(i, macro[t.Value]);
                            }
                        }
                        macro.Add(macroname, macrovalue);
                    }
                    else
                    {
                        Error(curr_token);
                    }
                }
                // operators
                else if (curr_token == '+')
                {
                    buffer.Append(Consume());
                    m_tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.Plus, Line = line });
                }
                else if (curr_token == '-')
                {
                    buffer.Append(Consume());
                    m_tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.Minus, Line = line });
                }
                else if (curr_token == '&')
                {
                    buffer.Append(Consume());
                    m_tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.And, Line = line });
                }
                else if (curr_token == '|')
                {
                    buffer.Append(Consume());
                    m_tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.Or, Line = line });
                }
                else if (curr_token == '^')
                {
                    buffer.Append(Consume());
                    m_tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.Xor, Line = line });
                }
                else if ((Peek('<').HasValue && Peek('<', 1).HasValue))
                {
                    buffer.Append(Consume());
                    buffer.Append(Consume());
                    m_tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.Sll, Line = line });
                }
                else if ((Peek('>').HasValue && Peek('>', 1).HasValue))
                {
                    buffer.Append(Consume());
                    buffer.Append(Consume());
                    m_tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.Srl, Line = line });
                }
                else if (Peek('=').HasValue && Peek('=', 1).HasValue)
                {
                    buffer.Append(Consume());
                    buffer.Append(Consume());
                    m_tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.EqualEqual, Line = line });
                }
                else if (Peek('!').HasValue && Peek('=', 1).HasValue)
                {
                    buffer.Append(Consume());
                    buffer.Append(Consume());
                    m_tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.NotEqual, Line = line });
                }
                else if (Peek('<').HasValue)
                {
                    buffer.Append(Consume());
                    m_tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.LessThan, Line = line });
                }
                // end operators
                else if (curr_token == '=')
                {
                    buffer.Append(Consume());
                    m_tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.Equal, Line = line });
                }

                else if (curr_token == ';')
                {
                    buffer.Append(Consume());
                    m_tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.SemiColon, Line = line });
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
                    Error(curr_token);
                }
                buffer.Clear();
            }
            m_curr_index = 0;
            return m_tokens;
        }

    }
}


#pragma warning restore CS8629 // Nullable value type may be null.