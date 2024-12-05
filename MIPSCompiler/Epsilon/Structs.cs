


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
            add = 7, sub, and, or, xor, nor, sll, srl
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

    //struct NodeStmtFor
    //{
    //    public NodeInit init;
    //    public NodeCond cond;
    //    public NodeUpdate udpate;
    //    public NodeScope scope;
    //}

    //struct NodeStmtIf
    //{
    //    public NodeCond cond;
    //    public NodeScope scope;
    //}

    struct NodeStmtExit
    {
        public NodeExpr expr;
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
            nodestmtdeclare, nodestmtassign, Return
        }
        public NodeStmtType type;
        public NodeStmtDeclare declare;
        public NodeStmtAssign assign;
        public NodeStmtExit Exit;
    }
    struct NodeProg
    {
        public List<NodeStmt> stmts;

        public NodeProg()
        {
            stmts = new List<NodeStmt>();
        }
    }


    /*

    NodeStmt: could be one of the following

        NodeStmtDeclare: could be
            StmtReg: is composed of
                identifier
                expression

            StmtMem: is composed of
                identifier
                expression

        StmtAssign: is composed of
            identifier
            expression

        StmtIf: is composed of 
            condition
            scope

        StmtFor: is composed of
            Initialization: could be
                StmtReg
                StmtAssign
            condition
            update: is an
                expression
            scope: is a
                list of statements    



    excpression: could be a 
        intlit, ident, binary expr

    */

}