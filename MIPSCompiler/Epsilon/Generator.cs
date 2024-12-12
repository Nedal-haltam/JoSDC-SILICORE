using System.Collections.Generic;
using System.Security.Cryptography;
using System.Text;
#pragma warning disable CS8500


namespace Epsilon
{
    class Generator
    {
        public NodeProg m_prog;
        StringBuilder m_outputcode = new StringBuilder();
        List<string> m_vars = new List<string>();
        int m_labels_count = 0;
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
            // TODO: add scope boundaries for variables
            // beginscope
            foreach (NodeStmt stmt in scope.stmts)
            {
                GenStmt(stmt);
            }
            // endscope
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
                string new_label_start = $"TEMP_LABEL{m_labels_count++}_START";
                string new_label_else = $"TEMP_LABEL{m_labels_count++}_ELSE";
                string new_label_end = $"TEMP_LABEL{m_labels_count++}_END";
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
                string new_label_start = $"TEMP_LABEL{m_labels_count++}_START";
                string new_label_else = $"TEMP_LABEL{m_labels_count++}_ELSE";
                string new_label_end = $"TEMP_LABEL{m_labels_count++}_END";
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
        void GenElifs(NodeIfElifs elifs, string label_end)
        {
            if (elifs.type == NodeIfElifs.NodeIfElifsType.elif)
            {
                string label = $"LABEL{m_labels_count++}_elifs";
                GenExpr(elifs.elif.pred.cond);
                string reg = "$1";
                GenPop(reg);
                m_outputcode.Append($"beq $1, $zero, {label}\n");
                GenScope(elifs.elif.pred.scope);
                m_outputcode.Append($"J {label_end}\n");
                if (elifs.elif.elifs.HasValue)
                {
                    m_outputcode.Append($"J {label_end}\n");
                    m_outputcode.Append($"{label}:\n");
                    GenElifs(elifs.elif.elifs.Value, label_end);
                }
                else
                {
                    m_outputcode.Append($"{label}:\n");
                }
            }
            else if (elifs.type == NodeIfElifs.NodeIfElifsType.elsee)
            {
                GenScope(elifs.elsee.scope);
            }
            else
            {
                Error("UNREACHABLE", -1);
            }
        }
        void GenStmtIF(NodeStmtIF iff)
        {
            string label_end = $"LABEL{m_labels_count++}_END";

            string label = $"LABEL{m_labels_count++}_elifs";
            GenExpr(iff.pred.cond);
            string reg = "$1";
            GenPop(reg);
            m_outputcode.Append($"beq $1, $zero, {label}\n");
            GenScope(iff.pred.scope);
            if (iff.elifs.HasValue)
            {
                m_outputcode.Append($"J {label_end}\n");
                m_outputcode.Append($"{label}:\n");
                GenElifs(iff.elifs.Value, label_end);
            }
            else
            {
                m_outputcode.Append($"{label}:\n");
            }
            m_outputcode.Append($"{label_end}:\n");
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