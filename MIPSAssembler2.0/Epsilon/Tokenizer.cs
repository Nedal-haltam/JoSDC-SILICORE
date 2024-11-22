using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
#pragma warning disable CS8629 // Nullable value type may be null.
namespace Epsilon
{
    class Tokenizer
    {
        private string m_thecode;
        private int m_curr_index = 0;
        public Tokenizer(string thecode)
        {
            m_thecode = thecode;
        }
        char? peek(int offset = 0)
        {
            if (m_curr_index + offset < m_thecode.Length)
            {
                return m_thecode[m_curr_index + offset];
            }
            return null;
        }
        char? peek(char type, int offset = 0)
        {
            char? token = peek(offset);
            if (token.HasValue && token.Value == type)
            {
                return token;
            }
            return null;
        }
        char consume()
        {
            return m_thecode.ElementAt(m_curr_index++);
        }

        bool IsComment()
        {
            return peek('/').HasValue && peek('/', 1).HasValue;
        }
        public List<Token> Tokinze()
        {
            List<Token> tokens = [];
            StringBuilder buffer = new(); // this buffer is for multiple letter tokens
            int line = 1;
            while (peek().HasValue)
            {
                // it may be the follwing
                // letter, digit , // (comment) , `(` , `)` , `[` , `]` , `,` , (+, -, <, >, &, |, ^, ~|, <<, >>) , `=` , `;` , `\n` (for line increament) , ` ` , else invalid token
                if (char.IsAsciiLetter(peek().Value))
                {
                    buffer.Append(consume());
                    // if it is a letter we will consume until it is not IsAsciiLetterOrDigit
                    while (peek().HasValue && char.IsAsciiLetterOrDigit(peek().Value))
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
                else if (char.IsDigit(peek().Value))
                {
                    buffer.Append(consume());
                    while (peek().HasValue && char.IsDigit(peek().Value))
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
                    while (peek('\n').HasValue)
                    {
                        consume();
                    }
                }
                else if (peek('/').HasValue && peek('*').HasValue)
                {
                    consume();
                    consume();
                    while (peek().HasValue)
                    {
                        if (peek('*').HasValue && peek('/').HasValue)
                        {
                            break;
                        }
                        consume();
                    }
                    if (peek().HasValue)
                    {
                        consume();
                    }
                    if (peek().HasValue)
                    {
                        consume();
                    }
                }
                else if (peek().Value == '(')
                {
                    buffer.Append(consume());
                    tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.OpenParen, Line = line });
                }
                else if (peek().Value == ')')
                {
                    buffer.Append(consume());
                    tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.CloseParen, Line = line });
                }
                else if (peek().Value == '[')
                {
                    buffer.Append(consume());
                    tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.OpenSquare, Line = line });
                }
                else if (peek().Value == ']')
                {
                    buffer.Append(consume());
                    tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.CloseSquare, Line = line });
                }
                else if (peek().Value == ',')
                {
                    buffer.Append(consume());
                    tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.Comma, Line = line });
                }
                // operators
                else if (peek().Value == '+')
                {
                    buffer.Append(consume());
                    tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.Plus, Line = line });
                }
                else if (peek().Value == '-')
                {
                    buffer.Append(consume());
                    tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.Minus, Line = line });
                }
                //else if (peek().Value == '<')
                //{
                //    buffer.Append(consume());
                //    tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.LessThan, Line = line });
                //}
                //else if (peek().Value == '>')
                //{
                //    buffer.Append(consume());
                //    tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.GreaterThan, Line = line });
                //}
                else if (peek().Value == '&')
                {
                    buffer.Append(consume());
                    tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.And, Line = line });
                }
                else if (peek().Value == '|')
                {
                    buffer.Append(consume());
                    tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.Or, Line = line });
                }
                else if (peek().Value == '^')
                {
                    buffer.Append(consume());
                    tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.Xor, Line = line });
                }
                else if ((peek('<').HasValue && peek('<', 1).HasValue))
                {
                    buffer.Append(consume());
                    buffer.Append(consume());
                    tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.Sll, Line = line });
                }
                else if ((peek('>').HasValue && peek('>', 1).HasValue))
                {
                    buffer.Append(consume());
                    buffer.Append(consume());
                    tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.Srl, Line = line });
                }
                else if ((peek('~').HasValue && peek('|', 1).HasValue))
                {
                    buffer.Append(consume());
                    buffer.Append(consume());
                    tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.Nor, Line = line });
                }
                // end operators
                else if (peek().Value == '=')
                {
                    buffer.Append(consume());
                    tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.Equal, Line = line });
                }
                else if (peek().Value == ';')
                {
                    buffer.Append(consume());
                    tokens.Add(new() { Value = buffer.ToString(), Type = TokenType.SemiColon, Line = line });
                }
                else if (peek().Value == '\n')
                {
                    consume();
                    line++;
                }
                else if (char.IsWhiteSpace(peek().Value))
                {
                    consume();
                }
                else
                {
                    Console.ForegroundColor = ConsoleColor.Red;

                    Console.Error.WriteLine($"Invalid token: {peek().Value}");
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