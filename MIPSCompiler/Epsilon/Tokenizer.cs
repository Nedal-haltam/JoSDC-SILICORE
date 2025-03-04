using System.Collections.Generic;
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
        Int, Ident, For, While, If, Elif, Else, IntLit, Exit, fslash, star, LessThan, GreaterThan, Break, Continue
    }
    class Tokenizer(string thecode)
    {
        Dictionary<string, TokenType> tokens = new()
        {
            { "int", TokenType.Int},
            {"if", TokenType.If},
            {"elif", TokenType.Elif},
            {"else", TokenType.Else},
            {"for", TokenType.For},
            {"while", TokenType.While},
            {"break", TokenType.Break},
            {"continue", TokenType.Continue},
            {"exit", TokenType.Exit},
            {"(", TokenType.OpenParen},
            {")", TokenType.CloseParen},
            {"[", TokenType.OpenSquare},
            {"]", TokenType.CloseSquare},
            {"{", TokenType.OpenCurly},
            {"}", TokenType.CloseCurly},
            {",", TokenType.Comma},
            {"+", TokenType.Plus},
            {"-", TokenType.Minus},
            {"&", TokenType.And},
            {"|", TokenType.Or},
            {"^", TokenType.Xor},
            {"<", TokenType.LessThan},
            {"=", TokenType.Equal },
            {";", TokenType.SemiColon},

        };
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
        public struct Macro
        {
            public List<string> inputs;
            public List<Token> value;
            public string src;
        }
        private Dictionary<string, Macro> macro = [];
        public List<Token> Tokenize()
        {
            m_tokens = [];
            StringBuilder buffer = new(); // this buffer is for multiple letter tokens
            int line = 1;
            while (Peek().HasValue)
            {
                char curr_token = Peek().Value;

                if (char.IsAsciiLetter(curr_token) || curr_token == '_')
                {
                    buffer.Append(Consume());
                    // if it is a letter we will consume until it is not IsAsciiLetterOrDigit
                    while (Peek().HasValue && (char.IsAsciiLetterOrDigit(Peek().Value) || Peek('_').HasValue))
                    {
                        buffer.Append(Consume());
                    }
                    string word = buffer.ToString();
                    if (macro.ContainsKey(word))
                    {
                        buffer.Clear();
                        List<string> inputs = [];
                        if (Peek('(').HasValue)
                        {
                            Consume();
                            while (!Peek(')').HasValue)
                            {
                                if (Peek(',').HasValue)
                                {
                                    if (string.IsNullOrEmpty(buffer.ToString()) || string.IsNullOrWhiteSpace(buffer.ToString()))
                                        throw new Exception("invalid macro input");
                                    inputs.Add(buffer.ToString());
                                    buffer.Clear();
                                }
                                else
                                {
                                    buffer.Append(Consume());
                                }
                            }
                            Consume();
                        }
                        inputs.Add(buffer.ToString());
                        buffer.Clear();

                        if (inputs.Count != macro[word].inputs.Count)
                            throw new Exception("inputs does not match macro definition");
                        string src = macro[word].src;
                        for (int i = 0; i < macro[word].inputs.Count; i++)
                        {
                            src = Regex.Replace(macro[word].src, $@"\b{Regex.Escape(macro[word].inputs[i])}\b", inputs[i]);
                        }
                        Tokenizer temp = new(src);
                        temp.macro = macro;
                        m_tokens.AddRange(temp.Tokenize());
                    }
                    else if (tokens.TryGetValue(word, out TokenType tt))
                    {
                        m_tokens.Add(new() { Value = word, Type = tt, Line = line });
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

                // multi-token operators
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
                
                else if (tokens.TryGetValue(curr_token.ToString(), out TokenType tt))
                {
                    buffer.Append(Consume());
                    m_tokens.Add(new() { Value = buffer.ToString(), Type = tt, Line = line });
                }
                else if (curr_token == '#')
                {
                    if (IsMacro())
                    {
                        // aready consumed, now we get the name and the value
                        while (Peek(' ').HasValue) Consume();
                        while (Peek().HasValue && (char.IsAsciiLetterOrDigit(Peek().Value) || Peek('_').HasValue))
                        {
                            buffer.Append(Consume());
                        }
                        string macroname = buffer.ToString();
                        buffer.Clear();
                        while (Peek(' ').HasValue) Consume();
                        List<string> inputs = [];
                        if (Peek('(').HasValue)
                        {
                            Consume();
                            while (!Peek(')').HasValue)
                            {
                                if (Peek(',').HasValue)
                                {
                                    if (string.IsNullOrEmpty(buffer.ToString()) || string.IsNullOrWhiteSpace(buffer.ToString()))
                                        throw new Exception("invalid macro input");
                                    inputs.Add(buffer.ToString());
                                    buffer.Clear();
                                }
                                else
                                {
                                    buffer.Append(Consume());
                                }
                            }
                            Consume();
                        }
                        inputs.Add(buffer.ToString());
                        buffer.Clear();


                        while (!Peek('\n').HasValue)
                        {
                            buffer.Append(Consume());
                        }
                        Consume();
                        string MacroSrc = buffer.ToString();
                        Tokenizer temp = new(MacroSrc);
                        List<Token> macrovalue = temp.Tokenize();
                        for (int i = 0; i < macrovalue.Count; i++)
                        {
                            if (macro.ContainsKey(macrovalue[i].Value))
                            {
                                Token t = macrovalue[i];
                                macrovalue.RemoveAt(i);
                                macrovalue.InsertRange(i, macro[t.Value].value);
                            }
                        }
                        macro.Add(macroname, new() { src = MacroSrc, inputs = inputs, value = macrovalue });
                    }
                    else
                    {
                        Error(curr_token);
                    }
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