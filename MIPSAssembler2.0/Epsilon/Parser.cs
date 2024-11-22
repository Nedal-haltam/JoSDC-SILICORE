using Microsoft.VisualBasic;
using OfficeOpenXml.Drawing.Style.Fill;
using OfficeOpenXml.FormulaParsing.Exceptions;
using OfficeOpenXml.FormulaParsing.Ranges;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;

namespace Epsilon
{
    struct NodeProg
    {
        public List<NodeStmt> stmts;

        public NodeProg()
        {
            stmts = new List<NodeStmt>();
        }
    }
    class Parser
    {
        Temp<Token> peek(int offset = 0)
        {
            bool still = (m_curr_index + offset < m_tokens.Count);
            Temp<Token> t = new()
            {
                hasvalue = still,
                value = (still) ? m_tokens[m_curr_index + offset] : new Token()
            };
            return t;
        }
        Token? try_consume(TokenType type)
        {
            if (peek().hasvalue && peek().value.Type == type) {
                return consume();
            }
            return null;
        }
        Token? try_consume_err(TokenType type)
        {
            if (peek().hasvalue && peek().value.Type == type)
            {
                return consume();
            }
            ErrorExpected($"Expected: {type}");
            return null;
        }
        Token consume()
        {
            return m_tokens.ElementAt(m_curr_index++);
        }
        void ErrorExpected(string msg)
        {
            Console.ForegroundColor = ConsoleColor.Red;
            Console.WriteLine($"Error Expected {msg} on line: {peek().value.Line}");
            Console.ResetColor();
            Environment.Exit(1);
        }

        private List<Token> m_tokens;
        private int m_curr_index = 0;
        public Parser(List<Token> tokens)
        {
            m_tokens = tokens;
        }


        bool IsStmtDeclare()
        {
            throw new NotImplementedException();
        }

        bool IsStmtAssign()
        {
            throw new NotImplementedException();
        }


        NodeStmt? ParseStmt()
        {
            // TODO: see what possible statements you have and parse it (stmts: declare, assign, if, for)
            if (IsStmtDeclare())
            {

            }
            else if (IsStmtAssign())
            {

            }   


            return null;
        }


        public NodeProg Parse()
        {
            NodeProg prog = new NodeProg();
            
            while (peek().hasvalue)
            {
                NodeStmt? stmt = ParseStmt();
                if (stmt != null)
                    prog.stmts.Add((NodeStmt)stmt);
                else
                    ErrorExpected($"statement");
            }

            return prog;
        }
    }
}
