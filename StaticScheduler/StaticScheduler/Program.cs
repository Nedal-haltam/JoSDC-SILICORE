
using System.Text;
using Raylib_cs;
using static Raylib_cs.Raylib;
using Color = Raylib_cs.Color;
int pc = 0;
string initinst = "addi x1, x0, 1\r\naddi x2, x0, 2\r\naddi x3, x0, 3\r\naddi x4, x0, 4\r\naddi x5, x0, 5\r\naddi x6, x0, 6\r\naddi x7, x0, 7\r\naddi x8, x0, 8\r\naddi x9, x0, 9\r\naddi x10, x0, 10\n";
main();
return;

void cout(string str, params object[] args)
{
    Console.Write(str, args);
}
void coutline(string str, params object[] args)
{
    Console.WriteLine(str, args);
}
void raylib()
{
    SetConfigFlags(ConfigFlags.AlwaysRunWindow);
    InitWindow(800, 600, "VGAG");
    SetTargetFPS(0); // maximum FPS
    while (!WindowShouldClose())
    {
        DrawText($"FPS: {GetFPS()}", 0, 0, 20, Color.White);
        BeginDrawing();
        ClearBackground(Color.DarkGray);
        EndDrawing();
    }
    CloseWindow();
}
bool IsDep(Instruction a, Instruction b)
{
    bool ardn0 = a.rd != 0; // a's rd is not zero
    bool brdn0 = b.rd != 0; // b's rd is not zero

    bool RAW = ((a.rs1 == b.rd) || (a.rs2 == b.rd)) && brdn0; // read after write
    bool WAR = ((a.rd == b.rs1) || (a.rd == b.rs2)) && ardn0; // write after read
    bool WAW = a.rd == b.rd && brdn0 && ardn0; // write after write

    return RAW || WAR || WAW;
}
void PrintInstructions(List<Instruction> instructions)
{
    for (int i = 0; i < instructions.Count; i++)
    {
        Instruction inst = instructions[i];
        cout($"PC = {inst.pc,2}: {inst.mnem,3}, x{inst.rd}, x{inst.rs1}, x{inst.rs2}\n");
    }
}
StringBuilder GetInstructions(List<Instruction> instructions)
{
    StringBuilder sb = new();
    for (int i = 0; i < instructions.Count; i++)
    {
        Instruction inst = instructions[i];
        sb.Append($"{inst.mnem,3} x{inst.rd}, x{inst.rs1}, x{inst.rs2}\n");
    }
    return sb;
}
bool IsValidReg(int reg)
{
    return 0 <= reg && reg <= 31;
}
bool IsValidInput(List<string> inst)
{
    return inst.Count == 3 && inst.All(x => int.TryParse(x, out int reg) && IsValidReg(reg));
}
List<Instruction> BackWardIter(List<Instruction> instructions)
{
    if (instructions.Count == 0) return [];
    List<Instruction> scheduled = new(instructions);
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
List<Instruction> GroupMethod(List<Instruction> instructions)
{
    if (instructions.Count == 0) return [];
    List<List<Instruction>> scheduled = [];

    for (int i = 0; i < instructions.Count; i++)
    {
        Instruction temp = new(instructions[i]);
        if (scheduled.Count == 0)
        {
            scheduled.Add([temp]);
            continue;
        }

        for (int j = scheduled.Count - 1; j >= 0; j--) // for every group
        {
            bool dep = false;
            for (int k = 0; k < scheduled[j].Count; k++) // for every instruction in that group
            {
                if (IsDep(temp, scheduled[j][k]))
                {
                    dep = true;
                    break;
                }
            }
            if (dep)
            {
                if (j == scheduled.Count - 1)
                {
                    scheduled.Add([temp]);
                }
                else
                {
                    scheduled[j + 1].Add(temp);
                }
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
    List<Instruction> ret = [];
    foreach (List<Instruction> group in scheduled)
    {
        foreach (Instruction inst in group)
        {
            Instruction toadd = new(inst)
            {
                pc = count++
            };
            ret.Add(toadd);
        }
    }
    return ret;
}
List<Instruction> GetRandomInsts(int N)
{
    List<Instruction> instructions = [];
    for (int i = 0; i < N; i++)
    {
        int rd = Random.Shared.Next(0, 32);
        int rs1 = Random.Shared.Next(0, 32);
        int rs2 = Random.Shared.Next(0, 32);
        Instruction newinst = new(Mnemonic.add, i, Aluop.addition, rd, rs1, rs2);
        instructions.Add(new(newinst));
    }

    return instructions;
}
bool IsInstEqual(Instruction a, Instruction b)
{
    return a.mnem == b.mnem &&
    a.pc == b.pc &&
    a.aluop == b.aluop &&
    a.rs1 == b.rs1 &&
    a.rs2 == b.rs2 &&
    a.rd == b.rd;
}
(Instruction, string) GetUserInst()
{
    string? input = Console.ReadLine();
    if (input == null)
    {
        return (new(), "error: invalid registers");
    }
    if (input == "finish")
    {
        return (new(), "finish");
    }
    List<string> inst = [.. input.Split(" ")];
    if (input == "done")
    {
        return (new(), "done");
    }
    if (!IsValidInput(inst))
    {
        return (new(), "error: invalid registers");
    }
    Instruction newinst = new(Mnemonic.add, pc++, Aluop.addition, Convert.ToInt32(inst[0]),
                                                                  Convert.ToInt32(inst[1]),
                                                                  Convert.ToInt32(inst[2]));
    return (newinst, "");
}
void WriteInstsToFile(List<Instruction> instructions, string FilePath)
{
    File.WriteAllText(FilePath, GetInstructions(instructions).ToString());
}
void Schedule(List<Instruction> instructions, string Folder)
{
    List<Instruction> backward = BackWardIter(instructions);
    List<Instruction> grouped = GroupMethod(instructions);

    string OrigPath = $"C:\\Users\\Lenovo\\Desktop\\StaticSchedulerOutput\\{Folder}\\orig.txt";
    WriteInstsToFile(instructions, OrigPath);
    string BackWardPath = $"C:\\Users\\Lenovo\\Desktop\\StaticSchedulerOutput\\{Folder}\\backward.txt";
    WriteInstsToFile(backward, BackWardPath);
    string GroupedPath = $"C:\\Users\\Lenovo\\Desktop\\StaticSchedulerOutput\\{Folder}\\grouped.txt";
    WriteInstsToFile(grouped, GroupedPath);
}
void main()
{
    //raylib();
    // TODO: check what dependencies to consider when scheduling
    List<Instruction> instructions = [];

    // this results in 9 cycles
    instructions = [new(Mnemonic.addi, 0, Aluop.addition, 1, 0, 0),
                    new(Mnemonic.addi, 0, Aluop.addition, 2, 0, 0),
                    new(Mnemonic.lw, 0, Aluop.addition, 1, 0, 0),
                    new(Mnemonic.beq, 0, Aluop.addition, 0, 1, 0)
                    ];
    //PrintInstructions(instructions);
    Schedule(instructions, "Testone");

    // this results in 8 cycles
    (instructions[2], instructions[1]) = (instructions[1], instructions[2]);
    //PrintInstructions(instructions);
    Schedule(instructions, "Testtwo");


}
/*
addi x1, x0, 1
addi x2, x0, 3
lw x1, x0, 0
beq x1, x0, l
l:
*/
