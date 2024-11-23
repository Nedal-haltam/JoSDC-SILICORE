#pragma warning disable CS8629 // Nullable value type may be null.



namespace Epsilon
{
    class Parser
    {
        private List<Token> m_tokens;
        private int m_curr_index = 0;
        public Parser(List<Token> tokens)
        {
            m_tokens = tokens;
        }

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
            Console.WriteLine($"Parser: Error Expected {msg} on line: {peek(-1).Value.Line}");
            Console.ResetColor();
            Environment.Exit(1);
        }

        bool IsStmtDeclare()
        {
            return (peek(TokenType.Int, 0).HasValue) &&
                   peek(TokenType.Ident, 1).HasValue &&
                   peek(TokenType.Equal, 2).HasValue;
        }

        bool IsStmtAssign()
        {
            return peek(TokenType.Ident).HasValue &&
                   peek(TokenType.Equal).HasValue;
        }

        bool IsBinExpr()
        {
            return peek(TokenType.Plus).HasValue ||
                   peek(TokenType.Minus).HasValue ||
                   peek(TokenType.And).HasValue ||
                   peek(TokenType.Or).HasValue ||
                   peek(TokenType.Xor).HasValue ||
                   peek(TokenType.Nor).HasValue ||
                   peek(TokenType.Sll).HasValue ||
                   peek(TokenType.Srl).HasValue;
        }


        NodeTerm? ParseTerm()
        {
            NodeTerm term = new NodeTerm();
            if (peek(TokenType.IntLit).HasValue)
            {
                term.type = NodeTerm.NodeTermType.intlit;
                term.intlit.intlit = consume();
                return term;
            }
            else if (peek(TokenType.Ident).HasValue)
            {
                term.type = NodeTerm.NodeTermType.ident;
                term.ident.ident = consume();
                return term;
            }

            return null;
        }

        unsafe NodeExpr? ParseExpr()
        {
            NodeTerm? Termlhs = ParseTerm();
            if (!Termlhs.HasValue)
            {
                return null;
            }
            NodeExpr expr = new NodeExpr();
            if (IsBinExpr())
            {
                expr.type = NodeExpr.NodeExprType.binExpr;
                NodeBinExpr binExpr = new NodeBinExpr();
                binExpr.type = (NodeBinExpr.NodeBinExprType)consume().Type;
                binExpr.lhs.type = NodeExpr.NodeExprType.term;
                binExpr.lhs.term = Termlhs.Value;
                binExpr.rhs.type = NodeExpr.NodeExprType.term;
                NodeTerm? Termrhs = ParseTerm(); // TODO: make it parse an expression and introduce operation precedence
                if (!Termrhs.HasValue)
                {
                    return null;
                }
                binExpr.rhs.term = Termrhs.Value;
                expr.binexpr = binExpr;
                return expr;
            }
            else
            {
                expr.type = NodeExpr.NodeExprType.term;
                expr.term = Termlhs.Value;
                return expr;
            }
        }

        NodeStmt? ParseStmt()
        {
            // see what possible statements you have and parse it (stmts: declare, assign, if, for)
            if (IsStmtDeclare())
            {
                Token vartype = consume();
                NodeStmtDeclare declare = new NodeStmtDeclare();
                if (vartype.Type == TokenType.Int)
                {
                    declare.type = NodeStmtDeclare.NodeStmtDeclareType.Int;
                }
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
            else if (peek(TokenType.Return).HasValue)
            {
                consume();
                NodeStmtReturn Return = new NodeStmtReturn();
                NodeExpr? expr = ParseExpr();
                if (expr.HasValue)
                {
                    Return.expr = expr.Value;
                }
                else
                {
                    ErrorExpected("expression ");
                }
                try_consume_err(TokenType.SemiColon);
                NodeStmt stmt = new NodeStmt();
                stmt.type = NodeStmt.NodeStmtType.Return;
                stmt.Return = Return;
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