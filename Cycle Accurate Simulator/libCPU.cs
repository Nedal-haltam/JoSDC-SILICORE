using static ProjectCPUCL.Macros;
using static ProjectCPUCL.MIPS;

namespace ProjectCPUCL
{
    public static class Macros
    {
        public static void cout(string str, params object[] args)
        {
            Console.WriteLine(str, args);
        }
    }
    public static class MIPS
    {
        public static string nop = "00000000000000000000000000000000";
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
        public struct Instruction
        {
            public Instruction()
            {
                mc = "";
                mc = mc.PadLeft(32, '0');
                opcode = "000000";
                shamt = "00000";
                format = "R";
                funct = "000000";
                mnem = Mnemonic.nop;
                aluop = 0;
                rsind = 0;
                rtind = 0;
                rdind = 0;
                address = 0;
                immeds = 0;
                immedz = 0;
                PC = 0;
                rs = 0;
                rt = 0;
                oper1 = 0;
                oper2 = 0;
                aluout = 0;
                memout = 0;
            }
            public string mc;
            public string opcode;
            public int rsind;
            public int rtind;
            public int rdind;
            public string shamt;
            public string funct;
            public int address;
            public int immeds;
            public int immedz;

            public Mnemonic mnem;
            public int PC;
            public int rs;
            public int rt;
            public int oper1;
            public int oper2;
            public Aluop aluop;
            public string format;
            public int aluout;
            public int memout;
        }

        public enum Stage
        {
            fetch, decode, execute, memory, write_back
        }

        public static readonly Dictionary<string, Mnemonic> mnemonicmap = new()
            {
                // R-format depends on the funct field, if opcode = "000000" then it is R-format else (it is an I-format or J-format either way it depends on distinct opcodes)
                // rd = rd, rs1 = rs, rs2 = rt
                { "0100000" , Mnemonic.add  }, // R[rd] = R[rs] op R[rt] , 0x20
                { "0100001" , Mnemonic.addu }, // R[rd] = R[rs] op R[rt] , 0x21
                { "0100010" , Mnemonic.sub  }, // R[rd] = R[rs] op R[rt] , 0x22
                { "0100011" , Mnemonic.subu }, // R[rd] = R[rs] op R[rt] , 0x23
                { "0100100" , Mnemonic.and  }, // R[rd] = R[rs] op R[rt] , 0x24
                { "0100101" , Mnemonic.or   }, // R[rd] = R[rs] op R[rt] , 0x25
                { "0100110" , Mnemonic.xor  }, // R[rd] = R[rs] op R[rt] , 0x26
                { "0100111" , Mnemonic.nor  }, // R[rd] = R[rs] op R[rt] , 0x27
                { "0101010" , Mnemonic.slt  }, // R[rd] = R[rs] op R[rt] , 0x2a
                { "0000000" , Mnemonic.sll  }, // R[rd] = R[rs] op shamt , 0x00
                { "0000010" , Mnemonic.srl  }, // R[rd] = R[rs] op shamt , 0x02
                { "0001000" , Mnemonic.jr   }, // PC = R[rs] (here we jump to the instruciont in the IM addressed by R[rs]) , 0x08

                // I-format depends on the opcode field
                // rd = rt, rs1 = rs, rs2 = rt, immed = immed or addr
                { "1001000" , Mnemonic.addi }, // R[rt] = R[rs] op sx(immed) , 0x48
                { "1001100" , Mnemonic.andi }, // R[rt] = R[rs] op zx(immed) , 0x4c
                { "1001101" , Mnemonic.ori  }, // R[rt] = R[rs] op zx(immed) , 0x4d
                { "1001110" , Mnemonic.xori }, // R[rt] = R[rs] op zx(immed) , 0x4e
                { "1100011" , Mnemonic.lw   }, // R[rt] = Mem[R[rs]+sx(immed)] , 0x63
                { "1101011" , Mnemonic.sw   }, // Mem[R[rs]+sx(immed)]=R[rt] , 0x6b
                // rs1 = rs, rs2 = rt
                { "1000100" , Mnemonic.beq  }, // if (R[rs] op R[rt]) -> PC += sx(offset) << 2  , note.1 , 0x44
                { "1000101" , Mnemonic.bne  }, // if (R[rs] op R[rt]) -> PC += sx(offset) << 2  , note.1 , 0x45
                { "1010000" , Mnemonic.bltz }, // if (R[rs] op R[rt]) -> PC += sx(offset) << 2  , note.1 , 0x50
                { "1010001" , Mnemonic.bgez }, // if (R[rs] op R[rt]) -> PC += sx(offset) << 2  , note.1 , 0x51
                // J-format depends on opcode field
                { "1000010" , Mnemonic.j    }, // PC = zx(addr) << 2  , note.1 , 0x42
                { "1000011" , Mnemonic.jal  }, // R[31] = PC+1, PC = zx(addr) << 2  , note.1 , 0x43
            };
        // note.1 : apparently the shift left by 2 is optional because because the IM may be word addressable rather than byte addressable.
        // in other words if the IM was byte addressable each location holds one of four bytes of an instruction and when we do a branch for example the offset by it self
        // represents how many instruction is the target address away from it so we shift left by 2 (multiply by four) so we can account for each byte in the IM (given that each
        // instrution is four bytes and it is the case here)...
        // BUT if the IM is word addressable and the size of the word depends on the architecture in our case it's 32-bit (four bytes), we won't need to shift because each
        // location is alread four bytes and holding a whole instruction
        public static Aluop get_inst_aluop(Mnemonic mnem)
        {
            return mnem switch
            {
                Mnemonic.add  => Aluop.addition,
                Mnemonic.sub  => Aluop.subtraction,
                Mnemonic.and  => Aluop.and,
                Mnemonic.andi => Aluop.and,
                Mnemonic.or   => Aluop.or,
                Mnemonic.ori  => Aluop.or,
                Mnemonic.xor  => Aluop.xor,
                Mnemonic.xori => Aluop.xor,
                Mnemonic.nor  => Aluop.nor,
                Mnemonic.slt  => Aluop.slt,
                Mnemonic.sll  => Aluop.sll,
                Mnemonic.srl  => Aluop.srl,
                Mnemonic.addi => Aluop.addition,
                Mnemonic.addu => Aluop.addition,
                Mnemonic.subu => Aluop.subtraction,
                Mnemonic.beq  => Aluop.addition,
                Mnemonic.bne  => Aluop.addition,
                Mnemonic.bltz => Aluop.addition,
                Mnemonic.bgez => Aluop.addition,
                Mnemonic.j    => Aluop.addition,
                Mnemonic.jr   => Aluop.addition,
                Mnemonic.jal  => Aluop.addition,
                Mnemonic.lw   => Aluop.addition,
                Mnemonic.sw   => Aluop.addition,
                _ => 0,
            };
        }
        public static string get_format(Mnemonic mnem)
        {
            return mnem switch
            {
                 Mnemonic.add  => "R",
                 Mnemonic.sub  => "R",
                 Mnemonic.and  => "R",
                 Mnemonic.andi => "I",
                 Mnemonic.or   => "R",
                 Mnemonic.ori  => "I",
                 Mnemonic.xor  => "R",
                 Mnemonic.xori => "I",
                 Mnemonic.nor  => "R",
                 Mnemonic.slt  => "R",
                 Mnemonic.sll  => "R",
                 Mnemonic.srl  => "R",
                 Mnemonic.addi => "I",
                 Mnemonic.addu => "R",
                 Mnemonic.subu => "R",
                 Mnemonic.beq  => "I",
                 Mnemonic.bne  => "I",
                 Mnemonic.bltz => "I",
                 Mnemonic.bgez => "I",
                 Mnemonic.j    => "J",
                 Mnemonic.jr   => "R",
                 Mnemonic.jal  => "J",
                 Mnemonic.lw   => "I",
                 Mnemonic.sw   => "I",
                 _             => "" ,
            };
        }
        public static int execute_inst(Instruction inst)
        {
            return inst.aluop switch
            {
                Aluop.addition    =>   inst.oper1  +  inst.oper2,
                Aluop.subtraction =>   inst.oper1  -  inst.oper2,
                Aluop.and         =>   inst.oper1  &  inst.oper2,
                Aluop.or          =>   inst.oper1  |  inst.oper2,
                Aluop.xor         =>   inst.oper1  ^  inst.oper2,
                Aluop.nor         => ~(inst.oper1  |  inst.oper2),
                Aluop.slt         =>  (inst.oper1  <  inst.oper2) ? 1 : 0,
                Aluop.sll         =>   inst.oper1 <<  inst.oper2,
                Aluop.srl         =>   inst.oper1 >>> inst.oper2,
                _ => throw new Exception($"Invalid aluop provided : {inst.aluop}"),
            };
        }
        public static bool iswb(Mnemonic mnem)
        {
            return mnem switch
            {
                Mnemonic.add  => true,
                Mnemonic.sub  => true,
                Mnemonic.and  => true,
                Mnemonic.andi => true,
                Mnemonic.or   => true,
                Mnemonic.ori  => true,
                Mnemonic.xor  => true,
                Mnemonic.xori => true,
                Mnemonic.nor  => true,
                Mnemonic.slt  => true,
                Mnemonic.sll  => true,
                Mnemonic.srl  => true,
                Mnemonic.addi => true,
                Mnemonic.addu => true,
                Mnemonic.subu => true,
                Mnemonic.beq  => false,
                Mnemonic.bne  => false,
                Mnemonic.bltz => false,
                Mnemonic.bgez => false,
                Mnemonic.j    => false,
                Mnemonic.jr   => false,
                Mnemonic.jal  => true,
                Mnemonic.lw   => true,
                Mnemonic.sw   => false,
                _ => false,
            };
        }
        public static bool isbranch(Mnemonic mnem)
        {
            return mnem == Mnemonic.beq || mnem == Mnemonic.bgez ||
                mnem == Mnemonic.bltz || mnem == Mnemonic.bne;
        }
        public static int get_oper1(Instruction inst)
        {
            if (inst.format == "R")
            {
                if (inst.mnem == Mnemonic.sll || inst.mnem == Mnemonic.srl)
                    return inst.rt;
                return inst.rs;
            }
            if (inst.format == "I")
            {
                return inst.rs;
            }
            if (inst.format == "J")
                return inst.PC + 1;
            throw new Exception($"Invalid format provided : {inst.format}");
        }
        public static bool islogical(Mnemonic mnem)
        {
            return mnem == Mnemonic.andi || mnem == Mnemonic.ori || mnem == Mnemonic.xori;
        }
        public static int get_oper2(Instruction inst)
        {
            if (inst.format == "R")
            {
                if (inst.mnem == Mnemonic.sll || inst.mnem == Mnemonic.srl)
                    return Convert.ToInt32(zx(inst.shamt), 2);
                if (inst.mnem == Mnemonic.jr)
                    return 0;
                return inst.rt;
            }
            if (inst.format == "I")
            {
                if (islogical(inst.mnem))
                    return inst.immedz;
                else if (isbranch(inst.mnem))
                    return inst.rt;
                return inst.immeds;
            }
            if (inst.format == "J")
            {
                return 0;
            }
            throw new Exception($"Invalid format provided : {inst.format}");
        }
        public static string sx(string num)
        {
            return num.PadLeft(32, num[0]);
        }
        public static string zx(string num)
        {
            return num.PadLeft(32, '0');
        }
        public static void print_regs(List<int> regs)
        {
            cout("Register file content : ");
            int i = 0;
            foreach (int n in regs)
            {
                if (i == 11) break;
                cout($"index = {i++,2} , signed = {n,10} , unsigned = {(uint)n,10}");
            }
        }
        public static void print_DM(List<string> DM)
        {
            cout("Data Memory Conten : ");
            int i = 0;
            foreach (string mem in DM)
            {
                if (i == 20) break;
                int n = Convert.ToInt32(DM[i], 2);
                cout($"index = {i++,2} , signed = {n,10} , unsigned = {(uint)n,10}");
            }
        }
        public static bool isvalid_format(string format)
        {
            return format == "R" || format == "I" || format == "J";
        }
        public static bool is_in_range_inc(int x, int lo, int hi)
        {
            return lo <= x && x <= hi;
        }
        public static bool isvalid_reg_ind(Instruction inst)
        {
            return is_in_range_inc(inst.rsind, 0, 32) &&
                   is_in_range_inc(inst.rtind, 0, 32) &&
                   is_in_range_inc(inst.rdind, 0, 32);
        }
        public static bool isvalid_opcode_funct(Instruction inst)
        {
            return (inst.format == "R") ? mnemonicmap.ContainsKey("0" + inst.funct) : mnemonicmap.ContainsKey("1" + inst.opcode);
        }


    }

    public class CPU5STAGE
    {   // TODO: -write the instruction beside the mc when pasting it (not necessary for the real time app)
        //       -log the info of the run every time you run the cpu on the given instructions (necessary for the real time app) make a btn for that
        //       -implement floating point (in terms of reg file and FP ALU) and do it in the FLBAL CPU
        //       -modify the HANDLER address to a suitable location in the instruction memory
        int PC;
        bool hlt;
        public List<string> IM; // Instruction Mem
        public static int HANDLER_ADDR;
        public List<int> regs;
        public List<string> DM; // Data Mem

        Instruction IFID;
        Instruction IDEX;
        Instruction EXMEM;
        Instruction MEMWB;

        Instruction memed_in_MEM_MIPS;
        Instruction executed_in_EX_MIPS;
        Instruction decoded_in_ID_MIPS;
        string fetched_in_IF_MIPS;
        
        int ID_HAZ;
        int EX_HAZ;
        int MEM_HAZ;
        enum PCsrc
        {
            nextpc, pfc, exception
        }
        PCsrc pcsrc;
        public CPU5STAGE(List<string>? insts = null)
        {
            regs = [];
            for (int i = 0; i < 32; i++) regs.Add(0);
            IM = (insts == null) ? [] : (List<string>)insts;
            DM = [];
            for (int i = 0; i < 1024; i++) DM.Add("0");
            PC = -1;
            hlt = false;
            IFID = new();
            IDEX  = new();
            EXMEM = new();
            MEMWB = new();
            memed_in_MEM_MIPS = new();
            executed_in_EX_MIPS = new();
            decoded_in_ID_MIPS  = new();
            fetched_in_IF_MIPS = "";
            ID_HAZ  = 0;
            EX_HAZ  = 0;
            MEM_HAZ = 0;
            HANDLER_ADDR = IM.Count - 1;
        }
        int forward(int n, int source_ind, int source_reg)
        {
            if (IDEX.rdind != 0 && iswb(IDEX.mnem) && IDEX.rdind == source_ind && n > 2 && IDEX.mnem == Mnemonic.lw)
            {
                Exception e = new("stall")
                {
                    Source = "jrBALstall"
                };
                throw e;
            }
            // ID haz
            if (IDEX.rdind != 0 && iswb(IDEX.mnem) && IDEX.rdind == source_ind && n > 2)
            {
                return ID_HAZ;
            }
            // EX haz
            else if (EXMEM.rdind != 0 && iswb(EXMEM.mnem) && EXMEM.rdind == source_ind && n > 1)
            {
                return EX_HAZ;
            }
            // MEM haz
            else if (MEMWB.rdind != 0 && iswb(MEMWB.mnem) && MEMWB.rdind == source_ind && n > 0)
            {
                return MEM_HAZ;
            }
            return source_reg;
        }
        void update_PC(Instruction inst)
        {
            if (pcsrc == PCsrc.nextpc)
            {
                PC += 1;
            }
            else if (pcsrc == PCsrc.pfc)
            {
                if (isbranch(inst.mnem))
                {
                    PC = (inst.PC + inst.immeds);
                }
                else if (inst.mnem == Mnemonic.j || inst.mnem == Mnemonic.jal)
                {
                    PC = inst.address;
                }
                else if (inst.mnem == Mnemonic.jr)
                {
                    inst.rs = forward(3, inst.rsind, inst.rs);
                    PC = inst.rs;
                }
            }
        }
        Instruction decodemc(string mc, int pc)
        {
            if (mc == nop)
            {
                return new Instruction();
            }
            Instruction inst = new()
            {
                mc = mc,
                PC = pc,
                opcode = mc[^(1 + 31)..^26],
                rsind = Convert.ToInt32(mc[^(1 + 25)..^21], 2),
                rtind = Convert.ToInt32(mc[^(1 + 20)..^16], 2),
                rdind = Convert.ToInt32(mc[^(1 + 15)..^11], 2),
                shamt = mc[^(1 + 10)..^6],
                funct = mc[^(1 + 5)..^0],
                immeds = Convert.ToInt32(sx(mc[^(1 + 15)..^0]), 2),
                immedz = Convert.ToInt32(zx(mc[^(1 + 15)..^0]), 2),
                address = Convert.ToInt32(zx(mc[^(1 + 25)..^0]), 2)
            };
            // mips integer instruction map for formats (R, I, J)
            inst.rs = regs[inst.rsind];
            inst.rt = regs[inst.rtind];

            string opcode;
            if (inst.opcode == "000000") 
                opcode = "0" + inst.funct;
            else
                opcode = "1" + inst.opcode;
            if (!mnemonicmap.TryGetValue(opcode, out Mnemonic value))
            {
                Exception e = new("Exception detected")
                {
                    Source = "exception",
                    HResult = 1
                };
                throw e;
            }
            else
                inst.mnem = value;

            inst.aluop  = get_inst_aluop(inst.mnem);
            inst.format = get_format(inst.mnem);
            inst.oper1  = get_oper1(inst);
            inst.oper2  = get_oper2(inst);
            if (inst.format == "I")
            {
                inst.rdind = inst.rtind;
            }
            if (inst.format == "J")
            {
                inst.rdind = 31;
            }
            return inst;
        }
        void comparator(Instruction decoded)
        {
            pcsrc = PCsrc.nextpc;
            if (!isbranch(decoded.mnem))
            {
                if (decoded.mnem == Mnemonic.j || decoded.mnem == Mnemonic.jal || decoded.mnem == Mnemonic.jr)
                    pcsrc = PCsrc.pfc;
                return;
            }
            int comp_oper1 = decoded.oper1;
            int comp_oper2 = decoded.oper2;

            
            comp_oper1 = forward(3, decoded.rsind, comp_oper1);
            comp_oper2 = forward(3, decoded.rtind, comp_oper2);

            if (decoded.mnem == Mnemonic.beq)
            {
                pcsrc = (comp_oper1 == comp_oper2) ? PCsrc.pfc : PCsrc.nextpc;
            }
            else if (decoded.mnem == Mnemonic.bne)
            {
                pcsrc = (comp_oper1 != comp_oper2) ? PCsrc.pfc : PCsrc.nextpc;
            }
            else if (decoded.mnem == Mnemonic.bltz)
            {
                pcsrc = (comp_oper1 < comp_oper2) ? PCsrc.pfc : PCsrc.nextpc;
            }
            else if (decoded.mnem == Mnemonic.bgez)
            {
                pcsrc = (comp_oper1 >= comp_oper2) ? PCsrc.pfc : PCsrc.nextpc;
            }
            else
                throw new Exception($"invalid branch instruction : {decoded.mnem}");
        }
        string fetch()
        {
            string fetched = "";
            if (PC >= IM.Count) return fetched.PadLeft(32, '0');
            fetched = IM[PC];
            return fetched;
        }
        Instruction decode(string fetched)
        {
            Instruction decoded = decodemc(fetched, PC);
            comparator(decoded);
            update_PC(decoded);
            detect_exception(decoded, Stage.decode);
            return decoded;
        }
        Instruction execute(Instruction decoded)
        {
            Instruction temp = decoded;
            if (decoded.mnem == Mnemonic.nop)
            {
                ID_HAZ = 0;
                return temp;
            }
            if (temp.format == "R")
            {
                temp.oper1 = forward(2, temp.rsind, temp.oper1);
                temp.oper2 = forward(2, temp.rtind, temp.oper2);
            }
            else if (temp.format == "I")
            {
                temp.oper1 = forward(2, temp.rsind, temp.oper1);
                // we will update the second operand if the instruction uses them 
                // (i.e. when it's an I-format and sw)
                if (temp.mnem == Mnemonic.sw)
                {
                    temp.rt = forward(2, temp.rtind, temp.rt);
                }
            }
            detect_exception(decoded, Stage.execute);
            temp.aluout = execute_inst(temp);
            ID_HAZ = temp.aluout;
            return temp;
        }
        Instruction mem(Instruction inst)
        {
            Instruction temp = inst;
            if (inst.mnem == Mnemonic.nop)
            {
                EX_HAZ = 0;
                return temp;
            }
            detect_exception(inst, Stage.memory);
            if (temp.mnem == Mnemonic.lw)
            {
                temp.memout = Convert.ToInt32(DM[temp.aluout], 2);
            }
            else if (temp.mnem == Mnemonic.sw)
            {
                DM[temp.aluout] = Convert.ToString(temp.rt, 2).PadLeft(32, '0');
            }

            if (temp.mnem == Mnemonic.lw)
                EX_HAZ = temp.memout;
            else
                EX_HAZ = temp.aluout;

            return temp;
        }
        void write_back(Instruction inst)
        {
            if (inst.mnem == Mnemonic.nop)
            {
                MEM_HAZ = 0;
                return;
            }
            if (!iswb(inst.mnem) || inst.rdind == 0)
                return;
            detect_exception(inst, Stage.write_back);
            regs[inst.rdind] = (inst.mnem == Mnemonic.lw) ? inst.memout : inst.aluout;
            MEM_HAZ = (inst.mnem == Mnemonic.lw) ? inst.memout : inst.aluout;
        }
        void handle_exception(Exception e)
        {
            // TODO: should we update the ID_HAZ, EX_HAZ, MEM_HAZ
            PC = HANDLER_ADDR;
            IFID.mc = fetch();
            IDEX = new();
            if ((Stage)e.HResult == Stage.decode)
            {
                MEMWB = memed_in_MEM_MIPS;
                EXMEM = executed_in_EX_MIPS;
            }
            else if ((Stage)e.HResult == Stage.execute)
            {
                MEMWB = memed_in_MEM_MIPS;
                EXMEM = new();
                ID_HAZ = 0;
            }
            else if ((Stage)e.HResult == Stage.memory || (Stage)e.HResult == Stage.write_back) // made them in a single if condition because they have the same effect in an exception case
            {
                MEMWB = new();
                EXMEM = new();
                ID_HAZ = 0;
                EX_HAZ = 0;
                MEM_HAZ = ((Stage)e.HResult == Stage.write_back) ? 0 : MEM_HAZ;
            }
            //else if ((Stage)e.HResult == Stage.write_back)
            //{
            //    MEMWB = new();
            //    EXMEM = new();
            //}
        }
        void detect_exception(Instruction inst, Stage stage)
        {
            if (PC == IM.Count) hlt = true;
            Exception e = new("Exception detected")
            {
                Source = "exception",
                HResult = (int)stage
            };
            if (stage == Stage.decode)
            {
                // detect if there is an exception in the decode operation in the decode stage
                if (!isvalid_opcode_funct(inst) || !isvalid_format(inst.format))
                {
                    throw e;
                }
                if (isbranch(inst.mnem) || inst.mnem == Mnemonic.j || inst.mnem == Mnemonic.jal || inst.mnem == Mnemonic.jr)
                {
                    if (!is_in_range_inc(PC, 0, IM.Count - 1) && !hlt)
                        throw e;
                }
            }
            else if (stage == Stage.execute)
            {
                // detect if there is an exception in the execution of the instruction in the execute stage (/0)
                if (inst.oper2 == 0 && inst.aluop == Aluop.div)
                {
                    throw e;
                }
            }
            else if (stage == Stage.memory)
            {
                // detect if there is an exception in the memory operation in the mem stage (invalid address)
                if ((inst.mnem == Mnemonic.lw || inst.mnem == Mnemonic.sw) && !is_in_range_inc(inst.aluout, 0, DM.Count - 1))
                {
                    throw e;
                }
            }
            else if (stage == Stage.write_back)
            {
                // detect if there is an exception in the write back to the reg file in the wb stage (invalid reg or control signals)
                if (!isvalid_reg_ind(inst))
                {
                    throw e;
                }
            }

            return;
        }
        void ConsumeInst()
        {
            // here is the bulk of going through a complete cycle in the whole pipelined CPU
            try
            {
                write_back(MEMWB);
                memed_in_MEM_MIPS = mem(EXMEM);
                executed_in_EX_MIPS = execute(IDEX);
                decoded_in_ID_MIPS = decode(IFID.mc);
                fetched_in_IF_MIPS = fetch();
            }
            catch (Exception e)
            {
                if (e.Source == "exception")
                {
                    handle_exception(e);
                    return;
                }
                else if (e.Source == "jrBALstall")
                {
                    // this is effectively how you would insert a nop in the pipeline in the case of (jr or branch) after load
                    MEMWB = memed_in_MEM_MIPS;
                    EXMEM = executed_in_EX_MIPS;
                    IDEX = new(); // the nop into the execution stage (aka. IDEX buffer)
                    return; // and then return and not fetch a new instruction
                }
            }
            // we update the buffers all together like this because we need to forward any value if there was a hazard
            MEMWB = memed_in_MEM_MIPS;
            EXMEM   = executed_in_EX_MIPS;
            IDEX    = decoded_in_ID_MIPS;
            IFID.mc = fetched_in_IF_MIPS;
        }
        public int Run(int? n = null)
        {
            int i = 0;
            while (PC - 3 < IM.Count)
            {
                i++;
                ConsumeInst();
                if (i == 1_000_000)
                {
                    return -2;
                }
            }
            return i;
        }
        public void print_regs()
        {
            MIPS.print_regs(regs);
        }
        public void print_DM()
        {
            MIPS.print_DM(DM);
        }
    }

    public class SingleCycle
    {
        public List<int> regs;
        public List<string> IM; // Instruction Mem
        public int PC;
        public List<string> DM; // Data Mem
        public SingleCycle(List<string>? insts = null)
        {
            regs = [];
            for (int i = 0; i < 32; i++) regs.Add(0);
            IM = (insts == null) ? [] : (List<string>)insts;
            DM = [];
            for (int i = 0; i < 1000; i++) DM.Add("0");
            PC = 0;
        }
        Instruction decodemc(string mc, int pc)
        {
            Instruction inst = new() 
            {
                mc      = mc,
                PC      = pc,
                opcode  = mc[^(1 + 31)..^26],
                rsind   = Convert.ToInt32(mc[^(1 + 25)..^21], 2),
                rtind   = Convert.ToInt32(mc[^(1 + 20)..^16], 2),
                rdind   = Convert.ToInt32(mc[^(1 + 15)..^11], 2),
                shamt   = mc[^(1 + 10)..^6],
                funct   = mc[^(1 + 5)..^0],
            };
            inst.immeds = Convert.ToInt32(sx(mc[^(1 + 15)..^0]), 2);
            inst.immedz = Convert.ToInt32(zx(mc[^(1 + 15)..^0]), 2);
            inst.address = Convert.ToInt32(zx(mc[^(1 + 25)..^0]), 2);
            // mips integer instruction map for formats (R, I, J)
            inst.rs = regs[inst.rsind];
            inst.rt = regs[inst.rtind];

            if (inst.opcode != "000000") inst.opcode = "0" + inst.opcode;
            // it depends on one of them or may be both
            if (inst.opcode == "000000")
                inst.mnem  = mnemonicmap[inst.funct];
            else             
                inst.mnem  = mnemonicmap[inst.opcode];
            inst.aluop  = get_inst_aluop(inst.mnem);
            inst.format = get_format(inst.mnem);
            inst.oper1  = get_oper1(inst);
            inst.oper2  = get_oper2(inst);
            if (inst.format == "I")
            {
                inst.rdind = inst.rtind;
            }
            if (inst.format == "J")
            {
                inst.rdind = 31;
            }
            return inst;
        }
        void mem(ref Instruction inst)
        {
            if (inst.mnem == Mnemonic.lw)
            {
                string smemout = DM[inst.aluout];
                smemout = DM[inst.aluout + 1] + smemout;
                smemout = DM[inst.aluout+2] + smemout;
                smemout = DM[inst.aluout+3] + smemout;
                inst.memout = Convert.ToInt32(smemout, 2);
            }
            else if (inst.mnem == Mnemonic.sw)
            {
                string memin = Convert.ToString(inst.rt, 2).PadLeft(32, '0');
                DM[inst.aluout]     = memin[24..32];
                DM[inst.aluout + 1] = memin[16..24];
                DM[inst.aluout + 2] = memin[8 ..16];
                DM[inst.aluout + 3] = memin[0 ..8];
            }
        }
        void write_back(Instruction inst)
        {
            if (!iswb(inst.mnem))
                return;
            regs[inst.rdind] = (inst.mnem == Mnemonic.lw) ? inst.memout : inst.aluout;
        }
        void ConsumeInst()
        {
            // fetching
            string mc = IM[PC];
            // decoding
            Instruction inst = decodemc(mc, PC);
            // executing
            inst.aluout = execute_inst(inst);
            // mem MIPS
            mem(ref inst);
            // writing back
            write_back(inst);

            // updating the PC
            if (inst.format == "J")
            {
                PC = inst.address;
            }
            else if (isbranch(inst.mnem))
            {
                PC += inst.immeds;
            }
            else if (inst.mnem == Mnemonic.jr)
            {
                PC = inst.aluout;
            }
            else
                PC += 1;
        }
        public int Run(int? n = null)
        {
            int i = 0;
            if (n == null)
            {
                while (PC < IM.Count)
                {
                    ConsumeInst();
                    i++;
                }
            }
            else
            {
                while (n-- > 0 && PC < IM.Count)
                {
                    ConsumeInst();
                    i++;
                }
            }
            return i;
        }
        public void print_regs()
        {
            MIPS.print_regs(regs);
        }
        public void print_DM()
        {
            MIPS.print_DM(DM);
        }
    }
}
