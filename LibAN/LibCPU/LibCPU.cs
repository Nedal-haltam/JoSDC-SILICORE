
using System.Text;

using static LibCPU.MIPS;
namespace LibCPU
{
    public enum CPU_type
    {
        PipeLined, SingleCycle
    }
    public static class MIPS
    {

        public const int HANDLER_ADDR = 1000;
        public const string EXCEPTION = "EXCEPTION";
        public const string FETCH = "FETCH";
        public const string DECODE = "DECODE";
        public const string EXECUTE = "EXECUTE";
        public const string MEMORY = "MEMORY";
        public const string WRITEBACK = "WRITEBACK";
        public const string INVALID_OPCODED = "INVALID_OPCODED";
        public const string BUBBLE = "BUBBLE";
        public const string WRONG_PRED = "WRONG_PRED";
        public const string LOAD_USE = "LOAD_USE";
        public const string JR_INDECODE = "JR_INDECODE";
        public enum Mnemonic
        {
            add, addu, subu, sub, and, or, nor, slt, sgt, xor,
            addi, andi, ori, xori, slti, sll, srl,
            beq, bne,
            j, jr, jal,
            lw, sw,
            nop, hlt
        }
        public enum Aluop
        {
            add, sub, and, or, xor, nor, sll, srl, slt, sgt, div
        }
        public struct Instruction
        {
            public Instruction Init()
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
                return this;
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
            

        public static Instruction GetNewInst()
        {
            return new Instruction().Init();
        }

        public static (List<string>, List<string>, List<int>) InitMipsCPU(List<string> insts, List<string> data_mem_init)
        {
            List<int> regs = new List<int>();
            for (int i = 0; i < 32; i++) regs.Add(0);
            List<string> IM = new List<string>();
            int curr_count = 0;
            if (insts != null)
            {
                IM.AddRange(insts);
                curr_count = insts.Count;
            }
            string nop = "0".PadLeft(32, '0');
            for (int i = 0; i < 1024 - curr_count; i++) IM.Add(nop);

            IM[HANDLER_ADDR - 1] = "11111100000000000000000000000000"; // hlt
            IM[HANDLER_ADDR] = "00100000000111111111111111111111"; // addi x31 x0 -1
            IM[HANDLER_ADDR + 1] = "11111100000000000000000000000000"; // hlt

            List<string> DM = [.. data_mem_init];

            for (int i = 0; i < 1024 - data_mem_init.Count; i++) DM.Add("x");

            return (IM, DM, regs);
        }

        public struct CPU
        {
            public List<string> DM;
            public List<int> regs;

            public CPU Init()
            {
                DM = new List<string>();
                regs = new List<int>();
                return this;
            }

        }

        public enum Stage
        {
            fetch, decode, execute, memory, write_back
        }
        public enum Exceptions
        {
            NONE, INF_LOOP, INVALID_INST, EXCEPTION
        }

        public static readonly Dictionary<string, Mnemonic> mnemonicmap = new Dictionary<string, Mnemonic>()
        {
            // the nop is not mentioned here to not conflict with sll
            // R-format depends on the funct field, if opcode = "000000" then it is R-format else (it is an I-format or J-format either way it depends on distinct opcodes)
            // rd = rd, rs1 = rs, rs2 = rt
            { "000000100000" , Mnemonic.add  }, // R[rd] = R[rs] op R[rt]
            { "000000100001" , Mnemonic.addu }, // R[rd] = R[rs] op R[rt]
            { "000000100010" , Mnemonic.sub  }, // R[rd] = R[rs] op R[rt]
            { "000000100011" , Mnemonic.subu }, // R[rd] = R[rs] op R[rt]
            { "000000100100" , Mnemonic.and  }, // R[rd] = R[rs] op R[rt]
            { "000000100101" , Mnemonic.or   }, // R[rd] = R[rs] op R[rt]
            { "000000100110" , Mnemonic.xor  }, // R[rd] = R[rs] op R[rt]
            { "000000100111" , Mnemonic.nor  }, // R[rd] = R[rs] op R[rt]
            { "000000101010" , Mnemonic.slt  }, // R[rd] = R[rs] op R[rt]
            { "000000101011" , Mnemonic.sgt  }, // R[rd] = R[rs] op R[rt]
            { "000000000000" , Mnemonic.sll  }, // R[rd] = R[rt] op shamt
            { "000000000010" , Mnemonic.srl  }, // R[rd] = R[rt] op shamt
            { "000000001000" , Mnemonic.jr   }, // PC = R[rs] (here we jump to the instruciont in the IM addressed by R[rs])

            // I-format depends on the opcode field
            // rd = rt, rs1 = rs, rs2 = rt, immed = immed or addr
            { "001000000000" , Mnemonic.addi }, // R[rt] = R[rs] op sx(immed)  
            { "001100000000" , Mnemonic.andi }, // R[rt] = R[rs] op zx(immed)  
            { "001101000000" , Mnemonic.ori  }, // R[rt] = R[rs] op zx(immed)  
            { "001110000000" , Mnemonic.xori }, // R[rt] = R[rs] op zx(immed)  
            { "101010000000" , Mnemonic.slti }, // R[rt] = R[rs] op sx(immed)  
            { "100011000000" , Mnemonic.lw   }, // R[rt] = Mem[R[rs]+sx(immed)]
            { "101011000000" , Mnemonic.sw   }, // Mem[R[rs]+sx(immed)]=R[rt]  
            // rs1 = rs, rs2 = rt
            { "000100000000" , Mnemonic.beq  }, // if (R[rs] op R[rt]) -> PC += sx(offset) << 2  , note.1
            { "000101000000" , Mnemonic.bne  }, // if (R[rs] op R[rt]) -> PC += sx(offset) << 2  , note.1

            // J-format depends on opcode field
            { "000010000000" , Mnemonic.j    }, // PC = zx(addr) << 2  , note.1
            { "000011000000" , Mnemonic.jal  }, // R[31] = PC+1, PC = zx(addr) << 2  , note.1


            { "111111000000" , Mnemonic.hlt  },
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
            Mnemonic.add => Aluop.add,
            Mnemonic.sub => Aluop.sub,
            Mnemonic.and => Aluop.and,
            Mnemonic.andi => Aluop.and,
            Mnemonic.or => Aluop.or,
            Mnemonic.ori => Aluop.or,
            Mnemonic.xor => Aluop.xor,
            Mnemonic.xori => Aluop.xor,
            Mnemonic.nor => Aluop.nor,
            Mnemonic.slt => Aluop.slt,
            Mnemonic.slti => Aluop.slt,
            Mnemonic.sgt => Aluop.sgt,
            Mnemonic.sll => Aluop.sll,
            Mnemonic.srl => Aluop.srl,
            Mnemonic.addi => Aluop.add,
            Mnemonic.addu => Aluop.add,
            Mnemonic.subu => Aluop.sub,
            Mnemonic.beq => Aluop.add,
            Mnemonic.bne => Aluop.add,
            Mnemonic.j => Aluop.add,
            Mnemonic.jr => Aluop.add,
            Mnemonic.jal => Aluop.add,
            Mnemonic.lw => Aluop.add,
            Mnemonic.sw => Aluop.add,
            _ => 0,
        };
        ;
        }
        public static string get_format(Mnemonic mnem)
        {
        return mnem switch
        {
            Mnemonic.add => "R",
            Mnemonic.sub => "R",
            Mnemonic.and => "R",
            Mnemonic.andi => "I",
            Mnemonic.or => "R",
            Mnemonic.ori => "I",
            Mnemonic.xor => "R",
            Mnemonic.xori => "I",
            Mnemonic.nor => "R",
            Mnemonic.slt => "R",
            Mnemonic.sgt => "R",
            Mnemonic.slti => "I",
            Mnemonic.sll => "R",
            Mnemonic.srl => "R",
            Mnemonic.addi => "I",
            Mnemonic.addu => "R",
            Mnemonic.subu => "R",
            Mnemonic.beq => "I",
            Mnemonic.bne => "I",
            Mnemonic.j => "J",
            Mnemonic.jr => "R",
            Mnemonic.jal => "J",
            Mnemonic.lw => "I",
            Mnemonic.sw => "I",
            Mnemonic.hlt => "I",
            _ => "",
        };
        ;
        }
        public static int execute_inst(Instruction inst)
        {
            switch (inst.aluop)
            {
                case Aluop.add: return inst.oper1 + inst.oper2;
                case Aluop.sub: return inst.oper1 - inst.oper2;
                case Aluop.and: return inst.oper1 & inst.oper2;
                case Aluop.or: return inst.oper1 | inst.oper2;
                case Aluop.xor: return inst.oper1 ^ inst.oper2;
                case Aluop.nor: return ~(inst.oper1 | inst.oper2);
                case Aluop.slt: return (inst.oper1 < inst.oper2) ? 1 : 0;
                case Aluop.sgt: return (inst.oper1 > inst.oper2) ? 1 : 0;
                case Aluop.sll: return inst.oper1 << inst.oper2;
                case Aluop.srl:
                    {
                        if (inst.oper2 == 0)
                            return inst.oper1;
                        return Math.Abs(inst.oper1 >> inst.oper2);
                    };
                default: return 0;
            };
        }
        public static bool iswb(Mnemonic mnem)
        {
        return mnem switch
        {
            Mnemonic.add => true,
            Mnemonic.sub => true,
            Mnemonic.and => true,
            Mnemonic.andi => true,
            Mnemonic.or => true,
            Mnemonic.ori => true,
            Mnemonic.xor => true,
            Mnemonic.xori => true,
            Mnemonic.nor => true,
            Mnemonic.slt => true,
            Mnemonic.sgt => true,
            Mnemonic.slti => true,
            Mnemonic.sll => true,
            Mnemonic.srl => true,
            Mnemonic.addi => true,
            Mnemonic.addu => true,
            Mnemonic.subu => true,
            Mnemonic.beq => false,
            Mnemonic.bne => false,
            Mnemonic.j => false,
            Mnemonic.jr => false,
            Mnemonic.jal => true,
            Mnemonic.lw => true,
            Mnemonic.sw => false,
            _ => false,
        };
        ;
        }
        public static bool isbranch_taken(Instruction inst)
        {
            return (inst.mnem == Mnemonic.beq && inst.oper1 == inst.oper2) ||
                    (inst.mnem == Mnemonic.bne && inst.oper1 != inst.oper2);
        }
        public static bool isbranch(Mnemonic mnem)
        {
            return mnem == Mnemonic.beq ||
                    mnem == Mnemonic.bne;
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
            Console.Write("Register file content : \n");
            int i = 0;
            foreach (int n in regs)
            {
                string temp = $"index = {i++,10} , reg_out : signed = {n,10} , unsigned = {(uint)n,10}\n";
                Console.Write(temp);
            }
        }
        public static void print_DM(List<string> DM)
        {
            Console.Write("Data Memory Content : \n");
            int i = 0;
            foreach (string mem in DM)
            {
                if (i == 20) break;
                string temp;
                temp = $"Mem[{i++,2}] = {mem,11}\n";

                Console.Write(temp);
            }
        }

        public static StringBuilder get_regs(List<int> regs)
        {
            StringBuilder sb = new StringBuilder();
            sb.Append("Register file content : \n");
            int i = 0;
            foreach (int n in regs)
            {
                string temp = $"index = {i++,10} , reg_out : signed = {n,11} , unsigned = {(uint)n,10}\n";
                sb.Append(temp);
            }
            return sb;
        }
        public static StringBuilder get_DM(List<string> DM)
        {
            StringBuilder sb = new StringBuilder();
            sb.Append("Data Memory Content : \n");
            int i = 0;
            foreach (string mem in DM)
            {
                if (i == 51) break;
                string temp;

                temp = $"Mem[{i++,2}] = {mem,11}\n";

                sb.Append(temp);
            }
            return sb;
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
            return mnemonicmap.ContainsKey(inst.opcode + inst.funct);
        }


    }
    public class CPU5STAGE
    {
        int PC;
        bool hlt;
        bool WrongPrediction;
        int targetaddress;
        public List<string> DM; // Data Mem
        public List<int> regs;
        public List<string> IM; // Instruction Mem

        Instruction IFID;
        Instruction IDEX;
        Instruction EXMEM;
        Instruction MEMWB;

        Instruction memed_in_MEM_MIPS;
        Instruction executed_in_EX_MIPS;
        Instruction decoded_in_ID_MIPS;
        string fetched_in_IF_MIPS;

        int EX_HAZ;
        int MEM_HAZ;
        enum PCsrc
        {
            PCplus1, pfc, exception, none
        }
        PCsrc pcsrc;
        public CPU5STAGE(List<string> insts, List<string> data_mem_init)
        {
            (IM, DM, regs) = InitMipsCPU(insts, data_mem_init);

            PC = -1;
            hlt = false;
            WrongPrediction = false;
            targetaddress = 0;

            IFID = GetNewInst();
            IDEX = GetNewInst();
            EXMEM = GetNewInst();
            MEMWB = GetNewInst();
            memed_in_MEM_MIPS = GetNewInst();
            executed_in_EX_MIPS = GetNewInst();
            decoded_in_ID_MIPS = GetNewInst();
            fetched_in_IF_MIPS = "";
            EX_HAZ = 0;
            MEM_HAZ = 0;
        }
        int forward(int source_ind, int source_reg)
        {
            // EX haz
            if (EXMEM.rdind != 0 && iswb(EXMEM.mnem) && EXMEM.rdind == source_ind)
            {
                return EX_HAZ;
            }
            // MEM haz
            else if (MEMWB.rdind != 0 && iswb(MEMWB.mnem) && MEMWB.rdind == source_ind)
            {
                return MEM_HAZ;
            }
            return source_reg;
        }
        void update_PC()
        {
            if (pcsrc == PCsrc.none)
            {
                return;
            }
            else if (pcsrc == PCsrc.PCplus1)
            {
                PC += 1;
            }
            else if (pcsrc == PCsrc.pfc)
            {
                PC = targetaddress;
            }
        }
        Instruction decodemc(string mc, int pc)
        {
            Instruction inst = GetNewInst();
            inst.mc = mc;
            inst.PC = pc;
            inst.opcode = mc.Substring(mc.Length - (1 + 31), 6);
            inst.rsind = Convert.ToInt32(mc.Substring(mc.Length - (1 + 25), 5), 2);
            inst.rtind = Convert.ToInt32(mc.Substring(mc.Length - (1 + 20), 5), 2);
            inst.rdind = Convert.ToInt32(mc.Substring(mc.Length - (1 + 15), 5), 2);
            inst.shamt = mc.Substring(mc.Length - (1 + 10), 5);
            inst.funct = mc.Substring(mc.Length - (1 + 5), 6);
            inst.immeds = Convert.ToInt32(sx(mc.Substring(mc.Length - (1 + 15), 16)), 2);
            inst.immedz = Convert.ToInt32(zx(mc.Substring(mc.Length - (1 + 15), 16)), 2);
            inst.address = Convert.ToInt32(zx(mc.Substring(mc.Length - (1 + 25), 26)), 2);

            // mips integer instruction map for formats (R, I, J)
            inst.rs = regs[inst.rsind];
            inst.rt = regs[inst.rtind];


            if (inst.opcode != "000000")
                inst.funct = "000000";
            if (!mnemonicmap.TryGetValue(inst.opcode + inst.funct, out Mnemonic value))
            {
                Exception e = new Exception(EXCEPTION)
                {
                    Source = DECODE
                };
                throw e;
            }
            else
            {
                if (mc == "".PadLeft(32, '0'))
                    inst.mnem = Mnemonic.nop;
                inst.mnem = value;
            }
            inst.aluop = get_inst_aluop(inst.mnem);
            inst.format = get_format(inst.mnem);
            inst.oper1 = get_oper1(inst);
            inst.oper2 = get_oper2(inst);
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
        void BranchResolver(Instruction decoded)
        {
            if (WrongPrediction)
            {
                WrongPrediction = false;
                throw new Exception(BUBBLE) { Source = WRONG_PRED };
            }
            else if (decoded.mnem == Mnemonic.jr)
            {
                throw new Exception(BUBBLE) { Source = JR_INDECODE };
            }
            else if (executed_in_EX_MIPS.mnem == Mnemonic.lw && executed_in_EX_MIPS.rdind != 0)
            {
                int rdind = executed_in_EX_MIPS.rdind;
                if (decoded.format == "R")
                {
                    if (decoded.rsind == rdind || decoded.rtind == rdind)
                    {
                        throw new Exception(BUBBLE) { Source = LOAD_USE };
                    }
                }
                else if (decoded.format == "I")
                {
                    if (decoded.rsind == rdind || decoded.rtind == rdind)
                    {
                        throw new Exception(BUBBLE) { Source = LOAD_USE };
                    }
                }
            }
            else if (decoded.mnem == Mnemonic.hlt)
            {
                pcsrc = PCsrc.none;
            }
            else
            {
                if (decoded.mnem == Mnemonic.beq || decoded.mnem == Mnemonic.bne)
                {
                    pcsrc = PCsrc.pfc;
                    targetaddress = decoded.PC + decoded.immeds;
                }
                else if (decoded.mnem == Mnemonic.j || decoded.mnem == Mnemonic.jal)
                {
                    pcsrc = PCsrc.pfc;
                    targetaddress = decoded.address;
                }
                else
                    pcsrc = PCsrc.PCplus1;
            }

            WrongPrediction = false;
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
            Instruction decoded = GetNewInst();
            try
            {
                decoded = decodemc(fetched, PC);
                BranchResolver(decoded);
            }
            catch (Exception e)
            {
                decoded_in_ID_MIPS = decoded;
                throw e;
            }
            update_PC();
            detect_exception(decoded, Stage.decode);
            return decoded;
        }
        Instruction execute(Instruction decoded)
        {
            Instruction temp = decoded;
            if (decoded.mnem == Mnemonic.nop)
            {
                return temp;
            }
            if (temp.format == "R")
            {
                if (temp.mnem == Mnemonic.sll || temp.mnem == Mnemonic.srl)
                {
                    temp.oper1 = forward(temp.rtind, temp.oper1);
                }
                else
                {
                    temp.oper1 = forward(temp.rsind, temp.oper1);
                    temp.oper2 = forward(temp.rtind, temp.oper2);
                }
            }
            else if (temp.format == "I")
            {
                temp.oper1 = forward(temp.rsind, temp.oper1);
                if (isbranch(temp.mnem))
                    temp.oper2 = forward(temp.rtind, temp.oper2);
                // we will update the second operand if the instruction uses them 
                // (i.e. when it's an I-format and sw)
                if (temp.mnem == Mnemonic.sw)
                {
                    temp.rt = forward(temp.rtind, temp.rt);
                }
            }
            detect_exception(decoded, Stage.execute);
            temp.aluout = execute_inst(temp);
            WrongPrediction = (temp.mnem == Mnemonic.beq && temp.oper1 != temp.oper2) ||
                                (temp.mnem == Mnemonic.bne && temp.oper1 == temp.oper2) ||
                                (temp.mnem == Mnemonic.jr);
            return temp;
        }
        Instruction mem(ref Instruction inst)
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
                temp.memout = Convert.ToInt32(DM[temp.aluout]);
            }
            else if (temp.mnem == Mnemonic.sw)
            {
                DM[temp.aluout] = Convert.ToString(temp.rt);
            }

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
            if (inst.mnem == Mnemonic.hlt)
                hlt = true;
            if (!iswb(inst.mnem) || inst.rdind == 0)
                return;
            detect_exception(inst, Stage.write_back);
            regs[inst.rdind] = (inst.mnem == Mnemonic.lw) ? inst.memout : inst.aluout;
            MEM_HAZ = (inst.mnem == Mnemonic.lw) ? inst.memout : inst.aluout;
        }
        void handle_exception(Exception e)
        {
            PC = HANDLER_ADDR;
            IFID.mc = fetch();

            string s = e.Source;

            if (s == DECODE)
            {
                IDEX = GetNewInst();
                EXMEM = executed_in_EX_MIPS;
                MEMWB = memed_in_MEM_MIPS;
            }
            else if (s == EXECUTE)
            {
                IDEX = GetNewInst();
                EXMEM = GetNewInst();
                MEMWB = memed_in_MEM_MIPS;
            }
            else if (s == MEMORY || s == WRITEBACK) // made them in a single if condition because they have the same effect in an exception case
            {
                IDEX = GetNewInst();
                EXMEM = GetNewInst();
                MEMWB = GetNewInst();
                EX_HAZ = 0;
                MEM_HAZ = (s == WRITEBACK) ? 0 : MEM_HAZ;
            }

        }
        void detect_exception(Instruction inst, Stage stage)
        {
            Exception e = new Exception(EXCEPTION);

            if (stage == Stage.decode)
            {
                // detect if there is an exception in the decode operation in the decode stage
                if ((!isvalid_opcode_funct(inst) || !isvalid_format(inst.format)) && inst.mnem != Mnemonic.nop)
                {
                    e.Source = DECODE;
                    throw e;
                }
                if (isbranch(inst.mnem) || inst.mnem == Mnemonic.j || inst.mnem == Mnemonic.jal || inst.mnem == Mnemonic.jr)
                {
                    if (!is_in_range_inc(PC, 0, IM.Count - 1) && !(PC == IM.Count))
                    {
                        e.Source = DECODE;
                        throw e;
                    }
                }
            }
            else if (stage == Stage.execute)
            {
                // detect if there is an exception in the execution of the instruction in the execute stage (/0)
                if (inst.oper2 == 0 && inst.aluop == Aluop.div)
                {
                    e.Source = EXECUTE;
                    throw e;
                }
            }
            else if (stage == Stage.memory)
            {
                // detect if there is an exception in the memory operation in the mem stage (invalid address)
                if ((inst.mnem == Mnemonic.lw || inst.mnem == Mnemonic.sw) && !is_in_range_inc(inst.aluout, 0, DM.Count - 1))
                {
                    e.Source = MEMORY;
                    throw e;
                }
            }
            else if (stage == Stage.write_back)
            {
                // detect if there is an exception in the write back to the reg file in the wb stage (invalid reg or control signals)
                if (!isvalid_reg_ind(inst))
                {
                    e.Source = WRITEBACK;
                    throw e;
                }
            }

            return;
        }

        void InsertBubble(string source)
        {
            if (source == WRONG_PRED)
            {
                pcsrc = PCsrc.PCplus1;
                if (isbranch(executed_in_EX_MIPS.mnem))
                    PC = executed_in_EX_MIPS.PC + 1;
                else if (executed_in_EX_MIPS.mnem == Mnemonic.jr)
                    PC = executed_in_EX_MIPS.oper1;
                fetched_in_IF_MIPS = fetch();

                IFID.mc = fetched_in_IF_MIPS;
                IDEX = GetNewInst();
                EXMEM = executed_in_EX_MIPS;
                MEMWB = memed_in_MEM_MIPS;
            }
            else if (source == LOAD_USE)
            {
                IDEX = GetNewInst();
                EXMEM = executed_in_EX_MIPS;
                MEMWB = memed_in_MEM_MIPS;
            }
            else if (source == JR_INDECODE)
            {
                IFID.mc = "".PadLeft(32, '0');
                IDEX = decoded_in_ID_MIPS;
                EXMEM = executed_in_EX_MIPS;
                MEMWB = memed_in_MEM_MIPS;
            }
        }

        void ConsumeInst()
        {
            // here is the bulk of going through a complete cycle in the whole pipelined CPU
            try
            {
                write_back(MEMWB);
                if (hlt)
                    return;
                memed_in_MEM_MIPS = mem(ref EXMEM);
                executed_in_EX_MIPS = execute(IDEX);
                decoded_in_ID_MIPS = decode(IFID.mc);
                fetched_in_IF_MIPS = fetch();
            }
            catch (Exception e)
            {
                if (e.Message == BUBBLE)
                {
                    InsertBubble(e.Source);
                    return; // and then return and not fetch a new instruction
                }
                else if (e.Message == EXCEPTION)
                {
                    handle_exception(e);
                    throw e;
                }
            }
            MEMWB = memed_in_MEM_MIPS;
            EXMEM = executed_in_EX_MIPS;
            IDEX = decoded_in_ID_MIPS;
            IFID.mc = fetched_in_IF_MIPS;
        }
        public (int, Exceptions) Run()
        {
            int i = 0;
            Exceptions excep = Exceptions.NONE;
            while (PC < IM.Count)
            {
                i++;
                try
                {
                    ConsumeInst();
                }
                catch (Exception e)
                {
                    if (e.Message == EXCEPTION)
                    {
                        Run();
                        return (i, excep);
                    }
                }
                if (hlt)
                    return (i, excep);
                if (i == 200 * 1000)
                {
                    excep = Exceptions.INF_LOOP;
                    return (i, excep);
                }
            }
            return (i, excep);
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
        public int PC;
        public bool hlt;
        public List<string> DM; // Data Mem
        public List<int> regs;
        public List<string> IM; // Instruction Mem

        public SingleCycle(List<string> insts, List<string> data_mem_init)
        {
            (IM, DM, regs) = InitMipsCPU(insts, data_mem_init);

            PC = 0;
            hlt = false;
        }
        Instruction decodemc(string mc, int pc)
        {
            Instruction inst = GetNewInst();
            inst.mc = mc;
            inst.PC = pc;
            inst.opcode = mc.Substring(mc.Length - (1 + 31), 6);
            inst.rsind = Convert.ToInt32(mc.Substring(mc.Length - (1 + 25), 5), 2);
            inst.rtind = Convert.ToInt32(mc.Substring(mc.Length - (1 + 20), 5), 2);
            inst.rdind = Convert.ToInt32(mc.Substring(mc.Length - (1 + 15), 5), 2);
            inst.shamt = mc.Substring(mc.Length - (1 + 10), 5);
            inst.funct = mc.Substring(mc.Length - (1 + 5), 6);
            inst.immeds = Convert.ToInt32(sx(mc.Substring(mc.Length - (1 + 15), 16)), 2);
            inst.immedz = Convert.ToInt32(zx(mc.Substring(mc.Length - (1 + 15), 16)), 2);
            inst.address = Convert.ToInt32(zx(mc.Substring(mc.Length - (1 + 25), 26)), 2);
            // mips integer instruction map for formats (R, I, J)
            inst.rs = regs[inst.rsind];
            inst.rt = regs[inst.rtind];


            if (inst.opcode != "000000")
                inst.funct = "000000";
            if (!mnemonicmap.TryGetValue(inst.opcode + inst.funct, out Mnemonic value))
            {
                Exception e = new Exception(EXCEPTION)
                {
                    Source = DECODE
                };
                throw e;
            }
            else
            {
                if (mc == "".PadLeft(32, '0'))
                    inst.mnem = Mnemonic.nop;
                inst.mnem = value;
            }

            inst.aluop = get_inst_aluop(inst.mnem);
            inst.format = get_format(inst.mnem);
            inst.oper1 = get_oper1(inst);
            inst.oper2 = get_oper2(inst);
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
                inst.memout = Convert.ToInt32(smemout);
            }
            else if (inst.mnem == Mnemonic.sw)
            {
                string memin = Convert.ToString(inst.rt);
                if (!is_in_range_inc(inst.aluout, 0, DM.Count - 1))
                {
                    Exception e = new Exception($"Memory address {inst.aluout} is an invalid memory address")
                    {
                        Source = "SingleCycle::DataMemory"
                    };
                    throw e;
                }
                DM[inst.aluout] = memin;
            }
        }
        void write_back(Instruction inst)
        {
            if (inst.mnem == Mnemonic.hlt)
                hlt = true;

            if (iswb(inst.mnem) && inst.rdind != 0)
            {
                regs[inst.rdind] = (inst.mnem == Mnemonic.lw) ? inst.memout : inst.aluout;
                //Console.WriteLine($"writereg = {inst.rdind} , writedata = {regs[inst.rdind]}");
            }

        }
        void ConsumeInst()
        {
            Instruction inst;
            try
            {
                // fetching
                //Console.WriteLine($"PC = {PC}");
                string mc = IM[PC];
                // decoding
                inst = decodemc(mc, PC);
                // executing
                inst.aluout = execute_inst(inst);
                // mem MIPS
                mem(ref inst);
                // writing back
                write_back(inst);
            }
            catch (Exception e)
            {
                PC = HANDLER_ADDR;

                Run();
                throw e;
            }

            if (hlt)
                return;
            // updating the PC
            if (inst.format == "J")
            {
                PC = inst.address;
            }
            else if (inst.mnem == Mnemonic.jr)
            {
                PC = inst.aluout;
            }
            else if (isbranch(inst.mnem) && isbranch_taken(inst))
            {
                PC += inst.immeds;
            }
            else
                PC += 1;
        }

        public (int, Exceptions) Run()
        {
            int i = 0;
            while (PC < IM.Count)
            {
                i++;
                try
                {
                    ConsumeInst();
                }
                catch (Exception e)
                {
                    //Console.WriteLine($"cycles consumed = {i}");
                    i--;
                    return (i, Exceptions.EXCEPTION);
                }
                if (hlt)
                    return (i, Exceptions.NONE);
                if (i == 200 * 1000)
                {
                    return (0, Exceptions.INF_LOOP);
                }
            }
            return (i, Exceptions.NONE);
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
