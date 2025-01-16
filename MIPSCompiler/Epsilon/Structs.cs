


using System.Runtime.InteropServices;

namespace Epsilon
{

    public struct NodeTermIntLit
    {
        public Token intlit;
    }
    public class NodeTermIdent
    {
        // TODO: add a term corresponds to an array element 
        public Token ident;
        public NodeExpr? index;
        public NodeTermIdent()
        {
            index = null;
        }
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

    public class NodeBinExpr 
    {
        public enum NodeBinExprType
        {
            add, sub, sll, srl, equalequal, notequal, lessthan, greaterthan
        }
        public NodeBinExprType type;
        public NodeExpr lhs;
        public NodeExpr rhs;
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
    public struct NodeStmtAssignSingleVar
    {
        public Token ident;
        public NodeExpr expr;
    }
    public struct NodeStmtAssignArray
    {
        public Token ident;
        public NodeExpr index;
        public NodeExpr expr;
    }
    public struct NodeStmtAssign
    {
        public enum NodeStmtAssignType
        {
            SingleVar, Array
        }
        public NodeStmtAssignType type;
        public NodeStmtAssignSingleVar singlevar;
        public NodeStmtAssignArray array;
    }
    public struct NodeStmtDeclareSingleVar
    {
        public Token ident;
        public NodeExpr expr;
    }
    public struct NodeStmtDeclareArray
    {
        public Token ident;
        public List<NodeStmtDeclareSingleVar> values;
    }

    public struct NodeStmtDeclare
    {
        public enum NodeStmtDeclareType
        {
            SingleVar, Array
        }
        public NodeStmtDeclareType type;
        public NodeStmtDeclareSingleVar singlevar;
        public NodeStmtDeclareArray array;

    }
    public struct NodeForInit
    {
        public enum NodeForInitType
        {
            declare, assign
        }
        public NodeForInitType type;
        public NodeStmtDeclare declare;
        public NodeStmtAssign assign;
    }
    public struct NodeForCond
    {
        public NodeExpr cond;
    }
    public struct NodeForUpdate
    {
        public List<NodeStmtAssign> udpates;
    }
    public struct NodeForPredicate
    {
        public NodeForInit? init;
        public NodeForCond? cond;
        public NodeForUpdate? udpate;
        public NodeScope scope;
    }
    public struct NodeStmtFor
    {
        public NodeForPredicate pred;
    }
    public struct NodeStmt
    {
        public enum NodeStmtType
        {
            declare, assign, iff, forr, Exit
        }
        public NodeStmtType type;
        public NodeStmtDeclare declare;
        public NodeStmtAssign assign;
        public NodeStmtIF iff;
        public NodeStmtFor forr;
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