
struct Instruction
{

    public Instruction(Instruction inst)
    {
        mnem  = inst.mnem;
        pc    = inst.pc;
        aluop = inst.aluop;
        rs1   = inst.rs1;
        rs2   = inst.rs2;
        rd    = inst.rd;
    }
    public Instruction(Mnemonic mnem, int pc, Aluop aluop, int rd, int rs1, int rs2)
    {
        this.mnem = mnem;
        this.pc = pc;
        this.aluop = aluop;
        this.rs1 = rs1;
        this.rs2 = rs2;
        this.rd = rd;
    }
    public Mnemonic mnem;
    public Aluop aluop;
    public int pc;
    public int rs1;
    public int rs2;
    public int rd;
}
public enum Mnemonic
{
    add, sub, and, andi, or, ori, xor, xori, nor, slt, sll, srl, addi, addu, subu,
    beq, bne, bltz, bgez, j, jr, jal,
    lw, sw, nop
}
public enum Aluop
{
    addition, subtraction, and, or, xor, nor, sll, srl, slt, div
}