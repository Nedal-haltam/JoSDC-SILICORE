


using System.ComponentModel.Design;
using System.Text;

namespace MIPSASSEMBLER
{
    public enum InstructionType
    {
        rtype, itype, jtype
    }

    public struct Token
    {
        public string value;
        public Token(string value)
        {
            this.value = value;
        }
    }

    public struct Instruction
    {
        public List<Token> tokens;
        public InstructionType type;
        public Instruction()
        {
            tokens = [];
        }
        public Instruction(List<Token> tokens)
        {
            this.tokens = tokens;
        }
    }

    public struct Program
    {
        public List<Instruction> instructions;
        public List<string> mc;

        public Program()
        {
            instructions = [];
            mc = [];
        }
    }

    public class MIPSASSEMBLER
    {
        public bool lblinvlabel = false;
        public bool lblmultlabels = false;
        public bool lblINVINST = false;
        readonly Dictionary<string, int> labels = [];
        List<string> m_prog = [];
        string m_curr_inst = "";
        int m_curr_index = 0;
        readonly List<string> REG_LIST =
        [ "zero", "at", "v0", "v1", "a0", "a1", "a2", "a3", "t0", "t1", "t2", "t3", "t4", "t5", "t6", "t7",
          "s0", "s1", "s2", "s3", "s4", "s5", "s6", "s7", "t8", "t9", "k0", "k1", "gp", "sp", "fp", "ra"];
        // The instruction type is the main token in a given instruction and should be known the first token in an instruction (first word)
        // the opcodes is a dictionary the you give it a certain opcode (in words) and get beack the binaries (or machine code) corresponding to that opcode
        // take a look to know what to expect because the binary might be different depending on the opcode some of them only opcode or with func3 or even with func7
        readonly Dictionary<string, string> opcodes = new()//{ "inst"     , "opcode/funct" },
        {
            { "nop"  , "000000" },
            { "hlt"  , "111111" },

            // R-format , opcode = 0
            { "add"  , "100000" },
            { "addu" , "100001" },
            { "sub"  , "100010" },
            { "subu" , "100011" },
            { "and"  , "100100" },
            { "or"   , "100101" },
            { "xor"  , "100110" },
            { "nor"  , "100111" },
            { "slt"  , "101010" },
            { "sgt"  , "101011" },
            { "sll"  , "000000" },
            { "srl"  , "000010" },
            { "jr"   , "001000" },
            
            // I-format
            { "addi" , "001000" },
            { "andi" , "001100" },
            { "ori"  , "001101" },
            { "xori" , "001110" },
            { "slti" , "101010" },
            { "lw"   , "100011" },
            { "sw"   , "101011" },
            { "beq"  , "000100" },
            { "bne"  , "000101" }, 
        
            // J-format
            { "j"    , "000010" },
            { "jal"  , "000011" },

        };

        // checks for impty instruction that dont need to be tokenized or converted to machine code
        public bool EmptyLine(string instruction)
        {
            return string.IsNullOrEmpty(instruction) || string.IsNullOrWhiteSpace(instruction);
        }

        // input : the opcode (string : in words)
        // return the Instruction type
        InstructionType? GetInstType(string name)
        {
            return name switch
            {
                "add" or "addu" or "sub" or "subu" or "and" or "or" or "xor" or "nor" or "slt" or 
                "sgt" or "sll" or "srl" or "jr" or "nop" => InstructionType.rtype,
                "addi" or "andi" or "ori" or "xori" or "slti" or "lw" or "sw" or "beq" or "bne" or "hlt" => InstructionType.itype,
                                                                                                                  
                "j" or "jal" => InstructionType.jtype,
                _ => null,
            };
        }

        // it takes as input the register name and extracts the index form it
        string? Getregindex(string reg)
        {
            if (reg.StartsWith('x'))
            {
                string index = reg[1..];
                if (byte.TryParse(index, out byte usb) && usb >= 0 && usb <= 31)
                {
                    return Convert.ToString(usb, 2).PadLeft(5, '0');
                }
                else
                    return null;
            }
            else if (reg.StartsWith('$'))
            {

                string name = reg[1..];
                if (byte.TryParse(name, out byte usb) && usb >= 0 && usb <= 31)
                {
                    return Convert.ToString(usb, 2).PadLeft(5, '0');
                }
                else
                {
                    if (!REG_LIST.Contains(name))
                    {
                        return null;
                    }
                    return Convert.ToString(REG_LIST.IndexOf(name), 2).PadLeft(5, '0');
                }
            }
            else
                return null;

        }

        // the following functions are used to tokenize, parse, and then generate the corresponding machine code for every 
        // token of the instruction
        string? Getrtypeinst(Instruction inst)
        {
            string mc;

            if (inst.tokens[0].value == "jr") // jr x12
            {
                if (inst.tokens.Count != 2)
                    return null;
                string? rs1 = Getregindex(inst.tokens[1].value);
                if (rs1 == null) return null;
                mc = "000000" + rs1 + "000000000000000" + opcodes[inst.tokens[0].value];
            }
            else
            {
                if (inst.tokens.Count != 4)
                    return null;
                string? rd = Getregindex(inst.tokens[1].value);
                string? rs1 = Getregindex(inst.tokens[2].value);
                string funct = opcodes[inst.tokens[0].value];

                if (rd == null || rs1 == null) return null;

                if (inst.tokens[0].value == "sll" || inst.tokens[0].value == "srl") // sll x1, x2, 2
                {
                    string shamt = inst.tokens[3].value;
                    if (byte.TryParse(shamt, out byte usb))
                    {
                        shamt = Convert.ToString(usb, 2);
                        if (shamt.Length > 5) shamt = shamt.Substring(shamt.Length - 5, 5);
                        shamt = shamt.PadLeft(5, '0');
                    }
                    else if (sbyte.TryParse(shamt, out sbyte sb))
                    {
                        shamt = Convert.ToString(sb, 2);
                        if (shamt.Length > 5) shamt = shamt.Substring(shamt.Length - 5, 5);
                        shamt = shamt.PadLeft(5, '0');
                    }
                    else
                        return null;
                    mc = "000000"
                        + "00000"
                        + rs1
                        + rd
                        + shamt
                        + funct;
                }
                else
                {
                    string? rs2 = Getregindex(inst.tokens[3].value);
                    if (rs2 == null)
                        return null;
                    mc = "000000"
                        + rs1
                        + rs2
                        + rd
                        + "00000"
                        + funct;
                }
            }
            return mc;
        }
        public bool Isbranch(string mnem)
        {
            return mnem == "beq" || mnem == "bne";
        }
        string? Getitypeinst(Instruction inst)
        {
            if (inst.tokens.Count != 4)
                return null;
            string mc;
            string opcode = opcodes[inst.tokens[0].value];


            string? reg1 = Getregindex(inst.tokens[1].value);
            string? reg2 = Getregindex(inst.tokens[2].value);
            if (reg1 == null || reg2 == null)
                return null;

            if (Isbranch(inst.tokens[0].value))
            {
                if (!labels.ContainsKey(inst.tokens[3].value))
                    return null;
                string immed = inst.tokens[3].value;
                immed = (labels[immed] - curr_inst_index).ToString();
                if (ushort.TryParse(immed, out ushort usb))
                    immed = Convert.ToString(usb, 2).PadLeft(16, '0');
                else if (short.TryParse(immed, out short sb))
                {
                    immed = Convert.ToString(sb, 2);
                    immed = immed.PadLeft(16, immed[0]);
                }
                else
                    return null;
                string rs1 = reg1;
                string rs2 = reg2;
                mc = opcode + rs1 + rs2 + immed;
            }
            else
            {
                // andi, ori, xori (they do zero extend)
                string immed = inst.tokens[3].value;
                if ((immed.StartsWith("0x") || immed.StartsWith("0X")))
                {
                    short temp;
                    try { temp = Convert.ToInt16(immed, 16); }
                    catch { return null; }

                    immed = Convert.ToString(temp, 2).PadLeft(16, '0');
                }
                else if (ushort.TryParse(immed, out ushort usb))
                {
                    immed = Convert.ToString(usb, 2);
                    immed = immed.PadLeft(16, '0');
                }
                else if (short.TryParse(immed, out short sb))
                {
                    immed = Convert.ToString(sb, 2);
                    immed = immed.PadLeft(16, immed[0]); // 1010101000
                }
                else
                    return null;
                string rd = reg1;
                string rs1 = reg2;
                mc = opcode + rs1 + rd + immed;
            }

            return mc;
        }
        string? Getjtypeinst(Instruction inst)
        {
            if (inst.tokens.Count != 2 || !labels.TryGetValue(inst.tokens[1].value, out int lbl))
                return null;
            string immed = Convert.ToString(lbl, 2);
            immed = immed.PadLeft(26, '0');
            string mc = opcodes[inst.tokens[0].value] + immed;
            return mc;
        }
        // this function takes the instructio and it's type and based on it, it passes it to the suitable fucntion to generate the machine code
        string? GetMcOfInst(Instruction inst)
        {
            if (inst.tokens.Count > 0 && (inst.tokens[0].value == "hlt" || inst.tokens[0].value == "nop"))
                return opcodes[inst.tokens[0].value].PadRight(32, '0');
            // here we construct the binaries of a given instruction
            return inst.type switch
            {
                InstructionType.rtype => Getrtypeinst(inst),
                InstructionType.itype => Getitypeinst(inst),
                InstructionType.jtype => Getjtypeinst(inst),
                _ => null,
            };
        }
        int curr_inst_index;
        // this fucntion iterates through the whole list of instruction and returns a list of the machine code for each valid instruction
        // and keep track of it's index for substituting the values of the labels
        List<string>? GetMachineCode(ref List<Instruction> insts)
        {
            List<string> mcs = [];
            curr_inst_index = 0;
            for (int i = 0; i < insts.Count; i++)
            {
                InstructionType? type = GetInstType(insts[i].tokens[0].value);
                if (type.HasValue)
                {
                    Instruction temp = insts[i];
                    temp.type = type.Value;
                    insts[i] = temp;
                    string? mc = GetMcOfInst(insts[i]);
                    if (mc == null)
                    {
                        return null;
                    }
                    mcs.Add(mc);
                    curr_inst_index++;
                }
                else
                {
                    return null;
                }
            }

            return mcs;
        }

        bool Is_pseudo_branch(string mnem)
        {
            return mnem == "bltz" || mnem == "bgez";
        }


        bool Is_pseudo(string mnem)
        {
            return Is_pseudo_branch(mnem)/* || other pseudo insts*/;
        }

        List<Instruction>? Pseudo_to_inst(List<Token> pseudo)
        {
            if (Is_pseudo_branch(pseudo[0].value) && pseudo.Count == 3)
            {
                string branch;
                if (pseudo[0].value == "bltz")
                {
                    branch = "bne";
                }
                else if (pseudo[0].value == "bgez")
                {
                    branch = "beq";
                }
                else
                {
                    return null;
                }
                return [
                    new Instruction([new Token("slt"), new Token("x31"), new Token($"{pseudo[1].value}"), new Token("x0") ]),
                    new Instruction([new Token(branch), new Token("x31"), new Token("x0"), new Token($"{pseudo[2].value}") ]),
                ];
            }
            return null;
        }


        void Substitute_pseudo_insts(ref Program program)
        {
            for (int i = 0; i < program.instructions.Count; i++)
            {
                List<Token> inst = program.instructions[i].tokens;
                if (inst.Count > 0 && Is_pseudo(inst[0].value))
                {
                    List<Instruction> replace = Pseudo_to_inst(inst);
                    program.instructions.RemoveAt(i);
                    program.instructions.InsertRange(i, replace);
                    i = 0;
                }
            }
        }


        char? peek(int offset = 0)
        {
            if (m_curr_index + offset < m_curr_inst.Length)
            {
                return m_curr_inst[m_curr_index + offset];
            }
            return null;
        }
        char? peek(char type, int offset = 0)
        {
            char? token = peek(offset);
            if (token.HasValue && token.Value == type)
            {
                return token;
            }
            return null;
        }
        char consume()
        {
            return m_curr_inst.ElementAt(m_curr_index++);
        }

        bool IsComment()
        {
            return (peek('/').HasValue && peek('/', 1).HasValue) || peek('#').HasValue;
        }


        Instruction? TokenizeInst()
        {
            StringBuilder buffer = new StringBuilder();
            Instruction instruction = new Instruction();
            while (peek().HasValue)
            {
                char c = peek().Value;

                if (char.IsWhiteSpace(c) || c == ',')
                {
                    if (buffer.Length > 0)
                    {
                        instruction.tokens.Add(new Token(buffer.ToString()));
                        buffer.Clear();
                    }
                    consume();
                }
                else if (IsComment())
                {
                    if (buffer.Length > 0)
                    {
                        instruction.tokens.Add(new Token(buffer.ToString()));
                        buffer.Clear();
                    }
                    break;
                }
                else
                {
                    buffer.Append(char.ToLower(c));
                    consume();
                }
            }
            if (buffer.Length > 0)
            {
                instruction.tokens.Add(new Token(buffer.ToString()));
                buffer.Clear();
            }
            m_curr_index = 0;
            return instruction;
        }

        // assmebling the program starts form here 
        // it tokenizes each non empty instruction and returns a list of parsable instruction each one of them is a list of tokens

        // it checks if a given label is valid or not
        string? Is_valid_label(Instruction label)
        {
            if (label.tokens.Count == 1)
            {
                return label.tokens[0].value[..^1];
            }
            else if (label.tokens.Count == 2 && label.tokens[1].value == ":")
            {
                return label.tokens[0].value;
            }
            else
            {
                return null;
            }
        }
        // this funciton saves each label and it's value (address) so it can be used when computing the offset address in the jump and branch instructions
        private void Subtitute_labels(ref Program program)
        {
            int index = 0;
            for (int i = 0; i < program.instructions.Count; i++)
            {
                Instruction inst = program.instructions[i];
                if (inst.tokens.Any(token => token.value.Contains(':')))
                {
                    string? label = Is_valid_label(program.instructions[i]);
                    lblinvlabel |= label == null;
                    if (label != null)
                    {
                        if (!labels.TryAdd(label, index))
                            lblmultlabels |= true;
                    }
                }
                else
                    index++;
            }
            program.instructions.RemoveAll(inst => inst.tokens.Any(token => token.value.Contains(':')));
        }

        Program? TokenizeProg(List<string> thecode)
        {
            Program program = new Program();
            for (int i = 0; i < thecode.Count; i++)
            {
                m_curr_inst = thecode[i];
                Instruction? instruction = TokenizeInst();
                if (instruction.HasValue)
                {
                    program.instructions.Add(instruction.Value);
                }
                else
                {
                    return null;
                }
            }

            return program;
        }
        public Program? ASSEMBLE(List<string> in_prog)
        {
            lblINVINST = false;
            lblinvlabel = false;
            lblmultlabels = false;
            labels.Clear();

            in_prog.RemoveAll(line => string.IsNullOrEmpty(line) || string.IsNullOrWhiteSpace(line));
            m_prog = in_prog;
            m_prog.Add("HLT");
            Program? prog = TokenizeProg(m_prog);

            if (prog.HasValue)
            {
                Program program = prog.Value;
                Substitute_pseudo_insts(ref program);
                Subtitute_labels(ref program);
                List<string>? mc = GetMachineCode(ref program.instructions);
                if (mc != null)
                {
                    program.mc = mc;
                }
                else
                {
                    lblINVINST = true;
                    return null;
                }
                return program;
            }
            else
            {
                return null;
            }
        }

        public List<string> GetInstsAsText(Program program)
        {
            List<string> ret = [];
            for (int i = 0; i < program.instructions.Count; i++)
            {
                Instruction instruction = program.instructions[i];
                string mnem = instruction.tokens[0].value;
                if (mnem == "beq" || mnem == "bne")
                {
                    string LabelValue = Convert.ToInt16(program.mc[i].Substring(16), 2).ToString();
                    instruction.tokens[^1] = new Token(LabelValue);
                }
                string inst = "";
                instruction.tokens.ForEach(token => inst += token.value + " ");
                ret.Add(inst);
            }
            return ret;
        }
    }



}
