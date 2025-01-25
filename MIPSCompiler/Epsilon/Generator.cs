using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Security.Principal;
using System.Text;
#pragma warning disable CS8500


namespace Epsilon
{
    public struct Var
    {
        public Var(string value, int size)
        {
            Value = value;
            Size = size;
        }
        public string Value { get; set; }
        public int Size { get; set; }
    }
    public struct Vars
    {
        public Vars()
        {
            m_vars = [];
        }
        public List<Var> m_vars = [];
    }
    class Generator
    {
        public NodeProg m_prog;
        StringBuilder m_outputcode = new();
        public Vars vars = new();
        List<int> m_scopes = [];
        int m_labels_count = 0;
        int m_StackSize = 0;
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
            m_outputcode.Append($"SW {reg}, 0($sp)\n");
            m_outputcode.Append("ADDI $sp, $sp, -1\n");
            m_StackSize++;
        }

        void GenPop(string reg)
        {
            m_outputcode.Append("ADDI $sp, $sp, 1\n");
            m_outputcode.Append($"LW {reg}, 0($sp)\n");
            m_StackSize--;
        }
        void BeginScope()
        {
            m_outputcode.Append("# begin scope\n");
            m_scopes.Add(vars.m_vars.Count);
        }
        void EndScope()
        {
            m_outputcode.Append("# end scope\n");
            int Vars_topop = vars.m_vars.Count - m_scopes[^1];
            int i = vars.m_vars.Count - 1;
            int iterations = Vars_topop;
            int popcount = 0;
            while (iterations-- > 0)
            {
                popcount += vars.m_vars[i--].Size;
            }
            m_outputcode.Append($"ADDi $sp, $sp, {popcount}\n");
            m_StackSize -= popcount;
            vars.m_vars.RemoveRange(vars.m_vars.Count - Vars_topop, Vars_topop);
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
        bool IsVariableDeclared(string name)
        {
            for (int i = 0; i < vars.m_vars.Count; i++)
                if (vars.m_vars[i].Value == name)
                    return true;
            return false;
        }
        int VariableLocation(string name)
        {
            int index = 0;
            for (int i = 0; i < vars.m_vars.Count; i++)
            {
                if (vars.m_vars[i].Value == name)
                    break;
                else
                    index += vars.m_vars[i].Size;
            }
            return index;
        }
        void GenArray1DAddrData(NodeStmtAssignArray array, string reg_addr, string reg_data)
        {
            GenExpr(array.index1);
            GenExpr(array.expr);
            GenPop(reg_data);
            GenPop(reg_addr);
            int relative_location = m_StackSize - VariableLocation(array.ident.Value);
            m_outputcode.Append($"ADDI $3, $sp, {relative_location}\n");
            m_outputcode.Append($"SUB {reg_addr}, $3, {reg_addr}\n");
        }
        void GenArray2DAddrData(NodeStmtAssignArray array, string reg_addr, string? reg_data)
        {
            string index2 = "$2";
            if (array.index2.HasValue)
                GenExpr(array.index2.Value);
            GenExpr(array.index1);
            if (reg_data != null)
            {
                GenExpr(array.expr);
                GenPop(reg_data);
            }
            GenPop(reg_addr);
            GenPop(index2);
            if (array.dim2.HasValue)
                GenMult(reg_addr, array.dim2.Value.intlit.Value);

            int relative_location = m_StackSize - VariableLocation(array.ident.Value);
            m_outputcode.Append($"ADD {reg_addr}, {reg_addr}, {index2}\n");
            m_outputcode.Append($"SUB {reg_addr}, $zero, {reg_addr}\n");
            m_outputcode.Append($"ADDI {reg_addr}, {reg_addr}, {relative_location}\n");
            m_outputcode.Append($"ADD {reg_addr}, {reg_addr}, $sp\n");
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
                m_outputcode.Append($"########## {term.ident.ident.Value}\n");
                NodeTermIdent ident = term.ident;
                if (!IsVariableDeclared(ident.ident.Value))
                {
                    Error($"variable {ident.ident.Value} is not declared", ident.ident.Line);
                }
                if (!ident.index1.HasValue)
                {
                    string dest_reg = "$1";
                    int relative_location = m_StackSize - VariableLocation(ident.ident.Value);
                    m_outputcode.Append($"LW {dest_reg}, {relative_location}($sp)\n");
                    GenPush(dest_reg);
                }
                else
                {
                    if (ident.index2.HasValue)
                    {
                        string reg_addr = "$1";
                        string reg_data = "$3";
                        string index2 = "$2";

                        m_outputcode.Append($"# begin index\n");
                        if (ident.index2.HasValue)
                            GenExpr(ident.index2.Value);
                        GenExpr(ident.index1.Value);
                        GenPop(reg_addr);
                        GenPop(index2);
                        if (ident.dim2.HasValue)
                            GenMult(reg_addr, ident.dim2.Value.intlit.Value);
                        m_outputcode.Append($"# end index\n");

                        m_outputcode.Append($"# begin data\n");
                        int relative_location = m_StackSize - VariableLocation(ident.ident.Value);
                        m_outputcode.Append($"ADD {reg_addr}, {reg_addr}, {index2}\n");
                        m_outputcode.Append($"SUB {reg_addr}, $zero, {reg_addr}\n");
                        m_outputcode.Append($"ADDI {reg_addr}, {reg_addr}, {relative_location}\n");
                        m_outputcode.Append($"ADD {reg_addr}, {reg_addr}, $sp\n");
                        m_outputcode.Append($"LW {reg_data}, 0({reg_addr})\n");
                        GenPush(reg_data);
                        m_outputcode.Append($"# end data\n");
                    }
                    else
                    {
                        string reg_addr = "$1";
                        string reg_data = "$2";
                        m_outputcode.Append($"# begin index\n");
                        GenExpr(ident.index1.Value);
                        GenPop(reg_addr);
                        int relative_location = m_StackSize - VariableLocation(ident.ident.Value);
                        m_outputcode.Append($"# end index\n");
                        m_outputcode.Append($"# begin data\n");
                        m_outputcode.Append($"SUB {reg_addr}, $zero, {reg_addr}\n");
                        m_outputcode.Append($"ADDI {reg_addr}, {reg_addr}, {relative_location}\n");
                        m_outputcode.Append($"ADD {reg_addr}, {reg_addr}, $sp\n");
                        m_outputcode.Append($"LW {reg_data}, 0({reg_addr})\n");
                        GenPush(reg_data);
                        m_outputcode.Append($"# end data\n");
                    }

                }

            }
            else if (term.type == NodeTerm.NodeTermType.paren)
            {
                GenExpr(term.paren.expr);
            }
        }
        void GenBinExpr(NodeBinExpr binExpr)
        {
            // TODO: add an instruction to ISA to enable us to evaluate (`==`, `!=`), like for example (seq, sneq) -> (set if equal, set if not equal)
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
            else if (binExpr.type == NodeBinExpr.NodeBinExprType.and)
            {
                string source_reg1 = "$1", source_reg2 = "$2";
                GenExpr(binExpr.rhs);
                GenExpr(binExpr.lhs);
                GenPop(source_reg1);
                GenPop(source_reg2);
                m_outputcode.Append($"AND {source_reg1}, {source_reg1}, {source_reg2}\n");
                GenPush(source_reg1);
            }
            else if (binExpr.type == NodeBinExpr.NodeBinExprType.or)
            {
                string source_reg1 = "$1", source_reg2 = "$2";
                GenExpr(binExpr.rhs);
                GenExpr(binExpr.lhs);
                GenPop(source_reg1);
                GenPop(source_reg2);
                m_outputcode.Append($"OR {source_reg1}, {source_reg1}, {source_reg2}\n");
                GenPush(source_reg1);
            }
            else if (binExpr.type == NodeBinExpr.NodeBinExprType.xor)
            {
                string source_reg1 = "$1", source_reg2 = "$2";
                GenExpr(binExpr.rhs);
                GenExpr(binExpr.lhs);
                GenPop(source_reg1);
                GenPop(source_reg2);
                m_outputcode.Append($"XOR {source_reg1}, {source_reg1}, {source_reg2}\n");
                GenPush(source_reg1);
            }
            else
            {
                Error("expected binary operator", -1);
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
        void GenArrayInit1D(List<NodeExpr> init)
        {
            for (int i = 0; i < init.Count; i++)
            {
                GenExpr(init[i]);
            }
        }
        void GenArrayInit2D(List<List<NodeExpr>> init)
        {
            for (int i = 0; i < init.Count; i++)
            {
                GenArrayInit1D(init[i]);
            }
        }
        void GenStmtDeclare(NodeStmtDeclare declare)
        {
            if (declare.type == NodeStmtDeclare.NodeStmtDeclareType.SingleVar)
            {
                Token ident = declare.singlevar.ident;
                if (IsVariableDeclared(ident.Value))
                {
                    Error($"variable {ident.Value} is already declared", ident.Line);
                }
                else
                {
                    vars.m_vars.Add(new(ident.Value, 1));
                    GenExpr(declare.singlevar.expr);
                }
            }
            else if (declare.type == NodeStmtDeclare.NodeStmtDeclareType.Array)
            {
                Token ident = declare.array.ident;
                if (IsVariableDeclared(ident.Value))
                {
                    Error($"variable {ident.Value} is already declared", ident.Line);
                }
                else
                {
                    
                    if (declare.array.dim2.HasValue)
                    {
                        int dim1 = Convert.ToInt32(declare.array.dim1.intlit.Value);
                        int dim2 = Convert.ToInt32(declare.array.dim2.Value.intlit.Value);
                        if (declare.array.values2.Count == 0)
                        {
                            m_outputcode.Append($"ADDI $sp, $sp, -{dim1*dim2}\n");
                            m_StackSize += (dim1 * dim2);
                        }
                        else
                        {
                            GenArrayInit2D(declare.array.values2);
                        }
                        vars.m_vars.Add(new(ident.Value, dim1*dim2));
                    }
                    else
                    {
                        int dim1 = Convert.ToInt32(declare.array.dim1.intlit.Value);
                        if (declare.array.values1.Count == 0)
                        {
                            m_outputcode.Append($"ADDI $sp, $sp, -{dim1}\n");
                            m_StackSize += (dim1);
                        }
                        else
                        {
                            GenArrayInit1D(declare.array.values1);
                        }
                        vars.m_vars.Add(new(ident.Value, dim1));
                    }
                }
            }
        }
        void GenMult(string reg, string intlit)
        {
            string count = "$8";
            string temp = "$9";
            m_outputcode.Append($"ADDI {count}, $zero, {intlit}\n");
            m_outputcode.Append($"ADD {temp}, $zero, {reg}\n");
            string label_start = $"LABEL{m_labels_count++}_START";
            string label_end = $"LABEL{m_labels_count++}_END";

            m_outputcode.Append($"{label_start}:\n");
            m_outputcode.Append($"ADDI {count}, {count}, -1\n");
            m_outputcode.Append($"BEQ {count}, $zero, {label_end}\n");
            m_outputcode.Append($"ADD {reg}, {reg}, {temp}\n");
            m_outputcode.Append($"J {label_start}\n");
            m_outputcode.Append($"{label_end}:\n");
        }

        void GenArrayAssign1D(NodeStmtAssignArray array)
        {
            // we save $sp + relative_location - index in $2 to use it as an address
            string reg_addr = "$1";
            string reg_data = "$2";
            GenArray1DAddrData(array, reg_addr, reg_data);
            m_outputcode.Append($"SW {reg_data}, 0({reg_addr})\n");
        }
        void GenArrayAssign2D(NodeStmtAssignArray array)
        {
            string reg_addr = "$1";
            string reg_data = "$3";
            GenArray2DAddrData(array, reg_addr, reg_data);
            m_outputcode.Append($"SW {reg_data}, 0({reg_addr})\n");
        }
        void GenStmtAssign(NodeStmtAssign assign)
        {
            if (assign.type == NodeStmtAssign.NodeStmtAssignType.SingleVar)
            {
                Token ident = assign.singlevar.ident;
                if (!IsVariableDeclared(ident.Value))
                {
                    Error($"variable {ident.Value} is not declared", ident.Line);
                }
                GenExpr(assign.singlevar.expr);
                string reg = "$1";
                GenPop(reg);
                int relative_location = m_StackSize - VariableLocation(ident.Value);
                m_outputcode.Append($"SW {reg}, {relative_location}($sp)\n");
            }
            else if (assign.type == NodeStmtAssign.NodeStmtAssignType.Array)
            {
                Token ident = assign.array.ident;
                if (!IsVariableDeclared(ident.Value))
                {
                    Error($"variable {ident.Value} is not declared", ident.Line);
                }
                if (assign.array.index2.HasValue)
                {
                    GenArrayAssign2D(assign.array);
                }
                else
                    GenArrayAssign1D(assign.array);
            }
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
