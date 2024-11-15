using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Security.Authentication;
using System.Windows.Forms;

public enum InstType
{
    rtype, itype, jtype, invalid_Inst
}

public static class ASSEMBLERMIPS
{
    public static Label lblinvlabel = new Label();
    public static Label lblmultlabels = new Label();
    public static Label lblnumofinst = new Label();
    public static Label lblinvinst = new Label();
    public static RichTextBox input = new RichTextBox();
    // The instruction type is the main token in a given instruction and should be known the first token in an instruction (first word)
    // the opcodes is a dictionary the you give it a certain opcode (in words) and get beack the binaries (or machine code) corresponding to that opcode
    // take a look to know what to expect because the binary might be different depending on the opcode some of them only opcode or with func3 or even with func7
    public static Dictionary<string, string> opcodes = new Dictionary<string, string>()//{ "inst"     , "opcode/funct" },
    {
        { "nop"  , "000000" },
        { "hlt"  , "111111" },

        // R-format , opcode = 0 // 11 + 1
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
            
        // I-format // 4 + 2 + 4
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
    public static Dictionary<string, int> labels = new Dictionary<string, int>();
    // the invInst is a string that come up when an invalid instruction is entered from the user
    public static string invinst = "Invalid Instruction";
    public static string invlbl = "Invalid Label";

    // checks for impty instruction that dont need to be tokenized or converted to machine code
    public static bool EmptyLine(string instruction)
    {
        return string.IsNullOrEmpty(instruction) || string.IsNullOrWhiteSpace(instruction);
    }

    // input : the opcode (string : in words)
    // return the Instruction type
    static InstType GetInstType(string name)
    {
        switch (name)
        {
            case "add":
            case "addu":
            case "sub":
            case "subu":
            case "and":
            case "or":
            case "xor":
            case "nor":
            case "slt":
            case "sgt":
            case "sll":
            case "srl":
            case "jr":
            case "nop":
            case "hlt":
                return InstType.rtype;
            case "addi":
            case "andi":
            case "ori":
            case "xori":
            case "slti":
            case "lw":
            case "sw":
            case "beq":
            case "bne":
                return InstType.itype;
            case "j":
            case "jal":
                return InstType.jtype;
            default:
                return InstType.invalid_Inst;
        }
    }

    // it takes as input the register name and extracts the index form it
    static string getregindex(string reg)
    {
        if (!reg.StartsWith("x"))
            return invinst;
        string index = reg.Substring(1); // x21



        if (byte.TryParse(index, out byte usb) && usb >= 0 && usb <= 31)
        {
            return Convert.ToString(usb, 2).PadLeft(5, '0');
        }
        else
            return invinst;
    }

    // the following functions are used to tokenize, parse, and then generate the corresponding machine code for every 
    // token of the instruction
    static string getrtypeinst(List<string> inst)
    {
        string mc = "";
        if (inst[0] == "jr") // jr x12
        {
            if (inst.Count != 2)
                return invinst;
            string rs1 = getregindex(inst[1]);
            if (rs1 == invinst) return invinst;
            mc = "000000" + rs1 + "000000000000000" + opcodes[inst[0]];
        }
        else
        {
            if (inst.Count != 4)
                return invinst;
            string rd = getregindex(inst[1]);
            string rs1 = getregindex(inst[2]);
            string funct = opcodes[inst[0]];

            if (rd == invinst || rs1 == invinst)
                return invinst;

            if (inst[0] == "sll" || inst[0] == "srl") // sll x1, x2, 2
            {
                string shamt = inst[3];
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
                    return invinst;
                mc = "000000"
                    + "00000"
                    + rs1
                    + rd
                    + shamt
                    + funct;
            }
            else
            {
                string rs2 = getregindex(inst[3]);
                if (rs2 == invinst)
                    return invinst;
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
    static bool isbranch(string mnem)
    {
        return mnem == "beq" || mnem == "bne";
    }
    static bool PseudoBranch(string mnem)
    {
        return mnem == "bltz" || mnem == "bgez";
    }
    static bool islogicalimmed(string mnem)
    {
        return mnem == "andi" || mnem == "ori" || mnem == "xori";
    }
    static string getitypeinst(List<string> inst)
    {
        if (inst.Count != 4)
            return invinst;
        string mc;
        string opcode = opcodes[inst[0]];


        string reg1 = getregindex(inst[1]);
        string reg2 = getregindex(inst[2]);
        if (reg1 == invinst || reg2 == invinst)
            return invinst;

        if (isbranch(inst[0]))
        {
            if (!labels.ContainsKey(inst[3]))
                return invinst;
            string immed = inst[3];
            immed = (labels[immed] - curr_inst_index).ToString();
            if (ushort.TryParse(immed, out ushort usb))
                immed = Convert.ToString(usb, 2).PadLeft(16, '0');
            else if (short.TryParse(immed, out short sb))
            {
                immed = Convert.ToString(sb, 2);
                immed = immed.PadLeft(16, immed[0]);
            }
            else
                return invinst;
            string rs1 = reg1;
            string rs2 = reg2;
            mc = opcode + rs1 + rs2 + immed;
        }
        else
        {
            // andi, ori, xori (they do zero extend)
            string immed = inst[3];
            if ((immed.StartsWith("0x") || immed.StartsWith("0X")))
            {
                short temp;
                try { temp = Convert.ToInt16(immed, 16); }
                catch { return invinst; }

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
                return invinst;
            string rd = reg1;
            string rs1 = reg2;
            mc = opcode + rs1 + rd + immed;
        }

        return mc;
    }
    static string getjtypeinst(List<string> inst)
    {
        string mc = "";

        if (inst.Count != 2 || !labels.ContainsKey(inst[1]))
            return invinst;
        int lbl = labels[inst[1]];
        string immed = Convert.ToString(lbl, 2);
        immed = immed.PadLeft(26, '0');
        mc = opcodes[inst[0]] + immed;

        return mc;
    }
    // this function takes the instructio and it's type and based on it, it passes it to the suitable fucntion to generate the machine code
    static string GetMcOfInst(InstType type, List<string> inst)
    {
        if (inst.Count > 0 && (inst[0] == "hlt" || inst[0] == "nop"))
            return opcodes[inst[0]].PadRight(32, '0');
        // here we construct the binaries of a given instruction
        switch (type)
        {
            case InstType.rtype:
                return getrtypeinst(inst);
            case InstType.itype:
                return getitypeinst(inst);
            case InstType.jtype:
                return getjtypeinst(inst);
            case InstType.invalid_Inst:
                return invinst;
            default: return invinst;
        }
    }
    static int curr_inst_index;
    // this fucntion iterates through the whole list of instruction and returns a list of the machine code for each valid instruction
    // and keep track of it's index for substituting the values of the labels
    static List<string> GetMachineCode(List<List<string>> insts)
    {
        List<string> mcs = new List<string>();
        curr_inst_index = 0;
        foreach (List<string> inst in insts)
        {
            InstType type = GetInstType(inst[0]); // addi x1, x0, 123
            string curr_mc = GetMcOfInst(type, inst);
            mcs.Add(curr_mc);
            curr_inst_index++;
        }

        return mcs;
    }
    // assmebling the program starts form here 
    // it tokenizes each non empty instruction and returns a list of parsable instruction each one of them is a list of tokens
    static private List<List<string>> Tokenize(List<string> thecode)
    {
        List<List<string>> insts = new List<List<string>>();
        foreach (string line in thecode)
        {
            // curr_inst is a list of tokens (strings)
            List<string> curr_inst = new List<string>();
            int i = 0;
        contin:
            string token = ""; // addi     x1, x0, 123   
            while (i < line.Length && line[i] != ' ' && line[i] != ',') // we consume letters
                token += line[i++];


            if (!EmptyLine(token))
            {
                if (token.Length > 1 && token[0] == '/' && token[1] == '/') // check if more than one letter and if its a comment
                    continue;
                curr_inst.Add(token.ToLower());
            }
            while (i < line.Length && (line[i] == ' ' || line[i] == ',')) i++; // consume all unwanted delimiters

            if (i < line.Length) goto contin;

            if (curr_inst.Count != 0) insts.Add(curr_inst);
        }

        subtitute_labels(insts);

        return insts;
    }
    // it checks if a given label is valid or not
    static string Is_valid_label(List<string> label)
    {
        // valid label (sdf:)
        if (label.Count == 1 && label[0].Count(x => x == ':') == 1)
            return label[0].Remove(label[0].IndexOf(':'));

        // valid label (sdf :)
        else if (label.Count == 2 && !label[0].Contains(":") && label[1] == ":")
            return label[0];

        // it is invalid
        return invlbl;
    }
    // this funciton saves each label and it's value (address) so it can be used when computing the offset address in the jump and branch instructions
    static private void subtitute_labels(List<List<string>> insts)
    {
        int index = 0;
        for (int i = 0; i < insts.Count; i++)
        {
            if (insts[i].Any(str => str.Contains(":")))
            {
                string label = Is_valid_label(insts[i]);
                lblinvlabel.Visible |= label == invlbl;
                if (label != invlbl)
                {
                    if (labels.ContainsKey(label))
                        lblmultlabels.Visible |= true;
                    else
                    {
                        labels.Add(label, index);
                    }
                }
            }
            else // if the current insts is not a label so it is an instruction
                index++;
        }

        // it removes any label from the list of instructions
        insts.RemoveAll(x => x.Any(y => y.Contains(':')));
    }

    public static (List<string>, List<List<string>>) TOP_MAIN()
    {
        lblinvinst.Visible = false;
        lblinvlabel.Visible = false;
        lblmultlabels.Visible = false;
        lblnumofinst.Text = "0";
        labels.Clear();
        
        List<string> thecode = input.Lines.ToList();
        List<List<string>> insts = new List<List<string>>();

        thecode.RemoveAll(x => (string.Empty == x || string.IsNullOrEmpty(x) || string.IsNullOrWhiteSpace(x)));

        insts = Tokenize(thecode); // example: addi x1, x9, 213
        // here we have a list of instructions that we can genrate machine code for
        if (insts.Count != 0)
        {
            List<string> mc = GetMachineCode(insts);
            if (insts.Count != mc.Count)
                throw new Exception("Instruction Count doesn't match MC Count");

            lblinvinst.Visible |= mc.Any(x => x.Contains(invinst)) || lblinvlabel.Visible || lblmultlabels.Visible;
            if (lblinvinst.Visible)
                return (new List<string>(), new List<List<string>>());

            return (mc, insts);
        }
        else
        {
            lblinvinst.Visible |= lblinvlabel.Visible || lblmultlabels.Visible;
            return (new List<string>(), new List<List<string>>());
        }
    }
}


