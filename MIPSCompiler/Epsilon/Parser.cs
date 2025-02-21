#pragma warning disable CS8629 // Nullable value type may be null.




using System.Reflection.Metadata.Ecma335;

namespace Epsilon
{
    class Parser
    {
        private List<Token> m_tokens;
        private int m_curr_index = 0;
        private bool ExitScope = false;
        private Dictionary<string, List<NodeTermIntLit>> m_Arraydims = [];
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
            return peek(TokenType.If).HasValue;
        }
        bool IsStmtFor()
        {
            return peek(TokenType.For).HasValue;
        }
        bool IsStmtWhile()
        {
            return peek(TokenType.While).HasValue;
        }
        bool IsStmtBreak()
        {
            return peek(TokenType.Break).HasValue;
        }
        bool IsStmtContinue()
        {
            return peek(TokenType.Continue).HasValue;
        }
        bool IsFunction()
        {
            return peek(TokenType.FN).HasValue;
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
                   peek(TokenType.Sll).HasValue ||
                   peek(TokenType.Srl).HasValue ||
                   peek(TokenType.EqualEqual).HasValue ||
                   peek(TokenType.NotEqual).HasValue ||
                   peek(TokenType.LessThan).HasValue ||
                   peek(TokenType.GreaterThan).HasValue;
        }

        NodeExpr? parseindex()
        {
            consume();
            NodeExpr? index = ParseExpr();
            if (!index.HasValue)
            {
                ErrorExpected("expression(parseindex)");
            }
            try_consume_err(TokenType.CloseSquare);
            return index;
        }
        NodeTerm? ParseTerm()
        {
            NodeTerm term = new NodeTerm();
            term.Negative = false;
            if (peek(TokenType.Minus).HasValue)
            {
                term.Negative = true;
                consume();
            }
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
                term.ident.index1 = null;
                term.ident.index2 = null;
                if (peek(TokenType.OpenSquare).HasValue)
                    term.ident.index1 = parseindex();
                if (peek(TokenType.OpenSquare).HasValue)
                {
                    term.ident.index2 = parseindex();
                    term.ident.dim1 = m_Arraydims[term.ident.ident.Value][0];
                    term.ident.dim2 = m_Arraydims[term.ident.ident.Value][1];
                }
                return term;
            }
            else if (peek(TokenType.OpenParen).HasValue)
            {
                consume();
                NodeExpr? expr = ParseExpr();
                if (!expr.HasValue)
                {
                    ErrorExpected("expression(parseterm)");
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
                case TokenType.Xor:
                case TokenType.Or:
                case TokenType.And:
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
            if (op == TokenType.And)
                return NodeBinExpr.NodeBinExprType.and;
            if (op == TokenType.Or)
                return NodeBinExpr.NodeBinExprType.or;
            if (op == TokenType.Xor)
                return NodeBinExpr.NodeBinExprType.xor;
            return null;
        }
        bool IsExprIntLit(NodeExpr expr)
        {
            bool IstermIntLit = expr.type == NodeExpr.NodeExprType.term && 
                (
                    expr.term.type == NodeTerm.NodeTermType.intlit || 
                    (expr.term.type == NodeTerm.NodeTermType.paren && expr.term.paren.expr.type == NodeExpr.NodeExprType.term && expr.term.paren.expr.term.type == NodeTerm.NodeTermType.intlit)
                );
            //bool IsBinExprIntLit = expr.type == NodeExpr.NodeExprType.binExpr &&
            //    (
            //        //expr.binexpr.type == NodeBinExpr.NodeBinExprType.
            //    )
            return IstermIntLit;
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
                    Token Operator = consume();
                    int next_min_prec = prec.Value + 1;
                    NodeExpr? expr_rhs = ParseExpr(next_min_prec);
                    if (!expr_rhs.HasValue)
                    {
                        ErrorExpected("expression(parseexpr)");
                    }
                    NodeBinExpr expr = new NodeBinExpr();
                    NodeExpr expr_lhs2 = new NodeExpr();
                    expr_lhs2 = exprlhs;
                    NodeBinExpr.NodeBinExprType? optype = GetOpType(Operator.Type);
                    if (optype.HasValue)
                        expr.type = optype.Value;
                    else
                        return null;
                    expr.lhs = expr_lhs2;
                    expr.rhs = expr_rhs.Value;

                    if (IsExprIntLit(expr.lhs) && IsExprIntLit(expr.rhs))
                    {
                        string constant1, constant2;
                        if (expr.lhs.term.type == NodeTerm.NodeTermType.intlit)
                        {
                            constant1 = expr.lhs.term.intlit.intlit.Value;
                        }
                        else
                        {
                            constant1 = expr.lhs.term.paren.expr.term.intlit.intlit.Value;
                        }
                        if (expr.rhs.term.type == NodeTerm.NodeTermType.intlit)
                        {
                            constant2 = expr.rhs.term.intlit.intlit.Value;
                        }
                        else
                        {
                            constant2 = expr.rhs.term.paren.expr.term.intlit.intlit.Value;
                        }
                        string? value = Generator.GetImmedOperation(constant1, constant2, expr.type);
                        if (value == null)
                            return null;
                        NodeTerm term = new();
                        term.type = NodeTerm.NodeTermType.intlit;
                        term.intlit.intlit.Value = value;
                        term.intlit.intlit.Type = TokenType.IntLit;
                        term.intlit.intlit.Line = expr.lhs.term.intlit.intlit.Line;
                        exprlhs.type = NodeExpr.NodeExprType.term;
                        exprlhs.term = term;
                    }
                    else
                    {
                        exprlhs.type = NodeExpr.NodeExprType.binExpr;
                        exprlhs.binexpr = expr;
                    }
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
                    NodeStmt? stmt;
                    if (ExitScope)
                    {
                        stmt = ParseStmt();
                        if (!stmt.HasValue)
                            return null;
                        continue;
                    }
                    stmt = ParseStmt();
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
                ExitScope = false;
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
                        ErrorExpected("expression(parseforinit)");
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
                    ErrorExpected("expression(parseforinit2)");
                }
                try_consume_err(TokenType.SemiColon);
                NodeForInit forinit = new NodeForInit();
                forinit.type = NodeForInit.NodeForInitType.assign;
                forinit.assign.type = NodeStmtAssign.NodeStmtAssignType.SingleVar;
                forinit.assign.singlevar = singlevar;
                return forinit;
            }
            try_consume_err(TokenType.SemiColon);
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
        NodeExpr? ParseWhileCond()
        {
            try_consume_err(TokenType.OpenParen);
            NodeExpr? cond = ParseExpr();
            if (cond.HasValue)
            {
                try_consume_err(TokenType.CloseParen);
                return cond.Value;
            }
            else
            {
                ErrorExpected("expression(parsestmtwhile)");
                return null;
            }
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
                    ErrorExpected("expression(parsestmtupdate)");
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
                    ErrorExpected("expression(parsedeclaresinglevar)");
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
        Token parsedimension()
        {
            consume();
            Token size_token = consume();
            if (!uint.TryParse(size_token.Value, out uint _))
            {
                ErrorExpected("a constant size for the array");
            }
            try_consume_err(TokenType.CloseSquare);
            return size_token;
        }
        List<NodeExpr> ParseArrayInit(int dim)
        {
            List<NodeExpr> values = [];
            try_consume_err(TokenType.OpenCurly);
            for (int i = 0; i < dim; i++)
            {
                NodeExpr? expr = ParseExpr();
                if (!expr.HasValue)
                    ErrorExpected("expression(parsearrayinit)");
                values.Add(expr.Value);
                if (peek(TokenType.CloseCurly).HasValue)
                {
                    consume();
                    break;
                }
                try_consume_err(TokenType.Comma);
            }
            return values;
        }
        List<NodeExpr> ParseArrayInit1D(int dim)
        {
            List<NodeExpr> values = [];
            values = ParseArrayInit(dim);
            if (values.Count != dim)
            {
                ErrorExpected("dimensions are not aligned");
            }
            return values;
        }
        List<List<NodeExpr>> ParseArrayInit2D(int dim1, int dim2)
        {
            List<List<NodeExpr>> values = [];
            try_consume_err(TokenType.OpenCurly);
            for (int i = 0; i < dim1; i++)
            {
                values.Add(ParseArrayInit1D(dim2));
                if (peek(TokenType.CloseCurly).HasValue)
                {
                    consume();
                    break;
                }
                try_consume_err(TokenType.Comma);
            }
            if (values.Count != dim1)
            {
                ErrorExpected("dimensions are not aligned");
            }
            return values;
        }
        NodeStmt? ParseDeclareArray(Token ident)
        {
            NodeStmtDeclareArray declare = new();
            declare.ident = ident;
            declare.values1 = [];
            declare.values2 = [];
            if (peek(TokenType.OpenSquare).HasValue)
            {
                Token dim = parsedimension();
                declare.dim1 = new() { intlit = dim };
            }
            if (peek(TokenType.OpenSquare).HasValue)
            {
                Token dim = parsedimension();
                declare.dim2 = new() { intlit = dim };
                m_Arraydims.Add(ident.Value, [declare.dim1, declare.dim2.Value]);
            }

            int dim1 = Convert.ToInt32(declare.dim1.intlit.Value);
            if (peek(TokenType.Equal).HasValue)
            {
                consume();
                if (declare.dim2.HasValue)
                {
                    int dim2 = Convert.ToInt32(declare.dim2.Value.intlit.Value);
                    declare.values2 = ParseArrayInit2D(dim1, dim2);
                }
                else
                    declare.values1 = ParseArrayInit1D(dim1);
            }

            try_consume_err(TokenType.SemiColon);
            NodeStmt stmt = new();
            stmt.type = NodeStmt.NodeStmtType.declare;
            stmt.declare.type = NodeStmtDeclare.NodeStmtDeclareType.Array;
            stmt.declare.array = declare;
            return stmt;
        }
        NodeStmt? ParseAssignSingleVar(Token ident)
        {
            NodeStmtAssignSingleVar singlevar = new();
            singlevar.ident = ident;
            consume();
            NodeExpr? expr = ParseExpr();
            if (expr.HasValue)
            {
                singlevar.expr = expr.Value;
            }
            else
            {
                ErrorExpected("expression(parseassignsinglevar)");
            }
            try_consume_err(TokenType.SemiColon);
            NodeStmt stmt = new NodeStmt();
            stmt.type = NodeStmt.NodeStmtType.assign;
            stmt.assign.type = NodeStmtAssign.NodeStmtAssignType.SingleVar;
            stmt.assign.singlevar = singlevar;
            return stmt;
        }
        NodeStmt? ParseAssignArray(Token ident)
        {
            NodeStmtAssignArray array = new();
            array.ident = ident;
            if (peek(TokenType.OpenSquare).HasValue)
            {
                array.index1 = parseindex().Value;
            }

            if (peek(TokenType.OpenSquare).HasValue)
            {
                array.index2 = parseindex().Value;
                if (!m_Arraydims.ContainsKey(array.ident.Value))
                {
                    ErrorExpected($"undeclared identifier : {array.ident.Value}");
                }
                array.dim1 = m_Arraydims[array.ident.Value][0];
                array.dim2 = m_Arraydims[array.ident.Value][1];
            }

            try_consume_err(TokenType.Equal);
            NodeExpr? expr = ParseExpr();
            if (expr.HasValue)
            {
                array.expr = expr.Value;
            }
            else
            {
                ErrorExpected("expression(parseassignarray)");
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
            // should be before the StmtAssign condition because it is considered an identifier
            else if (peek(TokenType.Ident).HasValue && peek(TokenType.Ident).Value.Value == "cleanstack" && peek(TokenType.SemiColon, 1).HasValue)
            {
                consume();
                consume();
                NodeStmtCleanStack cs = new();
                NodeStmt stmt = new();
                stmt.type = NodeStmt.NodeStmtType.CleanSack;
                stmt.CleanStack = cs;
                return stmt;
            }
            else if (IsStmtAssign())
            {
                Token ident = consume();
                if (peek(TokenType.OpenSquare).HasValue)
                {
                    return ParseAssignArray(ident);
                }
                else if (peek(TokenType.Equal).HasValue)
                {
                    return ParseAssignSingleVar(ident);
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
                stmt.type = NodeStmt.NodeStmtType.If;
                stmt.If = iff;
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
                stmt.type = NodeStmt.NodeStmtType.For;
                stmt.For = forr;
                return stmt;
            }
            else if (IsStmtWhile())
            {
                consume();
                NodeExpr? expr = ParseWhileCond();
                NodeStmtWhile whilee = new();
                whilee.cond = expr.Value;
                NodeScope? scope = ParseScope();
                if (scope.HasValue)
                {
                    whilee.scope = scope.Value;
                    NodeStmt stmt = new();
                    stmt.type = NodeStmt.NodeStmtType.While;
                    stmt.While = whilee;
                    return stmt;
                }
                else
                {
                    ErrorExpected("scope");
                }
            }
            else if (IsStmtBreak())
            {
                Token word = consume();
                try_consume_err(TokenType.SemiColon);
                NodeStmtBreak breakk = new();
                breakk.breakk = word;
                NodeStmt stmt = new();
                stmt.type = NodeStmt.NodeStmtType.Break;
                stmt.Break = breakk;
                return stmt;
            }
            else if (IsStmtContinue())
            {
                Token word = consume();
                try_consume_err(TokenType.SemiColon);
                NodeStmtContinuee continuee = new();
                continuee.continuee = word;
                NodeStmt stmt = new();
                stmt.type = NodeStmt.NodeStmtType.Continue;
                stmt.Continue = continuee;
                return stmt;
            }
            else if (IsFunction())
            {
                throw new NotImplementedException();
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
                    ErrorExpected("expression(parsestmtexit)");
                }
                try_consume_err(TokenType.CloseParen);
                try_consume_err(TokenType.SemiColon);
                NodeStmt stmt = new NodeStmt();
                stmt.type = NodeStmt.NodeStmtType.Exit;
                stmt.Exit = Return;
                ExitScope = true;
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
                {
                    prog.scope.stmts.Add(stmt.Value);
                    if (ExitScope)
                    {
                        ExitScope = false;
                        break;
                    }
                }
                else
                    ErrorExpected($"statement");
            }
            return prog;
        }
    }
}
#pragma warning restore CS8629 // Nullable value type may be null.