#pragma warning disable CS8629 // Nullable value type may be null.



using Microsoft.VisualBasic;
using System.Linq.Expressions;
using System.Net.Sockets;
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
            return (peek(TokenType.Int).HasValue) &&
                   peek(TokenType.Ident, 1).HasValue;
        }
        bool IsStmtAssign()
        {
            return peek(TokenType.Ident).HasValue;
        }
        bool IsStmtIF()
        {
            return peek(TokenType.Iff).HasValue;
        }
        bool IsStmtFor()
        {
            return peek(TokenType.For).HasValue;
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
                   peek(TokenType.Sll).HasValue ||
                   peek(TokenType.Srl).HasValue ||
                   peek(TokenType.EqualEqual).HasValue ||
                   peek(TokenType.NotEqual).HasValue ||
                   peek(TokenType.LessThan).HasValue ||
                   peek(TokenType.GreaterThan).HasValue;
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
                term.ident = new();
                term.ident.ident = consume();
                term.ident.index = null;
                if (peek(TokenType.OpenSquare).HasValue)
                {
                    consume();
                    NodeExpr? index = ParseExpr();
                    if (!index.HasValue)
                    {
                        ErrorExpected("expression");
                    }
                    term.ident.index = index;
                    try_consume_err(TokenType.CloseSquare);
                }
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
                case TokenType.LessThan:
                case TokenType.GreaterThan:
                    return 0;
                case TokenType.Sll:
                case TokenType.Srl:
                    return 1;
                case TokenType.Plus:
                case TokenType.Minus:
                    return 2;
                default: return null;
            }
        }
        NodeBinExpr.NodeBinExprType? GetOpType(TokenType op)
        {
            if (op == TokenType.Plus)
                return NodeBinExpr.NodeBinExprType.add;
            if (op == TokenType.Minus)
                return NodeBinExpr.NodeBinExprType.sub;
            if (op == TokenType.Sll)
                return NodeBinExpr.NodeBinExprType.sll;
            if (op == TokenType.Srl)
                return NodeBinExpr.NodeBinExprType.srl;
            if (op == TokenType.EqualEqual)
                return NodeBinExpr.NodeBinExprType.equalequal;
            if (op == TokenType.NotEqual)
                return NodeBinExpr.NodeBinExprType.notequal;
            if (op == TokenType.LessThan)
                return NodeBinExpr.NodeBinExprType.lessthan;
            if (op == TokenType.GreaterThan)
                return NodeBinExpr.NodeBinExprType.greaterthan;
            return null;
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
                    NodeBinExpr.NodeBinExprType? optype = GetOpType(op.Type);
                    if (optype.HasValue)
                        expr.type = optype.Value;
                    else
                        return null;
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
                scope.stmts = [];
                while (!peek(TokenType.CloseCurly).HasValue)
                {
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
                NodeIfPredicate? pred = ParseIfPredicate();
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

        NodeIfPredicate? ParseIfPredicate()
        {
            if (!peek(TokenType.OpenParen).HasValue)
                return null;
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
        NodeForInit? ParseForInit()
        {
            if (IsStmtDeclare())
            {
                Token vartype = consume();
                NodeStmtDeclareSingleVar declare = new();
                if (vartype.Type != TokenType.Int)
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
                NodeForInit forinit = new NodeForInit();
                forinit.type = NodeForInit.NodeForInitType.declare;
                forinit.declare.type = NodeStmtDeclare.NodeStmtDeclareType.SingleVar;
                forinit.declare.singlevar = declare;
                return forinit;
            }
            else if (IsStmtAssign())
            {
                NodeStmtAssignSingleVar singlevar = new();
                singlevar.ident = consume();
                consume();
                NodeExpr? expr = ParseExpr();
                if (expr.HasValue)
                {
                    singlevar.expr = expr.Value;
                }
                else
                {
                    ErrorExpected("expression");
                }
                try_consume_err(TokenType.SemiColon);
                NodeForInit forinit = new NodeForInit();
                forinit.type = NodeForInit.NodeForInitType.assign;
                forinit.assign.type = NodeStmtAssign.NodeStmtAssignType.SingleVar;
                forinit.assign.singlevar = singlevar;
                return forinit;
            }
            return null;
        }
        NodeForCond? ParseForCond()
        {
            NodeForCond forcond = new NodeForCond();
            NodeExpr? cond = ParseExpr();
            if (cond.HasValue)
            {
                try_consume_err(TokenType.SemiColon);
                forcond.cond = cond.Value;
            }
            else
            {
                try_consume_err(TokenType.SemiColon);
                return null;
            }
            return forcond;
        }
        NodeStmtAssign? ParseStmtUpdate()
        {
            if (IsStmtAssign())
            {
                NodeStmtAssignSingleVar singlevar = new();
                singlevar.ident = consume();
                consume();
                NodeExpr? expr = ParseExpr();
                if (expr.HasValue)
                {
                    singlevar.expr = expr.Value;
                }
                else
                {
                    ErrorExpected("expression");
                }
                NodeStmtAssign assign = new();
                assign.type = NodeStmtAssign.NodeStmtAssignType.SingleVar;
                assign.singlevar = singlevar;
                return assign;
            }
            else
            {
                return null;
            }
        }
        NodeForUpdate? ParseForUpdate()
        {
            NodeForUpdate forupdate = new NodeForUpdate();
            forupdate.udpates = [];
            NodeStmtAssign? update = ParseStmtUpdate();
            if (update.HasValue)
            {
                while (update.HasValue)
                {
                    forupdate.udpates.Add(update.Value);
                    if (peek(TokenType.CloseParen).HasValue)
                    {
                        consume();
                        return forupdate;
                    }
                    try_consume_err(TokenType.Comma);
                    update = ParseStmtUpdate();
                }
                ErrorExpected("statement assign");
                return null;
            }
            else
            {
                try_consume_err(TokenType.CloseParen);
                return null;
            }
        }
        NodeForPredicate? ParseForPredicate()
        {
            NodeForPredicate pred = new NodeForPredicate();
            if (!peek(TokenType.OpenParen).HasValue)
                return null;
            consume();
            pred.init = ParseForInit();
            pred.cond = ParseForCond();
            pred.udpate = ParseForUpdate();
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
        NodeStmt? ParseDeclareSingleVar(Token ident)
        {
            NodeStmtDeclareSingleVar declare = new();
            declare.ident = ident;
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
            NodeStmt stmt = new();
            stmt.type = NodeStmt.NodeStmtType.declare;
            stmt.declare.type = NodeStmtDeclare.NodeStmtDeclareType.SingleVar;
            stmt.declare.singlevar = declare;
            return stmt;
        }
        NodeExpr ExprZero()
        {
            NodeExpr expr = new()
            {
                type = NodeExpr.NodeExprType.term
            };
            expr.term.type = NodeTerm.NodeTermType.intlit;
            expr.term.intlit.intlit.Type = TokenType.Int;
            expr.term.intlit.intlit.Value = "0";
            return expr;
        }
        NodeStmt? ParseDeclareArray(Token ident)
        {
            NodeStmtDeclareArray declare = new();
            declare.ident = ident;
            declare.values = [];
            consume();
            Token size_token = consume();
            if (!uint.TryParse(size_token.Value, out uint size))
            {
                ErrorExpected("a constant size for the array");
            }
            try_consume_err(TokenType.CloseSquare);
            if (peek(TokenType.Equal).HasValue)
            {
                consume();
                try_consume_err(TokenType.OpenCurly);
                for (int i = 0; i < size; i++)
                {
                    NodeExpr? expr = ParseExpr();
                    if (!expr.HasValue)
                        ErrorExpected("expression");
                    declare.values.Add(new() { ident = new() { Line = ident.Line, Type = ident.Type, Value = ident.Value + $"{i}" }, expr = expr.Value });
                    if (peek(TokenType.CloseCurly).HasValue)
                    {
                        consume();
                        break;
                    }
                    try_consume_err(TokenType.Comma);
                }
            }
            else
            {
                NodeExpr expr = ExprZero();
                for (int i = 0; i < size; i++)
                {
                    declare.values.Add(new() { ident = new() { Line = ident.Line, Type = ident.Type, Value = ident.Value + $"{i}" }, expr = expr });
                }
            }
            try_consume_err(TokenType.SemiColon);
            NodeStmt stmt = new();
            stmt.type = NodeStmt.NodeStmtType.declare;
            stmt.declare.type = NodeStmtDeclare.NodeStmtDeclareType.Array;
            stmt.declare.array = declare;
            return stmt;
        }
        NodeStmt? ParseAssignSingleVar()
        {
            NodeStmtAssignSingleVar singlevar = new();
            singlevar.ident = consume();
            consume();
            NodeExpr? expr = ParseExpr();
            if (expr.HasValue)
            {
                singlevar.expr = expr.Value;
            }
            else
            {
                ErrorExpected("expression");
            }
            try_consume_err(TokenType.SemiColon);
            NodeStmt stmt = new NodeStmt();
            stmt.type = NodeStmt.NodeStmtType.assign;
            stmt.assign.type = NodeStmtAssign.NodeStmtAssignType.SingleVar;
            stmt.assign.singlevar = singlevar;
            return stmt;
        }
        NodeStmt? ParseAssignArray()
        {
            NodeStmtAssignArray array = new();
            array.ident = consume();
            consume();
            NodeExpr? index = ParseExpr();
            if (index.HasValue)
            {
                array.index = index.Value;
            }
            else
            {
                ErrorExpected("expression");
            }
            try_consume_err(TokenType.CloseSquare);
            try_consume_err(TokenType.Equal);
            NodeExpr? expr = ParseExpr();
            if (expr.HasValue)
            {
                array.expr = expr.Value;
            }
            else
            {
                ErrorExpected("expression");
            }
            try_consume_err(TokenType.SemiColon);
            NodeStmt stmt = new NodeStmt();
            stmt.type = NodeStmt.NodeStmtType.assign;
            stmt.assign.type = NodeStmtAssign.NodeStmtAssignType.Array;
            stmt.assign.array = array;
            return stmt;
        }
        NodeStmt? ParseStmt()
        {
            // see what possible statements you have and parse it
            // - declare
            // - assign
            // - if
            // - for
            // - exit

            if (IsStmtDeclare())
            {
                Token vartype = consume();
                if (vartype.Type != TokenType.Int)
                {
                    ErrorExpected("variable type");
                }
                Token ident = consume();
                if (peek(TokenType.OpenSquare).HasValue)
                {
                    return ParseDeclareArray(ident);
                }
                else
                {
                    return ParseDeclareSingleVar(ident);
                }
            }
            else if (IsStmtAssign())
            {
                if (peek(TokenType.OpenSquare, 1).HasValue)
                {
                    return ParseAssignArray();
                }
                else if (peek(TokenType.Equal, 1).HasValue)
                {
                    return ParseAssignSingleVar();
                }
            }
            else if (IsStmtIF())
            {
                consume();
                NodeStmtIF iff = new NodeStmtIF();
                NodeIfPredicate? pred = ParseIfPredicate();
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
            else if (IsStmtFor())
            {
                consume();
                NodeStmtFor forr = new NodeStmtFor();
                NodeForPredicate? pred = ParseForPredicate();
                if (pred.HasValue)
                {
                    forr.pred = pred.Value;
                }
                else
                {
                    return null;
                }
                NodeStmt stmt = new NodeStmt();
                stmt.type = NodeStmt.NodeStmtType.forr;
                stmt.forr = forr;
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