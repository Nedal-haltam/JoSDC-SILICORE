namespace Epsilon
{

    struct NodeIntLit
    {
        Token intlit;
    }
    struct NodeIdent
    {
        Token ident;
    }
    struct NodeTerm
    {
        public enum NodeTermType
        {
            intlit, ident
        }
        public NodeTermType type;
        public NodeIntLit intlit;
        public NodeIdent ident;
    }

    unsafe struct NodeBinExpr // could be (add, sub, and, or, xor, nor, sll, srl)
    {
        public enum NodeBinExprType
        {
            add, sub, and, or, xor, nor, sll, srl
        }
        public NodeBinExprType type;
        public NodeExpr* lhs;
        public NodeExpr* rhs;
    }

    unsafe struct NodeExpr
    {
        public enum NodeExprType
        {
            term, binExpr
        }
        public NodeExprType type;
        public NodeTerm term;
        public NodeBinExpr* expr;
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

    struct NodeStmtAssign
    {
        public Token ident;
        public NodeExpr expr;
    }

    struct NodeStmtDeclare
    {
        public enum VarType
        {
            Reg, Mem
        }
        public VarType type;
        public Token ident;
        public NodeExpr expr;
    }

    struct NodeStmt
    {
        public dynamic var;
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