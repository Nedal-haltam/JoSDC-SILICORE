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
        List<int> m_scopes = new List<int>();
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
        void BeginScope()
        {
            m_outputcode.Append("# begin scope\n");
            m_scopes.Add(m_vars.Count);
        }
        void EndScope()
        {
            m_outputcode.Append("# end scope\n");
            int popcount = m_vars.Count - m_scopes[^1];
            m_outputcode.Append($"ADDi $sp, $sp, {popcount}\n");
            StackSize -= popcount;
            m_vars.RemoveRange(m_vars.Count - popcount, popcount);
            m_scopes.RemoveAt(m_scopes.Count - 1);
        }
        void GenScope(NodeScope scope)
        {
            BeginScope();
            foreach (NodeStmt stmt in scope.stmts)
            {
                GenStmt(stmt);
            }
            EndScope();
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
            // TODO: add an instruction to ISA to enable us to evaluate (`==`, `!=`), like the (seq, sneq)
            if (binExpr.type == NodeBinExpr.NodeBinExprType.add)
            {
                string source_reg1 = "$1", source_reg2 = "$2";
                GenExpr(binExpr.rhs);
                GenExpr(binExpr.lhs);
                GenPop(source_reg1);
                GenPop(source_reg2);
                m_outputcode.Append($"ADD {source_reg1}, {source_reg1}, {source_reg2}\n");
                GenPush(source_reg1);
            }
            else if (binExpr.type == NodeBinExpr.NodeBinExprType.sub)
            {
                string source_reg1 = "$1", source_reg2 = "$2";
                GenExpr(binExpr.rhs);
                GenExpr(binExpr.lhs);
                GenPop(source_reg1);
                GenPop(source_reg2);
                m_outputcode.Append($"SUB {source_reg1}, {source_reg1}, {source_reg2}\n");
                GenPush(source_reg1);
            }
            // TODO: support shifting using registers, add it to mips ISA
            else if (binExpr.type == NodeBinExpr.NodeBinExprType.sll)
            {
                string source_reg1 = "$1", source_reg2 = "$2";
                GenExpr(binExpr.rhs);
                GenExpr(binExpr.lhs);
                GenPop(source_reg1);
                GenPop(source_reg2);

                string? immed = GenImmedExpr(binExpr.rhs);
                if (immed != null)
                    source_reg2 = immed;
                else
                    Error("expected immediate", -1);
                m_outputcode.Append($"SLL {source_reg1}, {source_reg1}, {source_reg2}\n");
                GenPush(source_reg1);
            }
            else if (binExpr.type == NodeBinExpr.NodeBinExprType.srl)
            {
                string source_reg1 = "$1", source_reg2 = "$2";
                GenExpr(binExpr.rhs);
                GenExpr(binExpr.lhs);
                GenPop(source_reg1);
                GenPop(source_reg2);

                string? immed = GenImmedExpr(binExpr.rhs);
                if (immed != null)
                    source_reg2 = immed;
                else
                    Error("expected immediate", -1);
                m_outputcode.Append($"SRL {source_reg1}, {source_reg1}, {source_reg2}\n");
                GenPush(source_reg1);
            }
            else if (binExpr.type == NodeBinExpr.NodeBinExprType.equalequal)
            {
                string source_reg1 = "$1", source_reg2 = "$2";
                GenExpr(binExpr.rhs);
                GenExpr(binExpr.lhs);
                GenPop(source_reg1);
                GenPop(source_reg2);
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
                string source_reg1 = "$1", source_reg2 = "$2";
                GenExpr(binExpr.rhs);
                GenExpr(binExpr.lhs);
                GenPop(source_reg1);
                GenPop(source_reg2);
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
            else if (binExpr.type == NodeBinExpr.NodeBinExprType.lessthan)
            {
                string source_reg1 = "$1", source_reg2 = "$2";
                GenExpr(binExpr.rhs);
                GenExpr(binExpr.lhs);
                GenPop(source_reg1);
                GenPop(source_reg2);
                m_outputcode.Append($"SLT {source_reg1}, {source_reg1}, {source_reg2}\n");
                GenPush(source_reg1);
            }
            else if (binExpr.type == NodeBinExpr.NodeBinExprType.greaterthan)
            {
                string source_reg1 = "$1", source_reg2 = "$2";
                GenExpr(binExpr.rhs);
                GenExpr(binExpr.lhs);
                GenPop(source_reg1);
                GenPop(source_reg2);
                m_outputcode.Append($"SGT {source_reg1}, {source_reg1}, {source_reg2}\n");
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
        string? GenImmedTerm(NodeTerm term)
        {
            if (term.type == NodeTerm.NodeTermType.intlit)
            {
                return term.intlit.intlit.Value;
            }
            else if (term.type == NodeTerm.NodeTermType.paren)
            {
                return GenImmedExpr(term.paren.expr);
            }
            else
            {
                return null;
            }
        }
        string? GenImmedBinExpr(NodeBinExpr binExpr)
        {
            string? imm2 = GenImmedExpr(binExpr.rhs);
            string? imm1 = GenImmedExpr(binExpr.lhs);
            if (imm1 != null && imm2 != null)
            {
                return GetImmedOperation(imm1, imm2, binExpr.type);
            }
            return null;

        }
        string? GetImmedOperation(string imm1, string imm2, NodeBinExpr.NodeBinExprType op)
        {
            if (op == NodeBinExpr.NodeBinExprType.add)
                return (Convert.ToInt32(imm1) + Convert.ToInt32(imm2)).ToString();
            else if (op == NodeBinExpr.NodeBinExprType.sub)
                return (Convert.ToInt32(imm1) - Convert.ToInt32(imm2)).ToString();
            else if (op == NodeBinExpr.NodeBinExprType.sll)
                return (Convert.ToInt32(imm1) << Convert.ToInt32(imm2)).ToString();
            else if (op == NodeBinExpr.NodeBinExprType.srl)
                return (Convert.ToInt32(imm1) >> Convert.ToInt32(imm2)).ToString();
            else if (op == NodeBinExpr.NodeBinExprType.equalequal)
                return (Convert.ToInt32(imm1) == Convert.ToInt32(imm2) ? 1 : 0).ToString();
            else if (op == NodeBinExpr.NodeBinExprType.notequal)
                return (Convert.ToInt32(imm1) != Convert.ToInt32(imm2) ? 1 : 0).ToString();
            return null;
        }
        string? GenImmedExpr(NodeExpr Iexpr)
        {
            if (Iexpr.type == NodeExpr.NodeExprType.term)
            {
                return GenImmedTerm(Iexpr.term);
            }
            else if (Iexpr.type == NodeExpr.NodeExprType.binExpr)
            {
                return GenImmedBinExpr(Iexpr.binexpr);
            }
            return null;
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
                m_outputcode.Append($"BEQ $1, $zero, {label}\n");
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
        string GenStmtIF(NodeStmtIF iff)
        {
            string label_start = $"LABEL{m_labels_count++}_START";
            string label_end = $"LABEL{m_labels_count++}_END";
            string label = $"LABEL{m_labels_count++}_elifs";

            m_outputcode.Append($"{label_start}:\n");
            GenExpr(iff.pred.cond);
            string reg = "$1";
            GenPop(reg);
            m_outputcode.Append($"BEQ $1, $zero, {label}\n");
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
            return label_start;
        }
        void GenStmtFor(NodeStmtFor forr)
        {
            m_outputcode.Append("# begin forloop\n");
            BeginScope();
            if (forr.pred.init.HasValue)
            {
                // TODO: pop the initialization variables
                m_outputcode.Append("# begin init\n");
                if (forr.pred.init.Value.type == NodeForInit.NodeForInitType.declare)
                    GenStmtDeclare(forr.pred.init.Value.declare);
                else if (forr.pred.init.Value.type == NodeForInit.NodeForInitType.assign)
                    GenStmtAssign(forr.pred.init.Value.assign);
                m_outputcode.Append("# end init\n");
            }
            if (forr.pred.cond.HasValue)
            {
                m_outputcode.Append("# begin condition\n");
                string label_start = $"TEMP_LABEL{m_labels_count++}_START";
                string label_end = $"TEMP_LABEL{m_labels_count++}_END"; 

                m_outputcode.Append($"{label_start}:\n");
                GenExpr(forr.pred.cond.Value.cond);
                string reg = "$1";
                GenPop(reg);
                m_outputcode.Append($"BEQ $1, $zero, {label_end}\n");
                m_outputcode.Append("# end condition\n");
                GenScope(forr.pred.scope);
                m_outputcode.Append("# begin update\n");
                if (forr.pred.udpate.HasValue)
                {
                    for (int i = 0; i < forr.pred.udpate.Value.udpates.Count; i++)
                    {
                        GenStmtAssign(forr.pred.udpate.Value.udpates[i]);
                    }
                }
                m_outputcode.Append("# end update\n");
                m_outputcode.Append($"J {label_start}\n");
                m_outputcode.Append($"{label_end}:\n");
            }
            else if (forr.pred.udpate.HasValue)
            {
                m_outputcode.Append("# begin update\n");
                string label_start = $"TEMP_LABEL{m_labels_count++}_START";

                m_outputcode.Append($"{label_start}:\n");
                GenScope(forr.pred.scope);
                for (int i = 0; i < forr.pred.udpate.Value.udpates.Count; i++)
                {
                    GenStmtAssign(forr.pred.udpate.Value.udpates[i]);
                }
                m_outputcode.Append("# end update\n");
                m_outputcode.Append($"J {label_start}\n");
            }
            else
            {
                string label_start = $"TEMP_LABEL{m_labels_count++}_START";

                m_outputcode.Append($"{label_start}:\n");
                GenScope(forr.pred.scope);
                m_outputcode.Append($"J {label_start}\n");
            }
            EndScope();
            m_outputcode.Append("# end forloop\n");
        }
        void GenStmtExit(NodeStmtExit exit)
        {
            GenExpr(exit.expr);
            GenPop("$1");
            m_outputcode.Append("HLT\n");
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
            else if (stmt.type == NodeStmt.NodeStmtType.forr)
            {
                GenStmtFor(stmt.forr);
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
