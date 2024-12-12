using System.Collections.Generic;
using System.Text;
#pragma warning disable CS8500


namespace Epsilon
{
    class Generator
    {
        public NodeProg m_prog;
        StringBuilder m_outputcode = new StringBuilder();
        List<string> m_vars = new List<string>();
        List<string> m_labels = new List<string>();
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
            m_outputcode.Append($"SW {reg}, $sp, 0\n");
            m_outputcode.Append("ADDI $sp, $sp, -1\n");
            StackSize++;
        }

        void GenPop(string reg)
        {
            m_outputcode.Append("ADDI $sp, $sp, 1\n");
            m_outputcode.Append($"LW {reg}, $sp, 0\n");
            //m_Vars.RemoveAt(m_Vars.Count - 1);
            StackSize--;
        }

        void GenScope(NodeScope scope)
        {
            foreach (NodeStmt stmt in scope.stmts)
            {
                GenStmt(stmt);
            }
        }

        void GenTerm(NodeTerm term)
        {
            if (term.type == NodeTerm.NodeTermType.intlit)
            {
                string reg = "$1";
                m_outputcode.Append($"ADDI {reg}, $zero, {term.intlit.intlit.Value}\n");
                GenPush(reg);
            }
            else if (term.type == NodeTerm.NodeTermType.ident)
            {
                if (!m_vars.Contains(term.ident.ident.Value))
                {
                    Error($"variable {term.ident.ident.Value} is not declared", term.ident.ident.Line);
                }
                string dest_reg = "$1";
                int rel_loc = StackSize - m_vars.IndexOf(term.ident.ident.Value);
                m_outputcode.Append($"LW {dest_reg}, $sp, {rel_loc}\n");
                GenPush(dest_reg);
            }
            else if (term.type == NodeTerm.NodeTermType.paren)
            {
                GenExpr(term.paren.expr);
            }

        }

        void GenBinExpr(NodeBinExpr binExpr)
        {
            string source_reg1 = "$1", source_reg2 = "$2";
            GenExpr(binExpr.rhs);
            GenExpr(binExpr.lhs);
            GenPop(source_reg1);
            GenPop(source_reg2);
            if (binExpr.type == NodeBinExpr.NodeBinExprType.equalequal)
            {
                string new_label_start = $"TEMP_LABEL{m_labels.Count}_START";
                string new_label_else = $"TEMP_LABEL{m_labels.Count}_ELSE";
                string new_label_end = $"TEMP_LABEL{m_labels.Count}_END";
                m_labels.Add(new_label_start);
                m_labels.Add(new_label_else);
                m_labels.Add(new_label_end);
                // TODO: optimize the comparison by adding seq, sneq instructions
                m_outputcode.Append($"{new_label_start}:\n");
                m_outputcode.Append($"SUB {source_reg1}, {source_reg1}, {source_reg2}\n");
                m_outputcode.Append($"BEQ {source_reg1}, $zero, {new_label_else}\n");
                m_outputcode.Append($"ADDI {source_reg1}, $zero, 0\n");
                m_outputcode.Append($"J {new_label_end}\n");
                m_outputcode.Append($"{new_label_else}:\n");
                m_outputcode.Append($"ADDI {source_reg1}, $zero, 1\n");
                m_outputcode.Append($"{new_label_end}:\n");
                GenPush(source_reg1);
            }
            else if (binExpr.type == NodeBinExpr.NodeBinExprType.notequal)
            {
                string new_label_start = $"TEMP_LABEL{m_labels.Count}_START";
                string new_label_else = $"TEMP_LABEL{m_labels.Count}_ELSE";
                string new_label_end = $"TEMP_LABEL{m_labels.Count}_END";
                m_labels.Add(new_label_start);
                m_labels.Add(new_label_else);
                m_labels.Add(new_label_end);
                // TODO: optimize the comparison by adding seq, sneq instructions
                m_outputcode.Append($"{new_label_start}:\n");
                m_outputcode.Append($"SUB {source_reg1}, {source_reg1}, {source_reg2}\n");
                m_outputcode.Append($"BEQ {source_reg1}, $zero, {new_label_else}\n");
                m_outputcode.Append($"ADDI {source_reg1}, $zero, 1\n");
                m_outputcode.Append($"J {new_label_end}\n");
                m_outputcode.Append($"{new_label_else}:\n");
                m_outputcode.Append($"ADDI {source_reg1}, $zero, 0\n");
                m_outputcode.Append($"{new_label_end}:\n");
                GenPush(source_reg1);
            }
            else
            {
                m_outputcode.Append($"{binExpr.type.ToString()} {source_reg1}, {source_reg1}, {source_reg2}\n");
                GenPush(source_reg1);
            }
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
            if (m_vars.Contains(ident.Value))
            {
                Error($"variable {ident.Value} is already declared", ident.Line);
            }
            else
                m_vars.Add(ident.Value);
            GenExpr(declare.expr);
        }
        void GenStmtAssign(NodeStmtAssign assign)
        {
            Token ident = assign.ident;
            if (!m_vars.Contains(ident.Value))
            {
                Error($"variable {ident.Value} is not declared", ident.Line);
            }
            GenExpr(assign.expr);
            string reg = "$1";
            GenPop(reg);
            int relative_location = StackSize - m_vars.IndexOf(ident.Value);
            m_outputcode.Append($"SW {reg}, $sp, {relative_location}\n");
        }
        void GenStmtIF(NodeStmtIF iff)
        {
            string new_label_start = $"LABEL{m_labels.Count}_START";
            string new_label_end = $"LABEL{m_labels.Count}_END";
            m_labels.Add(new_label_start);
            m_labels.Add(new_label_end);

            m_outputcode.Append($"{new_label_start}:\n");
            GenExpr(iff.cond.expr);
            string reg = "$1";
            GenPop(reg);
            m_outputcode.Append($"beq $1, $zero, {new_label_end}\n");
            GenScope(iff.scope);
            m_outputcode.Append($"{new_label_end}:\n");
        }
        void GenStmtExit(NodeStmtExit exit)
        {
            GenExpr(exit.expr);
            GenPop("$1");
            m_outputcode.Append("HLT");
        }
        void GenStmt(NodeStmt stmt)
        {
            if (stmt.type == NodeStmt.NodeStmtType.declare)
            {
                GenStmtDeclare(stmt.declare);
            }
            else if (stmt.type == NodeStmt.NodeStmtType.assign)
            {
                GenStmtAssign(stmt.assign);
            }
            else if (stmt.type == NodeStmt.NodeStmtType.iff)
            {
                GenStmtIF(stmt.iff);
            }
            else if (stmt.type == NodeStmt.NodeStmtType.Exit)
            {
                GenStmtExit(stmt.Exit);
            }
        }

        public StringBuilder GenProg()
        {
            m_outputcode.Append(".text\nmain:\n");
            m_outputcode.Append("ADDI $sp, $zero, 20\n");
            foreach (NodeStmt stmt in m_prog.scope.stmts)
                GenStmt(stmt);

            return m_outputcode;
        }
    }
}
#pragma warning restore CS8500

/*
if (cond)
if (x) -> (x != 0)
if (x == 123)
if (x != 123)


bne x, 0, LABEL1



LABEL1:

*/