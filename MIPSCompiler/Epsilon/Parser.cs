#pragma warning disable CS8629 // Nullable value type may be null.



using System.Linq.Expressions;
using System.Reflection.Metadata;
using System.Runtime.CompilerServices;

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
            Console.WriteLine($"Parser: Error Expected {msg} on line: {peek().Value.Line}");
            Console.ResetColor();
            Environment.Exit(1);
        }

        bool IsStmtDeclare()
        {
            return (peek(TokenType.Int, 0).HasValue) &&
                   peek(TokenType.Ident, 1).HasValue;
        }
        bool IsStmtAssign()
        {
            return peek(TokenType.Ident).HasValue &&
                   peek(TokenType.Equal, 1).HasValue;
        }
        bool IsStmtIF()
        {
            return peek(TokenType.Iff, 0).HasValue;
        }
        bool IsStmtExit()
        {
            return peek(TokenType.Exit).HasValue &&
                   peek(TokenType.OpenParen, 1).HasValue;
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
                   peek(TokenType.EqualEqual).HasValue ||
                   peek(TokenType.NotEqual).HasValue ||
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
            else if (peek(TokenType.OpenParen).HasValue)
            {
                consume();
                NodeExpr? expr = ParseExpr();
                if (!expr.HasValue)
                {
                    ErrorExpected("expression");
                }
                try_consume_err(TokenType.CloseParen);
                NodeTermParen paren = new NodeTermParen();
                paren.expr = expr.Value;
                term.type = NodeTerm.NodeTermType.paren;
                term.paren = paren;
                return term;
            }

            return null;
        }

        int? GetPrec(TokenType type)
        {
            switch (type)
            {
                case TokenType.EqualEqual:
                case TokenType.NotEqual:
                case TokenType.Plus:
                case TokenType.Minus:
                    return 0;
                case TokenType.star:
                case TokenType.fslash:
                    return 1;
                default: return null;
            }
        }

        NodeExpr? ParseExpr(int min_prec = 0)
        {
            NodeTerm? Termlhs = ParseTerm();
            if (!Termlhs.HasValue)
            {
                return null;
            }
            NodeExpr exprlhs = new NodeExpr();
            exprlhs.type = NodeExpr.NodeExprType.term;
            exprlhs.term = Termlhs.Value;

            if (IsBinExpr())
            {
                while (true)
                {
                    Token? curr_tok = peek();
                    int? prec;
                    if (curr_tok.HasValue)
                    {
                        prec = GetPrec(curr_tok.Value.Type);
                        if (!prec.HasValue || prec < min_prec)
                        {
                            break;
                        }
                    }
                    else
                    {
                        break;
                    }
                    Token op = consume();
                    int next_min_prec = prec.Value + 1;
                    NodeExpr? expr_rhs = ParseExpr(next_min_prec);
                    if (!expr_rhs.HasValue)
                    {
                        ErrorExpected("expression");
                    }
                    NodeBinExpr expr = new NodeBinExpr();
                    NodeExpr expr_lhs2 = new NodeExpr();
                    expr_lhs2 = exprlhs;
                    expr.type = (NodeBinExpr.NodeBinExprType)op.Type;
                    expr.lhs = expr_lhs2;
                    expr.rhs = expr_rhs.Value;

                    exprlhs.type = NodeExpr.NodeExprType.binExpr;
                    exprlhs.binexpr = expr;
                }

                return exprlhs;
            }
            else
            {
                exprlhs.type = NodeExpr.NodeExprType.term;
                exprlhs.term = Termlhs.Value;
                return exprlhs;
            }
        }

        NodeScope? ParseScope()
        {
            NodeScope scope = new NodeScope();
            if (peek(TokenType.OpenCurly).HasValue)
            {
                consume();
                while (!peek(TokenType.CloseCurly).HasValue)
                {
                    scope.stmts = [];
                    NodeStmt? stmt = ParseStmt();
                    if (stmt.HasValue)
                    {
                        scope.stmts.Add(stmt.Value);
                    }
                    else
                    {
                        return null;
                    }
                }
                try_consume_err(TokenType.CloseCurly);
                return scope;
            }
            else
            {
                NodeStmt? stmt = ParseStmt();
                if (stmt.HasValue)
                {
                    scope.stmts = [];
                    scope.stmts.Add(stmt.Value);
                    return scope;
                }
                else
                {
                    return null;
                }
            }
        }

        NodeIfElifs? ParseElifs()
        {
            NodeIfElifs elifs = new NodeIfElifs();
            if (peek(TokenType.Elif).HasValue)
            {
                consume();
                NodeIfPredicate? pred = ParsePredicate();
                if (pred.HasValue)
                {
                    elifs.type = NodeIfElifs.NodeIfElifsType.elif;
                    elifs.elif = new NodeElif();
                    elifs.elif.pred = pred.Value;
                    elifs.elif.elifs = ParseElifs();
                    return elifs;
                }
                else
                {
                    ErrorExpected("predicate");

                }
            }
            else if (peek(TokenType.Else).HasValue)
            {
                consume();
                NodeScope? scope = ParseScope();
                if (scope.HasValue)
                {
                    elifs.type = NodeIfElifs.NodeIfElifsType.elsee;
                    elifs.elsee = new NodeElse();
                    elifs.elsee.scope = scope.Value;
                    return elifs;
                }
                else
                {
                    ErrorExpected("scope");
                }
            }
            return null;
        }

        NodeIfPredicate? ParsePredicate()
        {
            if (!peek(TokenType.OpenParen).HasValue)
            {
                return null;
            }
            consume();
            NodeIfPredicate pred = new NodeIfPredicate();
            NodeExpr? cond = ParseExpr();
            if (cond.HasValue)
            {
                pred.cond = cond.Value;
            }
            else
            {
                return null;
            }
            try_consume_err(TokenType.CloseParen);
            NodeScope? scope = ParseScope();
            if (scope.HasValue)
            {
                pred.scope = scope.Value;
            }
            else
            {
                return null;
            }
            return pred;
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
                else
                {
                    ErrorExpected("variable type");
                }
                declare.ident = consume();
                if (peek(TokenType.Equal).HasValue)
                {
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
                }
                else
                {
                    NodeExpr expr = new()
                    {
                        type = NodeExpr.NodeExprType.term
                    };
                    expr.term.type = NodeTerm.NodeTermType.intlit;
                    expr.term.intlit.intlit.Type = TokenType.Int;
                    expr.term.intlit.intlit.Value = "0";
                    declare.expr = expr;
                }
                try_consume_err(TokenType.SemiColon);
                NodeStmt stmt = new NodeStmt();
                stmt.type = NodeStmt.NodeStmtType.declare;
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
                stmt.type = NodeStmt.NodeStmtType.assign;
                stmt.assign = assign;
                return stmt;
            }
            else if (IsStmtIF())
            {
                consume();
                NodeStmtIF iff = new NodeStmtIF();
                NodeIfPredicate? pred = ParsePredicate();
                if (pred.HasValue)
                {
                    iff.pred = pred.Value;
                }
                else
                {
                    return null;
                }
                NodeIfElifs? elifs = ParseElifs();
                iff.elifs = elifs;
                NodeStmt stmt = new NodeStmt();
                stmt.type = NodeStmt.NodeStmtType.iff;
                stmt.iff = iff;
                return stmt;
            }
            else if (IsStmtExit())
            {
                consume();
                consume();
                NodeStmtExit Return = new NodeStmtExit();
                NodeExpr? expr = ParseExpr();
                if (expr.HasValue)
                {
                    Return.expr = expr.Value;
                }
                else
                {
                    ErrorExpected("expression");
                }
                try_consume_err(TokenType.CloseParen);
                try_consume_err(TokenType.SemiColon);
                NodeStmt stmt = new NodeStmt();
                stmt.type = NodeStmt.NodeStmtType.Exit;
                stmt.Exit = Return;
                return stmt;
            }


            return null;
        }


        public NodeProg ParseProg()
        {
            NodeProg prog = new NodeProg();
            
            while (peek().HasValue)
            {
                NodeStmt? stmt = ParseStmt();
                if (stmt.HasValue)
                    prog.scope.stmts.Add(stmt.Value);
                else
                    ErrorExpected($"statement");
            }
            return prog;
        }
    }
}
#pragma warning restore CS8629 // Nullable value type may be null.