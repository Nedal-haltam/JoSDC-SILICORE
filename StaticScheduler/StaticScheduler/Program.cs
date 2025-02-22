using System;
using System.Collections.Generic;
using System.IO;

public enum Aluop
{
    addition, subtraction, and, or, xor, sll, srl, slt, sgt
}

public enum Mnemonic
{
    BEQ, BNE, BLTZ, BGEZ, J, JR, JAL, ADD, ADDI, ADDU, SUB, SUBU,
    AND, ANDI, OR, ORI, XOR, XORI, NOR, SRL, SLL, SLT, SLTI, SGT, LW, SW
}

public class Instruction
{
    public Mnemonic mnem;
    public int pc;
    public Aluop aluop;
    public int rd, rs1, rs2;

    public Instruction(Mnemonic mnem, int pc, Aluop aluop, int rd, int rs1, int rs2)
    {
        this.mnem = mnem;
        this.aluop = aluop;
        this.pc = pc;
        this.rd = rd;
        this.rs1 = rs1;
        this.rs2 = rs2;
    }
}

class Program
{
    static int pc = 0; // Reset counter for each new instruction

    static void Main()
    {
        List<Instruction> instructions = new List<Instruction>
        {
            new Instruction(Mnemonic.ADDI, pc++, Aluop.addition, 1, 0, 0),
            new Instruction(Mnemonic.ADDI, pc++, Aluop.addition, 2, 0, 0),
            new Instruction(Mnemonic.LW, pc++, Aluop.addition, 1, 0, 0),
            new Instruction(Mnemonic.BEQ, pc++, Aluop.addition, 0, 1, 0),
        };

        PrintInstructions(instructions);
        Schedule(instructions, "TestOutput");

        Console.WriteLine("\r");

        string filePath1 = @"C:";
        if (File.Exists(filePath1))
        {
            List<Instruction> backward = ReadInstructionsFromFile(filePath1);
            PrintInstructions(backward);
        }

        Console.WriteLine("\r");

        string filePath2 = @"C:";
        if (File.Exists(filePath2))
        {
            List<Instruction> grouped = ReadInstructionsFromFile(filePath2);
            PrintInstructions(grouped);
        }
    }

    static List<Instruction> ReadInstructionsFromFile(string filePath)
    {
        List<Instruction> instructions = new List<Instruction>();
        string[] lines = File.ReadAllLines(filePath);
        foreach (string line in lines)
        {
            string[] parts = line.Split(new[] { ' ', ',', ':' }, StringSplitOptions.RemoveEmptyEntries);

            if (parts.Length == 4)
            {
                string mnem = parts[0];
                int rd = int.Parse(parts[1].Substring(1));
                int rs1 = int.Parse(parts[2].Substring(1));
                int rs2 = int.Parse(parts[3].Substring(1));

                Aluop aluop = GetAluopFromMnemonic(mnem);
                Mnemonic mnemonic = GetMnemonicFromString(mnem);
                instructions.Add(new Instruction(mnemonic, instructions.Count, aluop, rd, rs1, rs2));
            }
        }
        return instructions;
    }

    static Aluop GetAluopFromMnemonic(string mnem)
    {
        switch (mnem)
        {
            case "ADD": return Aluop.addition;
            case "SUB": return Aluop.subtraction;
            case "AND": return Aluop.and;
            case "OR": return Aluop.or;
            case "XOR": return Aluop.xor;
            case "SLL": return Aluop.sll;
            case "SRL": return Aluop.srl;
            case "SLT": return Aluop.slt;
            case "SGT": return Aluop.sgt;
            default: return Aluop.addition; // Default case
        }
    }

    static Mnemonic GetMnemonicFromString(string mnem)
    {
        return Enum.TryParse(mnem, out Mnemonic result) ? result : Mnemonic.ADD; // Default case
    }

    static void Schedule(List<Instruction> instructions, string folder)
    {
        List<Instruction> backwardScheduled = BackWardIter(instructions);
        List<Instruction> groupedScheduled = GroupMethod(instructions);

        if (!Directory.Exists(folder))
        {
            Directory.CreateDirectory(folder);
        }

        WriteInstsToFile(instructions, Path.Combine(folder, "orig.txt"));
        WriteInstsToFile(backwardScheduled, Path.Combine(folder, "backward.txt"));
        WriteInstsToFile(groupedScheduled, Path.Combine(folder, "grouped.txt"));
    }

    static List<Instruction> BackWardIter(List<Instruction> instructions)
    {
        List<Instruction> scheduled = new List<Instruction>(instructions);
        bool nodep = true;

        while (nodep)
        {
            for (int i = scheduled.Count - 1; i >= 0; i--)
            {
                nodep = false;
                Instruction temp = scheduled[i];
                int DestIndex = i;

                for (int j = i - 1; j >= 0; j--)
                {
                    if (IsDep(temp, scheduled[j]))
                    {
                        break;
                    }
                    else
                    {
                        nodep = true;
                        DestIndex = j;
                    }
                }

                scheduled.RemoveAt(i);
                scheduled.Insert(DestIndex, temp);
                for (int j = 0; j < scheduled.Count; j++)
                {
                    Instruction oldpcinst = scheduled[j];
                    oldpcinst.pc = j;
                    scheduled[j] = oldpcinst;
                }
            }
        }

        return scheduled;
    }

    static List<Instruction> GroupMethod(List<Instruction> instructions)
    {
        List<List<Instruction>> scheduled = new List<List<Instruction>>();

        for (int i = 0; i < instructions.Count; i++)
        {
            Instruction temp = new Instruction(instructions[i].mnem, instructions[i].pc, instructions[i].aluop,
                                               instructions[i].rd, instructions[i].rs1, instructions[i].rs2);
            if (scheduled.Count == 0)
            {
                scheduled.Add(new List<Instruction> { temp });
                continue;
            }

            bool dep = false;
            for (int j = scheduled.Count - 1; j >= 0; j--)
            {
                for (int k = 0; k < scheduled[j].Count; k++)
                {
                    if (IsDep(temp, scheduled[j][k]))
                    {
                        dep = true;
                        break;
                    }
                }

                if (dep)
                {
                    scheduled[j].Add(temp);
                    break;
                }
                else if (j == 0)
                {
                    scheduled[j].Add(temp);
                    break;
                }
            }
        }

        int count = 0;
        List<Instruction> ret = new List<Instruction>();

        foreach (List<Instruction> group in scheduled)
        {
            foreach (Instruction inst in group)
            {
                inst.pc = count++;
                ret.Add(inst);
            }
        }

        return ret;
    }

    static bool IsDep(Instruction a, Instruction b)
    {
        bool ardn0 = a.rd != 0;
        bool brdn0 = b.rd != 0;

        bool RAW = ((a.rs1 == b.rd) || (a.rs2 == b.rd)) && brdn0;
        bool WAR = ((a.rd == b.rs1) || (a.rd == b.rs2)) && ardn0;
        bool WAW = (a.rd == b.rd) && ardn0 && brdn0;

        return RAW || WAR || WAW;
    }

    static void PrintInstructions(List<Instruction> instructions)
    {
        foreach (var inst in instructions)
        {
            Console.WriteLine($"PC = {inst.pc,2}: {inst.mnem,3}, x{inst.rd}, x{inst.rs1}, x{inst.rs2}");
        }
    }

    static void WriteInstsToFile(List<Instruction> instructions, string filePath)
    {
        string folder = Path.GetDirectoryName(filePath);
        if (!Directory.Exists(folder))
        {
            Directory.CreateDirectory(folder);
        }
        using (StreamWriter writer = new StreamWriter(filePath))
        {
            foreach (var inst in instructions)
            {
                writer.WriteLine($"{inst.mnem} x{inst.rd}, x{inst.rs1}, x{inst.rs2}");
            }
        }
    }
}
