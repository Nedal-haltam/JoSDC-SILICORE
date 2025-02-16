

using System.Collections.Generic;
using System.Data;
using System.Security.Cryptography;
using System.Text;
using System.Text.RegularExpressions;
using static System.Formats.Asn1.AsnWriter;




namespace Epsilon
{
    class Optimizer
    {
        private NodeProg m_prog;
        public Optimizer(NodeProg prog)
        {
            m_prog = prog;
        }
        private Token? GetIdent(NodeStmt stmt)
        {
            if (stmt.type == NodeStmt.NodeStmtType.declare)
            {
                if (stmt.declare.type == NodeStmtDeclare.NodeStmtDeclareType.SingleVar)
                    return stmt.declare.singlevar.ident;
                else
                    return stmt.declare.array.ident;
            }
            else if (stmt.type == NodeStmt.NodeStmtType.assign)
            {
                if (stmt.assign.type == NodeStmtAssign.NodeStmtAssignType.SingleVar)
                    return stmt.assign.singlevar.ident;
                else
                    return stmt.assign.array.ident;
            }
            return null;
        }
        private bool IsUsedInExpression(Token ident, NodeExpr expr)
        {
            if (expr.type == NodeExpr.NodeExprType.term)
            {
                if (expr.term.type == NodeTerm.NodeTermType.ident)
                {
                    return expr.term.ident.ident.Value == ident.Value;
                }
                else if (expr.term.type == NodeTerm.NodeTermType.paren)
                {
                    return IsUsedInExpression(ident, expr.term.paren.expr);
                }
                return false;
            }
            else if (expr.type == NodeExpr.NodeExprType.binExpr)
            {
                return IsUsedInExpression(ident, expr.binexpr.lhs) || IsUsedInExpression(ident, expr.binexpr.rhs);
            }
            else
            {
                throw new Exception("UNREACHABLE");
            }
        }
        private bool IsUsedInScope(Token ident, NodeScope scope)
        {
            for (int i = 0; i < scope.stmts.Count; i++)
            {
                if (IsUsedInStmt(ident, scope.stmts[i]))
                    return true;
            }
            return false;
        }
        private bool IsUsedInExpressionArrayDeclare(Token ident, NodeStmtDeclareArray array)
        {
            if (array.dim2.HasValue)
            {
                for (int i = 0; i < array.values2.Count; i++)
                {
                    for (int j = 0; j < array.values2[0].Count; j++)
                    {
                        if (IsUsedInExpression(ident, array.values2[i][j]))
                            return true;
                    }
                }
                return false;
            }
            else
            {
                for (int i = 0; i < array.values1.Count; i++)
                {
                    if (IsUsedInExpression(ident, array.values1[i]))
                        return true;
                }
                return false;
            }
        }
        private bool IsUsedInIfStmt(Token ident, NodeStmtIF If)
        {
            if (IsUsedInExpression(ident, If.pred.cond))
                return true;
            if (IsUsedInScope(ident, If.pred.scope))
                return true;
            if (If.elifs.HasValue)
            {
                if (If.elifs.Value.type == NodeIfElifs.NodeIfElifsType.elif)
                {
                    return IsUsedInIfStmt(ident, new() { pred = If.elifs.Value.elif.pred, elifs = If.elifs.Value.elif.elifs });
                }
                else if (If.elifs.Value.type == NodeIfElifs.NodeIfElifsType.elsee)
                {
                    return IsUsedInScope(ident, If.elifs.Value.elsee.scope);
                }
                throw new Exception("UNREACHABLE");
            }
            return false;
        }
        private bool IsUsedInStmt(Token ident, NodeStmt DestStmt)
        {
            if (DestStmt.type == NodeStmt.NodeStmtType.declare)
            {
                if (DestStmt.declare.type == NodeStmtDeclare.NodeStmtDeclareType.SingleVar)
                    return IsUsedInExpression(ident, DestStmt.declare.singlevar.expr);
                else
                    return IsUsedInExpressionArrayDeclare(ident, DestStmt.declare.array);
            }
            else if (DestStmt.type == NodeStmt.NodeStmtType.assign)
            {
                if (DestStmt.assign.type == NodeStmtAssign.NodeStmtAssignType.SingleVar)
                    return IsUsedInExpression(ident, DestStmt.assign.singlevar.expr);
                else
                    return IsUsedInExpression(ident, DestStmt.assign.array.expr);
            }
            else if (DestStmt.type == NodeStmt.NodeStmtType.If)
            {
                return IsUsedInIfStmt(ident, DestStmt.If);
            }
            else if (DestStmt.type == NodeStmt.NodeStmtType.For)
            {

            }
            else if (DestStmt.type == NodeStmt.NodeStmtType.While)
            {

            }
            else if (DestStmt.type == NodeStmt.NodeStmtType.Exit)
            {
                return IsUsedInExpression(ident, DestStmt.Exit.expr);
            }
            return false;
        }
        public NodeStmt? OptimizeDeclareAssign(NodeStmt stmt, NodeScope scope, int StartIndex)
        {
            Token? ident = GetIdent(stmt);
            if (!ident.HasValue)
                throw new Exception($"{stmt.type.ToString()} is not a declare or assign statement type");
            for (int j = StartIndex + 1; j < scope.stmts.Count; j++)
            {
                NodeStmt CurrentStmt2 = scope.stmts[j];
                if (IsUsedInStmt(ident.Value, CurrentStmt2))
                    return stmt;
            }
            return null;
        }
        public NodeIfElifs OptimizeElifsElse(NodeIfElifs elifs)
        {
            if (elifs.type == NodeIfElifs.NodeIfElifsType.elif)
            {
                elifs.elif.pred.scope = OptimizeScope(elifs.elif.pred.scope);
                if (elifs.elif.elifs.HasValue)
                    elifs.elif.elifs = OptimizeElifsElse(elifs.elif.elifs.Value);
            }
            else if (elifs.type == NodeIfElifs.NodeIfElifsType.elsee)
            {
                NodeIfElifs temp = new();
                temp.type = NodeIfElifs.NodeIfElifsType.elsee;
                temp.elsee = new() { scope = OptimizeScope(elifs.elsee.scope) };
                return temp;
            }
            throw new Exception("UNREACHABLE");
        }
        public NodeStmt? OptimizeIf(NodeStmt stmt)
        {
            stmt.If.pred.scope = OptimizeScope(stmt.If.pred.scope);
            if (stmt.If.elifs.HasValue)
                stmt.If.elifs = OptimizeElifsElse(stmt.If.elifs.Value);
            return stmt;
        }
        public NodeScope OptimizeScope(NodeScope scope)
        {
            NodeScope OptimizedScope = new();
            OptimizedScope.stmts = [];
            for (int i = 0; i < scope.stmts.Count; i++)
            {
                NodeStmt CurrentStmt = scope.stmts[i];
                if (CurrentStmt.type == NodeStmt.NodeStmtType.declare || CurrentStmt.type == NodeStmt.NodeStmtType.assign)
                {
                    NodeStmt? ret = OptimizeDeclareAssign(CurrentStmt, scope, i);
                    if (ret.HasValue)
                        OptimizedScope.stmts.Add(ret.Value);
                }
                else if (CurrentStmt.type == NodeStmt.NodeStmtType.If)
                {
                    NodeStmt? ret = OptimizeIf(CurrentStmt);
                }
                else if (CurrentStmt.type == NodeStmt.NodeStmtType.For)
                {

                }
                else if (CurrentStmt.type == NodeStmt.NodeStmtType.While)
                {

                }
                else
                {
                    OptimizedScope.stmts.Add(CurrentStmt);
                }
            }
            return OptimizedScope;
        }
        public NodeProg OptimizeProg()
        {
            NodeProg OptimizedProgram = new NodeProg();
            OptimizedProgram.scope = OptimizeScope(m_prog.scope);
            return OptimizedProgram;
        }
    }
    internal class Program
    {
        static void Main()
        {
            string inputcode = File.ReadAllText("./input.e");

            Tokenizer tokenizer = new(inputcode);
            List<Token> TokenizedProgram = tokenizer.Tokenize(); // tokenized program

            Parser parser = new(TokenizedProgram);
            NodeProg ParsedProgram  = parser.ParseProg(); // parsed program

            Optimizer optimizer = new(ParsedProgram);
            NodeProg OptimizedProgram = optimizer.OptimizeProg();

            Generator generator = new(OptimizedProgram);
            StringBuilder GeneratedProgram = generator.GenProg();

            File.WriteAllText("./output.mips", GeneratedProgram.ToString());
        }
    }
}
