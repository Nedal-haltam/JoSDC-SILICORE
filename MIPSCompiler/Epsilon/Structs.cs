


using System.Runtime.InteropServices;

namespace Epsilon
{

    public struct NodeTermIntLit
    {
        public Token intlit;
    }
    public struct NodeTermIdent
    {
        public Token ident;
    }
    public class NodeTermParen
    {
        public NodeExpr expr;
    }
    public struct NodeTerm
    {
        public enum NodeTermType
        {
            intlit, ident, paren
        }
        public NodeTermType type;
        public NodeTermIntLit intlit;
        public NodeTermIdent ident;
        public NodeTermParen paren;
    }

    public class NodeBinExpr // could be (add, sub, and, or, xor, nor, sll, srl)
    {
        public enum NodeBinExprType
        {
            add = 7, sub, and, or, xor, nor, sll, srl, equalequal, notequal
        }
        public NodeBinExprType type;
        public NodeExpr lhs;
        public NodeExpr rhs;

        public NodeBinExpr()
        {
        }
    }

    public struct NodeExpr
    {
        public enum NodeExprType
        {
            term, binExpr
        }
        public NodeExprType type;
        public NodeTerm term;
        public NodeBinExpr binexpr;
    }


    public struct NodeStmtExit
    {
        public NodeExpr expr;
    }

    //struct NodeStmtFor
    //{
    //    public NodeInit init;
    //    public NodeCond cond;
    //    public NodeUpdate udpate;
    //    public NodeScope scope;
    //}
    public struct NodeScope
    {
        public List<NodeStmt> stmts;
        public NodeScope()
        {
            stmts = [];
        }
    }
    public struct NodeIfPredicate
    {
        public NodeExpr cond;
        public NodeScope scope;
    }
    public class NodeElif
    {
        public NodeIfPredicate pred;
        public NodeIfElifs? elifs;
    }
    public struct NodeElse
    {
        public NodeScope scope;
    }

    public struct NodeIfElifs
    {
        public enum NodeIfElifsType
        {
            elif, elsee
        }
        public NodeIfElifsType type;
        public NodeElif elif;
        public NodeElse elsee;
        public NodeIfElifs()
        {
            type = NodeIfElifsType.elsee;
            elif = new NodeElif();
            elsee = new NodeElse();
        }
    }

    public class NodeStmtIF
    {
        public NodeIfPredicate pred;
        public NodeIfElifs? elifs;
        public NodeStmtIF()
        {
            pred = new NodeIfPredicate();
            elifs = null;
        }
    }

    public struct NodeStmtAssign
    {
        public Token ident;
        public NodeExpr expr;
    }

    public struct NodeStmtDeclare
    {
        public enum NodeStmtDeclareType
        {
            Int
        }
        public NodeStmtDeclareType type;
        public Token ident;
        public NodeExpr expr;
    }

    public struct NodeStmt
    {
        public enum NodeStmtType
        {
            declare, assign, iff, Exit
        }
        public NodeStmtType type;
        public NodeStmtDeclare declare;
        public NodeStmtAssign assign;
        public NodeStmtIF iff;
        public NodeStmtExit Exit;
    }
    public struct NodeProg
    {
        public NodeScope scope;
        public NodeProg()
        {
            scope = new();
        }
    }
}