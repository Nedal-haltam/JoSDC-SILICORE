


using System.Runtime.InteropServices;

namespace Epsilon
{

    struct NodeTermIntLit
    {
        public Token intlit;
    }
    struct NodeTermIdent
    {
        public Token ident;
    }
    class NodeTermParen
    {
        public NodeExpr expr;
    }
    struct NodeTerm
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

    class NodeBinExpr // could be (add, sub, and, or, xor, nor, sll, srl)
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

    struct NodeExpr
    {
        public enum NodeExprType
        {
            term, binExpr
        }
        public NodeExprType type;
        public NodeTerm term;
        public NodeBinExpr binexpr;
    }


    struct NodeStmtExit
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
    struct NodeCond
    {
        public NodeExpr expr;
    }
    struct NodeScope
    {
        public List<NodeStmt> stmts;
        public NodeScope()
        {
            stmts = [];
        }
    }

    struct NodeStmtIF
    {
        public NodeCond cond;
        public NodeScope scope;
        public NodeStmtIF()
        {
            cond = new NodeCond();
            scope = new NodeScope();
        }

    }

    struct NodeStmtAssign
    {
        public Token ident;
        public NodeExpr expr;
    }

    struct NodeStmtDeclare
    {
        public enum NodeStmtDeclareType
        {
            Int
        }
        public NodeStmtDeclareType type;
        public Token ident;
        public NodeExpr expr;
    }

    struct NodeStmt
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
    struct NodeProg
    {
        public NodeScope scope;
        public NodeProg()
        {
            scope = new();
        }
    }
}