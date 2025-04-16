using System.Collections.Generic;
using System.Linq;
using System.Reflection.Metadata.Ecma335;
using System.Runtime.Intrinsics.X86;
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
        public readonly int STACK_CAPACITY = 100;
        public NodeProg m_prog;
        public readonly StringBuilder m_outputcode = new();
        public Vars vars = new();
        public readonly Stack<int> m_scopes = [];
        public int m_labels_count = 0;
        public int m_StackSize = 0;
        public readonly Stack<string?> m_scopestart = [];
        public readonly Stack<string?> m_scopeend = [];
        public void Error(string msg, int line)
        {
            Console.ForegroundColor = ConsoleColor.Red;
            Console.WriteLine($"Generator: Error: {msg} on line: {line}");
            Console.ResetColor();
            Environment.Exit(1);
        }
        public static string? GetImmedOperation(string imm1, string imm2, NodeBinExpr.NodeBinExprType op)
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
            else if (op == NodeBinExpr.NodeBinExprType.lessthan)
                return (Convert.ToInt32(imm1) < Convert.ToInt32(imm2) ? 1 : 0).ToString();
            else if (op == NodeBinExpr.NodeBinExprType.greaterthan)
                return (Convert.ToInt32(imm1) > Convert.ToInt32(imm2) ? 1 : 0).ToString();
            else if (op == NodeBinExpr.NodeBinExprType.and)
                return (Convert.ToInt32(imm1) & Convert.ToInt32(imm2)).ToString();
            else if (op == NodeBinExpr.NodeBinExprType.or)
                return (Convert.ToInt32(imm1) | Convert.ToInt32(imm2)).ToString();
            else if (op == NodeBinExpr.NodeBinExprType.xor)
                return (Convert.ToInt32(imm1) ^ Convert.ToInt32(imm2)).ToString();
            return null;
        }
    }
    class MIPSGenerator : Generator
    {
        public MIPSGenerator(NodeProg prog)
        {
            m_prog = prog;
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
        void StackPopEndScope(int popcount)
        {
            m_outputcode.Append($"ADDi $sp, $sp, {popcount}\n");
        }
        void BeginScope()
        {
            m_outputcode.Append("# begin scope\n");
            m_scopes.Push(vars.m_vars.Count);
        }
        void EndScope()
        {
            m_outputcode.Append("# end scope\n");
            int Vars_topop = vars.m_vars.Count - m_scopes.Pop();
            int i = vars.m_vars.Count - 1;
            int iterations = Vars_topop;
            int popcount = 0;
            while (iterations-- > 0)
            {
                popcount += vars.m_vars[i--].Size;
            }
            StackPopEndScope(popcount);
            m_StackSize -= popcount;
            vars.m_vars.RemoveRange(vars.m_vars.Count - Vars_topop, Vars_topop);
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
            GenExpr_(array.index1, null);
            GenExpr_(array.expr, null);
            GenPop(reg_data);
            GenPop(reg_addr);
            int relative_location = m_StackSize - VariableLocation(array.ident.Value);
            m_outputcode.Append($"ADDI $3, $sp, {relative_location}\n");
            m_outputcode.Append($"SUB {reg_addr}, $3, {reg_addr}\n");
        }
        void GenArray2DAddrData(NodeStmtAssignArray array, string reg_addr, string reg_data)
        {
            if (!array.index2.HasValue)
                throw new Exception("array is not a 2D array");

            string index2 = "$2";
            GenExpr_(array.index2.Value, null);
            GenExpr_(array.index1, null);
            GenExpr_(array.expr, null);
            GenPop(reg_data);
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
        void GenTerm(NodeTerm term, string? DestinationRegister)
        {
            if (term.type == NodeTerm.NodeTermType.intlit)
            {
                string reg = "$1";
                string sign = (term.Negative) ? "-" : "";
                m_outputcode.Append($"ADDI {reg}, $zero, {sign}{term.intlit.intlit.Value}\n");
                if (DestinationRegister == null)
                {
                    GenPush(reg);
                }
                else
                {
                    m_outputcode.Append($"ADDI {DestinationRegister}, {reg}, 0\n");
                }
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
                    if (term.Negative)
                        m_outputcode.Append($"SUB {dest_reg}, $zero, {dest_reg}\n");
                    if (DestinationRegister == null)
                    {
                        GenPush(dest_reg);
                    }
                    else
                    {
                        m_outputcode.Append($"ADDI {DestinationRegister}, {dest_reg}, 0\n");
                    }
                }
                else
                {
                    if (ident.index2.HasValue)
                    {
                        string reg_addr = "$1";
                        string reg_data = "$3";
                        string index2 = "$2";

                        m_outputcode.Append($"# begin index\n");
                        GenExpr_(ident.index2.Value, null);
                        GenExpr_(ident.index1.Value, null);
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
                        if (term.Negative)
                            m_outputcode.Append($"SUB {reg_data}, $zero, {reg_data}\n");
                        if (DestinationRegister == null)
                        {
                            GenPush(reg_data);
                        }
                        else
                        {
                            m_outputcode.Append($"ADDI {DestinationRegister}, {reg_data}, 0\n");
                        }
                        m_outputcode.Append($"# end data\n");
                    }
                    else
                    {
                        string reg_addr = "$1";
                        string reg_data = "$2";
                        m_outputcode.Append($"# begin index\n");
                        GenExpr_(ident.index1.Value, reg_addr);
                        int relative_location = m_StackSize - VariableLocation(ident.ident.Value);
                        m_outputcode.Append($"# end index\n");
                        m_outputcode.Append($"# begin data\n");
                        m_outputcode.Append($"SUB {reg_addr}, $zero, {reg_addr}\n");
                        m_outputcode.Append($"ADDI {reg_addr}, {reg_addr}, {relative_location}\n");
                        m_outputcode.Append($"ADD {reg_addr}, {reg_addr}, $sp\n");
                        m_outputcode.Append($"LW {reg_data}, 0({reg_addr})\n");
                        if (term.Negative)
                            m_outputcode.Append($"SUB {reg_data}, $zero, {reg_data}\n");
                        if (DestinationRegister == null)
                        {
                            GenPush(reg_data);
                        }
                        else
                        {
                            m_outputcode.Append($"ADDI {DestinationRegister}, {reg_data}, 0\n");
                        }
                        m_outputcode.Append($"# end data\n");
                    }
                }
            }
            else if (term.type == NodeTerm.NodeTermType.paren)
            {
                GenExpr_(term.paren.expr, DestinationRegister);
            }
        }
        void GenBinExpr(NodeBinExpr binExpr, string? DestinationRegister)
        {
            // TODO: add an instruction to ISA to enable us to evaluate (`==`, `!=`), like for example (seq, sneq) -> (set if equal, set if not equal)
            if (binExpr.type == NodeBinExpr.NodeBinExprType.add)
            {
                string source_reg1 = "$1", source_reg2 = "$2";
                GenExpr_(binExpr.rhs, null);
                GenExpr_(binExpr.lhs, null);
                GenPop(source_reg1);
                GenPop(source_reg2);
                m_outputcode.Append($"ADD {source_reg1}, {source_reg1}, {source_reg2}\n");
                if (DestinationRegister == null) { GenPush(source_reg1); }
                else { m_outputcode.Append($"ADDI {DestinationRegister}, {source_reg1}, 0\n"); }
            }
            else if (binExpr.type == NodeBinExpr.NodeBinExprType.sub)
            {
                string source_reg1 = "$1", source_reg2 = "$2";
                GenExpr_(binExpr.rhs, null);
                GenExpr_(binExpr.lhs, null);
                GenPop(source_reg1);
                GenPop(source_reg2);
                m_outputcode.Append($"SUB {source_reg1}, {source_reg1}, {source_reg2}\n");
                if (DestinationRegister == null) { GenPush(source_reg1); }
                else { m_outputcode.Append($"ADDI {DestinationRegister}, {source_reg1}, 0\n"); }
            }
            // TODO: support shifting using registers, add it to mips ISA
            else if (binExpr.type == NodeBinExpr.NodeBinExprType.sll)
            {
                string source_reg1 = "$1", source_reg2 = "$2";
                GenExpr_(binExpr.rhs, null);
                GenExpr_(binExpr.lhs, null);
                GenPop(source_reg1);
                GenPop(source_reg2);

                string? immed = GenImmedExpr(binExpr.rhs);
                if (immed != null)
                    source_reg2 = immed;
                else
                    Error("expected immediate", -1);
                m_outputcode.Append($"SLL {source_reg1}, {source_reg1}, {source_reg2}\n");
                if (DestinationRegister == null) { GenPush(source_reg1); }
                else { m_outputcode.Append($"ADDI {DestinationRegister}, {source_reg1}, 0\n"); }
            }
            else if (binExpr.type == NodeBinExpr.NodeBinExprType.srl)
            {
                string source_reg1 = "$1", source_reg2 = "$2";
                GenExpr_(binExpr.rhs, null);
                GenExpr_(binExpr.lhs, null);
                GenPop(source_reg1);
                GenPop(source_reg2);

                string? immed = GenImmedExpr(binExpr.rhs);
                if (immed != null)
                    source_reg2 = immed;
                else
                    Error("expected immediate", -1);
                m_outputcode.Append($"SRL {source_reg1}, {source_reg1}, {source_reg2}\n");
                if (DestinationRegister == null) { GenPush(source_reg1); }
                else { m_outputcode.Append($"ADDI {DestinationRegister}, {source_reg1}, 0\n"); }
            }
            else if (binExpr.type == NodeBinExpr.NodeBinExprType.equalequal)
            {
                string source_reg1 = "$1", source_reg2 = "$2";
                GenExpr_(binExpr.rhs, null);
                GenExpr_(binExpr.lhs, null);
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
                if (DestinationRegister == null) { GenPush(source_reg1); }
                else { m_outputcode.Append($"ADDI {DestinationRegister}, {source_reg1}, 0\n"); }
            }
            else if (binExpr.type == NodeBinExpr.NodeBinExprType.notequal)
            {
                string source_reg1 = "$1", source_reg2 = "$2";
                GenExpr_(binExpr.rhs, null);
                GenExpr_(binExpr.lhs, null);
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
                if (DestinationRegister == null) { GenPush(source_reg1); }
                else { m_outputcode.Append($"ADDI {DestinationRegister}, {source_reg1}, 0\n"); }
            }
            else if (binExpr.type == NodeBinExpr.NodeBinExprType.lessthan)
            {
                string source_reg1 = "$1", source_reg2 = "$2";
                GenExpr_(binExpr.rhs, null);
                GenExpr_(binExpr.lhs, null);
                GenPop(source_reg1);
                GenPop(source_reg2);
                m_outputcode.Append($"SLT {source_reg1}, {source_reg1}, {source_reg2}\n");
                if (DestinationRegister == null) { GenPush(source_reg1); }
                else { m_outputcode.Append($"ADDI {DestinationRegister}, {source_reg1}, 0\n"); }
            }
            else if (binExpr.type == NodeBinExpr.NodeBinExprType.greaterthan)
            {
                string source_reg1 = "$1", source_reg2 = "$2";
                GenExpr_(binExpr.rhs, null);
                GenExpr_(binExpr.lhs, null);
                GenPop(source_reg1);
                GenPop(source_reg2);
                m_outputcode.Append($"SGT {source_reg1}, {source_reg1}, {source_reg2}\n");
                if (DestinationRegister == null) { GenPush(source_reg1); }
                else { m_outputcode.Append($"ADDI {DestinationRegister}, {source_reg1}, 0\n"); }
            }
            else if (binExpr.type == NodeBinExpr.NodeBinExprType.and)
            {
                string source_reg1 = "$1", source_reg2 = "$2";
                GenExpr_(binExpr.rhs, null);
                GenExpr_(binExpr.lhs, null);
                GenPop(source_reg1);
                GenPop(source_reg2);
                m_outputcode.Append($"AND {source_reg1}, {source_reg1}, {source_reg2}\n");
                if (DestinationRegister == null) { GenPush(source_reg1); }
                else { m_outputcode.Append($"ADDI {DestinationRegister}, {source_reg1}, 0\n"); }
            }
            else if (binExpr.type == NodeBinExpr.NodeBinExprType.or)
            {
                string source_reg1 = "$1", source_reg2 = "$2";
                GenExpr_(binExpr.rhs, null);
                GenExpr_(binExpr.lhs, null);
                GenPop(source_reg1);
                GenPop(source_reg2);
                m_outputcode.Append($"OR {source_reg1}, {source_reg1}, {source_reg2}\n");
                if (DestinationRegister == null) { GenPush(source_reg1); }
                else { m_outputcode.Append($"ADDI {DestinationRegister}, {source_reg1}, 0\n"); }
            }
            else if (binExpr.type == NodeBinExpr.NodeBinExprType.xor)
            {
                string source_reg1 = "$1", source_reg2 = "$2";
                GenExpr_(binExpr.rhs, null);
                GenExpr_(binExpr.lhs, null);
                GenPop(source_reg1);
                GenPop(source_reg2);
                m_outputcode.Append($"XOR {source_reg1}, {source_reg1}, {source_reg2}\n");
                if (DestinationRegister == null) { GenPush(source_reg1); }
                else { m_outputcode.Append($"ADDI {DestinationRegister}, {source_reg1}, 0\n"); }
            }
            else
            {
                Error("expected binary operator", -1);
            }
        }
        void GenExpr_(NodeExpr expr, string? DestinationRegister)
        {
            if (expr.type == NodeExpr.NodeExprType.term)
            {
                GenTerm(expr.term, DestinationRegister);
            }
            else if (expr.type == NodeExpr.NodeExprType.binExpr)
            {
                GenBinExpr(expr.binexpr, DestinationRegister);
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
                GenExpr_(init[i], null);
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
                    GenExpr_(declare.singlevar.expr, null);
                    vars.m_vars.Add(new(ident.Value, 1));
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
                            m_outputcode.Append($"ADDI $sp, $sp, -{dim1 * dim2}\n");
                            m_StackSize += (dim1 * dim2);
                        }
                        else
                        {
                            GenArrayInit2D(declare.array.values2);
                        }
                        vars.m_vars.Add(new(ident.Value, dim1 * dim2));
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
                string reg = "$1";
                if (!IsVariableDeclared(ident.Value))
                {
                    Error($"variable {ident.Value} is not declared", ident.Line);
                }
                GenExpr_(assign.singlevar.expr, reg);
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
                string reg = "$1";
                string label = $"LABEL{m_labels_count++}_elifs";
                GenExpr_(elifs.elif.pred.cond, reg);
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
            string reg = "$1";
            string label_start = $"LABEL{m_labels_count++}_START";
            string label_end = $"LABEL{m_labels_count++}_END";
            string label = $"LABEL{m_labels_count++}_elifs";

            m_outputcode.Append($"{label_start}:\n");
            GenExpr_(iff.pred.cond, reg);
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
                string label_update = $"TEMP_LABEL{m_labels_count++}_START";

                m_outputcode.Append($"{label_start}:\n");
                string reg = "$1";
                GenExpr_(forr.pred.cond.Value.cond, reg);
                m_outputcode.Append($"BEQ $1, $zero, {label_end}\n");
                m_outputcode.Append("# end condition\n");
                m_scopestart.Push(label_update);
                m_scopeend.Push(label_end);
                GenScope(forr.pred.scope);
                m_scopestart.Pop();
                m_scopeend.Pop();
                m_outputcode.Append("# begin update\n");
                m_outputcode.Append($"{label_update}:\n");
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
                string label_start = $"TEMP_LABEL{m_labels_count++}_START";
                string label_end = $"TEMP_LABEL{m_labels_count++}_END";
                string label_update = $"TEMP_LABEL{m_labels_count++}_START";

                m_outputcode.Append($"{label_start}:\n");
                m_scopestart.Push(label_update);
                m_scopeend.Push(label_end);
                GenScope(forr.pred.scope);
                m_scopestart.Pop();
                m_scopeend.Pop();
                m_outputcode.Append("# begin update\n");
                m_outputcode.Append($"{label_update}:\n");
                for (int i = 0; i < forr.pred.udpate.Value.udpates.Count; i++)
                {
                    GenStmtAssign(forr.pred.udpate.Value.udpates[i]);
                }
                m_outputcode.Append("# end update\n");
                m_outputcode.Append($"J {label_start}\n");
                m_outputcode.Append($"{label_end}:\n");
            }
            else
            {
                string label_start = $"TEMP_LABEL{m_labels_count++}_START";
                string label_end = $"TEMP_LABEL{m_labels_count++}_END";

                m_outputcode.Append($"{label_start}:\n");
                m_scopestart.Push(label_start);
                m_scopeend.Push(label_end);
                GenScope(forr.pred.scope);
                m_scopestart.Pop();
                m_scopeend.Pop();
                m_outputcode.Append($"J {label_start}\n");
                m_outputcode.Append($"{label_end}:\n");
            }
            EndScope();
            m_outputcode.Append("# end forloop\n");
        }
        void GenStmtWhile(NodeStmtWhile whilee)
        {
            m_outputcode.Append("# begin whileloop\n");
            BeginScope();
            m_outputcode.Append("# begin condition\n");
            string label_start = $"TEMP_LABEL{m_labels_count++}_START";
            string label_end = $"TEMP_LABEL{m_labels_count++}_END";

            m_outputcode.Append($"{label_start}:\n");
            string reg = "$1";
            GenExpr_(whilee.cond, reg);
            m_outputcode.Append($"BEQ $1, $zero, {label_end}\n");
            m_outputcode.Append("# end condition\n");
            m_scopestart.Push(label_start);
            m_scopeend.Push(label_end);
            GenScope(whilee.scope);
            m_scopestart.Pop();
            m_scopeend.Pop();
            m_outputcode.Append($"J {label_start}\n");
            m_outputcode.Append($"{label_end}:\n");
            EndScope();
            m_outputcode.Append("# end whileloop\n");
        }
        void GenStmtBreak(NodeStmtBreak breakk)
        {
            if (m_scopeend.Count == 0)
                Error("no enclosing loop out of which to break", breakk.breakk.Line);
            m_outputcode.Append($"J {m_scopeend.Peek()}\n");
        }
        void GenStmtContinue(NodeStmtContinuee continuee)
        {
            if (m_scopestart.Count == 0)
                Error("no enclosing loop out of which to break", continuee.continuee.Line);
            m_outputcode.Append($"J {m_scopestart.Peek()}\n");
        }
        void GenStmtExit(NodeStmtExit exit)
        {
            GenExpr_(exit.expr, "$1");
            m_outputcode.Append("HLT\n");
        }
        void GenStmtCleanStack(NodeStmtCleanStack CleanStack)
        {
            m_outputcode.Append($"ADDI $1, $zero, 0\n");
            m_outputcode.Append($"ADDI $2, $zero, {STACK_CAPACITY + 1}\n");
            m_outputcode.Append($"Clean_Loop:\n");
            m_outputcode.Append($"SW $zero, 0($1)\n");
            m_outputcode.Append($"ADDI $1, $1, 1\n");
            m_outputcode.Append($"BNE $1, $2, Clean_Loop\n");
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
            else if (stmt.type == NodeStmt.NodeStmtType.If)
            {
                GenStmtIF(stmt.If);
            }
            else if (stmt.type == NodeStmt.NodeStmtType.For)
            {
                GenStmtFor(stmt.For);
            }
            else if (stmt.type == NodeStmt.NodeStmtType.While)
            {
                GenStmtWhile(stmt.While);
            }
            else if (stmt.type == NodeStmt.NodeStmtType.Break)
            {
                GenStmtBreak(stmt.Break);
            }
            else if (stmt.type == NodeStmt.NodeStmtType.Continue)
            {
                GenStmtContinue(stmt.Continue);
            }
            else if (stmt.type == NodeStmt.NodeStmtType.Exit)
            {
                GenStmtExit(stmt.Exit);
            }
            else if (stmt.type == NodeStmt.NodeStmtType.CleanSack)
            {
                GenStmtCleanStack(stmt.CleanStack);
            }
        }

        public StringBuilder GenProg()
        {
            m_outputcode.Append(".text\n");
            m_outputcode.Append("main:\n");
            m_outputcode.Append($"ADDI $sp, $zero, {STACK_CAPACITY}\n");
            foreach (NodeStmt stmt in m_prog.scope.stmts)
                GenStmt(stmt);

            return m_outputcode;
        }
    }
}
#pragma warning restore CS8500
