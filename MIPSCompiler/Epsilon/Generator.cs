using System.Collections.Generic;
using System.Text;
#pragma warning disable CS8500


namespace Epsilon
{
    class Generator
    {
        public NodeProg m_prog;
        StringBuilder m_outputcode = new StringBuilder();
        List<string> m_Vars = new List<string>();
        int StackSize = 0;
        //Dictionary<string, int> m_Vars = new Dictionary<string, int>();
        //int m_VarCount = 0;
        //int m_RegsIndex = 1;
        //Dictionary<string, int> m_RegVars = new Dictionary<string, int>();
        //Dictionary<string, int> m_MemVars = new Dictionary<string, int>();
        public Generator(NodeProg prog)
        {
            m_prog = prog;
        }
        void Error(string msg, int line)
        {
            Console.ForegroundColor = ConsoleColor.Red;
            Console.WriteLine($"Generator: Error: {msg} on line: {line}");
            Console.ResetColor();
            Environment.Exit(1);
        }

        void GenPush(string reg)
        {
            // TODO: check for stack overflow
            m_outputcode.Append($"sw {reg}, x29, 0\n");
            m_outputcode.Append("addi x29, x29, -1\n");
            StackSize++;
        }

        void GenPop(string reg)
        {
            m_outputcode.Append("addi x29, x29, 1\n");
            m_outputcode.Append($"lw {reg}, x29, 0\n");
            //m_Vars.RemoveAt(m_Vars.Count - 1);
            StackSize--;
        }

        void GenTerm(NodeTerm term)
        {
            if (term.type == NodeTerm.NodeTermType.intlit)
            {
                string reg = "x1";
                m_outputcode.Append($"addi {reg}, x0, {term.intlit.intlit.Value}\n");
                GenPush(reg);
            }
            else if (term.type == NodeTerm.NodeTermType.ident)
            {
                if (!m_Vars.Contains(term.ident.ident.Value))
                {
                    Error($"variable {term.ident.ident.Value} is not declared", term.ident.ident.Line);
                }
                string dest_reg = "x1";
                int rel_loc = StackSize - m_Vars.IndexOf(term.ident.ident.Value);
                m_outputcode.Append($"lw {dest_reg}, x29, {rel_loc}\n");
                GenPush(dest_reg);
            }
            else if (term.type == NodeTerm.NodeTermType.paren)
            {
                GenExpr(term.paren.expr);
            }

        }

        void GenBinExpr(NodeBinExpr binExpr)
        {
            string source_reg1 = "x1", source_reg2 = "x2";
            GenExpr(binExpr.rhs);
            GenExpr(binExpr.lhs);
            GenPop(source_reg1);
            GenPop(source_reg2);
            m_outputcode.Append($"{binExpr.type.ToString()} {source_reg1}, {source_reg1}, {source_reg2}\n");
            GenPush(source_reg1);
        }

        void GenExpr(NodeExpr expr)
        {
            if (expr.type == NodeExpr.NodeExprType.term)
            {
                GenTerm(expr.term);
            }
            else if (expr.type == NodeExpr.NodeExprType.binExpr)
            {
                GenBinExpr(expr.binexpr);
            }
        }

        void GenStmtDeclare(NodeStmtDeclare declare)
        {
            Token ident = declare.ident;
            if (m_Vars.Contains(ident.Value))
            {
                Error($"variable {ident.Value} is already declared", ident.Line);
            }
            else
                m_Vars.Add(ident.Value);
            GenExpr(declare.expr);
        }
        void GenStmtAssign(NodeStmtAssign assign)
        {
            Token ident = assign.ident;
            if (!m_Vars.Contains(ident.Value))
            {
                Error($"variable {ident.Value} is not declared", ident.Line);
            }
            GenExpr(assign.expr);
            string reg = "x1";
            GenPop(reg);
            int rel_loc = StackSize - m_Vars.IndexOf(ident.Value);
            m_outputcode.Append($"sw {reg}, x29, {rel_loc}\n");
        }

        void GenStmtReturn(NodeStmtReturn Return)
        {
            GenExpr(Return.expr);
            GenPop("x1");
            m_outputcode.Append("HLT");
        }
        void GenStmt(NodeStmt stmt)
        {
            if (stmt.type == NodeStmt.NodeStmtType.nodestmtdeclare)
            {
                GenStmtDeclare(stmt.declare);
            }
            else if (stmt.type == NodeStmt.NodeStmtType.nodestmtassign)
            {
                GenStmtAssign(stmt.assign);
            }
            else if (stmt.type == NodeStmt.NodeStmtType.Return)
            {
                GenStmtReturn(stmt.Return);
            }
        }

        public string Generate()
        {
            foreach (NodeStmt stmt in m_prog.stmts)
                GenStmt(stmt);


            return m_outputcode.ToString();
        }
    }
}
#pragma warning restore CS8500