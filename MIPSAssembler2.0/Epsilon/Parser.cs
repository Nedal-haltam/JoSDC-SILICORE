using Microsoft.VisualBasic;
using NuGet.Common;
using OfficeOpenXml.Drawing;
using OfficeOpenXml.Drawing.Style.Fill;
using OfficeOpenXml.FormulaParsing.Exceptions;
using OfficeOpenXml.FormulaParsing.Ranges;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;
#pragma warning disable CS8629 // Nullable value type may be null.
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
        Token? peek(int offset = 0)
        {
            if (m_curr_index + offset < m_tokens.Count)
            {
                return m_tokens[m_curr_index + offset];
            }
            return null;
        }
        Token? peek(TokenType type, int offset = 0)
        {
            Token? token = peek(offset);
            if (token.HasValue && token.Value.Type == type)
            {
                return token;
            }
            return null;
        }
        Token consume()
        {
            return m_tokens.ElementAt(m_curr_index++);
        }
        Token? try_consume(TokenType type)
        {
            if (peek(type).HasValue) {
                return consume();
            }
            return null;
        }
        Token? try_consume_err(TokenType type)
        {
            if (peek(type).HasValue)
            {
                return consume();
            }
            ErrorExpected($"Expected: {type}");
            return null;
        }
        void ErrorExpected(string msg)
        {
            Console.ForegroundColor = ConsoleColor.Red;
            Console.WriteLine($"Error Expected {msg} on line: {peek().Value.Line}");
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
            return (peek(TokenType.Reg, 0).HasValue || peek(TokenType.Mem, 0).HasValue) &&
                   peek(TokenType.Ident, 1).HasValue &&
                   peek(TokenType.Equal, 2).HasValue;
        }

        bool IsStmtAssign()
        {
            return peek(TokenType.Ident).HasValue &&
                   peek(TokenType.Equal).HasValue;
        }

        NodeExpr? ParseExpr()
        {
            throw new NotImplementedException();
        }

        NodeStmt? ParseStmt()
        {
            // see what possible statements you have and parse it (stmts: declare, assign, if, for)
            if (IsStmtDeclare())
            {
                Token reg_mem = consume();
                NodeStmtDeclare declare = new NodeStmtDeclare();
                declare.type = (reg_mem.Type == TokenType.Reg) ? NodeStmtDeclare.NodeStmtDeclareType.Reg : NodeStmtDeclare.NodeStmtDeclareType.Mem;
                declare.ident = consume();
                consume();
                NodeExpr? expr = ParseExpr();
                if (expr.HasValue)
                {
                    declare.expr = expr.Value;
                }
                else
                {
                    ErrorExpected("expression");
                }
                try_consume_err(TokenType.SemiColon);
                NodeStmt stmt = new NodeStmt();
                stmt.type = NodeStmt.NodeStmtType.nodestmtdeclare;
                stmt.declare = declare;
                return stmt;
            }
            else if (IsStmtAssign())
            {
                NodeStmtAssign assign = new NodeStmtAssign();
                assign.ident = consume();
                consume();
                NodeExpr? expr = ParseExpr();
                if (expr.HasValue)
                {
                    assign.expr = expr.Value;
                }
                else
                {
                    ErrorExpected("expression");
                }
                try_consume_err(TokenType.SemiColon);
                NodeStmt stmt = new NodeStmt();
                stmt.type = NodeStmt.NodeStmtType.nodestmtassign;
                stmt.assign = assign;
                return stmt;
            }   


            return null;
        }


        public NodeProg Parse()
        {
            NodeProg prog = new NodeProg();
            
            while (peek().HasValue)
            {
                NodeStmt? stmt = ParseStmt();
                if (stmt.HasValue)
                    prog.stmts.Add(stmt.Value);
                else
                    ErrorExpected($"statement");
            }

            return prog;
        }
    }
}
#pragma warning restore CS8629 // Nullable value type may be null.