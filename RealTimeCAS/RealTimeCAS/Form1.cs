using System.Text;
using static System.Text.RegularExpressions.Regex;
using static LibAN.LibAN;
namespace RealTimeCAS
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }
        List<string> curr_insts = [];
        List<string> curr_text_dir = [];
        List<string> curr_data = [];
        List<string> curr_data_dir = [];
        MIPSASSEMBLER.Program m_prog = new();
        int MIFinstwidth = 0;
        int MIFinstdepth = 0;
        int MIFdatawidth = 0;
        int MIFdatadepth = 0;
        LibCPU.CPU_type curr_cpu = LibCPU.CPU_type.SingleCycle;
        System.Drawing.Point[] locations = [];
        Label[] errors = [];
        enum CopyType
        {
            CAS, TB_copy
        }

        void Assemble()
        {
            MIPSASSEMBLER.MIPSASSEMBLER assembler = new();
            MIPSASSEMBLER.Program? program = assembler.ASSEMBLE(curr_text_dir);
            if (program.HasValue)
            {
                m_prog = program.Value;
                m_prog.mc = program.Value.mc;
                curr_insts = assembler.GetInstsAsText(m_prog);
            }
            else
            {
                m_prog.instructions.Clear();
                m_prog.mc.Clear();
                m_prog.mc.Clear();
                curr_insts.Clear();
            }
            lblErrInvinst.Visible = assembler.lblINVINST;
            lblErrInvlabel.Visible = assembler.lblinvlabel;
            lblErrMultlabels.Visible = assembler.lblmultlabels;
            lblnumofinst.Text = m_prog.mc.Count.ToString();
        }
        (int, LibCPU.MIPS.Exceptions, LibCPU.MIPS.CPU) SimulateCPU(List<string> mc)
        {
            LibCPU.MIPS.CPU cpu = new LibCPU.MIPS.CPU().Init();
            if (curr_cpu == LibCPU.CPU_type.SingleCycle)
            {
                LibCPU.SingleCycle sc = new LibCPU.SingleCycle(mc, curr_data);
                (int cycles, LibCPU.MIPS.Exceptions excep) = sc.Run();
                cpu.regs = sc.regs;
                cpu.DM = sc.DM;
                return (cycles, excep, cpu);
            }
            else if (curr_cpu == LibCPU.CPU_type.PipeLined)
            {
                LibCPU.CPU6STAGE pl = new LibCPU.CPU6STAGE(mc, curr_data);
                (int cycles, LibCPU.MIPS.Exceptions excep) = pl.Run();
                cpu.regs = pl.regs;
                cpu.DM = pl.DM;
                return (cycles, excep, cpu);
            }
            else if (curr_cpu == LibCPU.CPU_type.OOO)
            {
                LibCPU.OOO SSOOO = new LibCPU.OOO(mc, curr_data);
                (int cycles, LibCPU.MIPS.Exceptions excep) = SSOOO.Run();
                cpu.regs = SSOOO.regs;
                cpu.DM = SSOOO.DM;
                return (cycles, excep, cpu);
            }
            else
                return (0, LibCPU.MIPS.Exceptions.EXCEPTION, new LibCPU.MIPS.CPU());
        }
        StringBuilder GetRegsAndDM(List<int> regs, List<string> DM)
        {
            //List<string> toout = [];
            StringBuilder toout = new StringBuilder();
            toout.Append(LibCPU.MIPS.get_regs(regs));
            toout.Append(LibCPU.MIPS.get_DM(DM));
            return toout;
        }
        void update(List<string> mc, int cycles, LibCPU.MIPS.Exceptions excep, List<int> regs, List<string> DM)
        {
            if (excep == LibCPU.MIPS.Exceptions.INVALID_INST)
            {
                lblcycles.Text = "0";
            }
            else if (excep == LibCPU.MIPS.Exceptions.INF_LOOP)
            {
                lblErrInfloop.Visible = true;
                lblcycles.Text = "0";
                StringBuilder toout = new StringBuilder();
                toout.Append("Reg file : \n");
                toout.Append(LibCPU.MIPS.get_regs(regs));
                toout.Append("Data Memory : \n");
                toout.Append(LibCPU.MIPS.get_DM(DM));
                output.Lines = toout.ToString().Split('\n');
            }
            else if (excep == LibCPU.MIPS.Exceptions.NONE && cycles != 0)
            {
                lblcycles.Text = cycles.ToString();
                StringBuilder toout = GetRegsAndDM(regs, DM);
                output.Lines = toout.ToString().Split('\n');
            }
            else if (excep == LibCPU.MIPS.Exceptions.EXCEPTION)
            {
                lblcycles.Text = "0";
                StringBuilder toout = new StringBuilder();
                toout.Append("Reg file : \n");
                toout.Append(LibCPU.MIPS.get_regs(regs));
                toout.Append("Data Memory : \n");
                toout.Append(LibCPU.MIPS.get_DM(DM));
                output.Lines = toout.ToString().Split('\n');
            }

        }
        private void layout_size()
        {
            int w = 1350;
            int h = 800;
            int padding = 10;
            Width = (Width < w) ? w : Width;
            Height = (Height < h) ? h : Height;
            int p = Width / 3;
            input.Size = new System.Drawing.Size(p, Height - 100);

            output.Location = new System.Drawing.Point(p + 50, output.Location.Y);
            output.Size = new System.Drawing.Size((Width - p) - 300, Height - 100);

            lblnumofinsttxt.Location = new System.Drawing.Point(output.Location.X, output.Location.Y - lblnumofinsttxt.Size.Height);
            lblnumofinst.Location = new System.Drawing.Point(lblnumofinsttxt.Location.X + lblnumofinsttxt.Size.Width, lblnumofinsttxt.Location.Y);

            lblcyclestxt.Location = new System.Drawing.Point(lblnumofinst.Location.X + lblnumofinst.Size.Width + padding, output.Location.Y - lblnumofinsttxt.Size.Height);
            lblcycles.Location = new System.Drawing.Point(lblcyclestxt.Location.X + lblcyclestxt.Size.Width, lblcyclestxt.Location.Y);

            btntbcopy.Location = new System.Drawing.Point(output.Location.X + output.Width, btntbcopy.Location.Y);
            cmbcpulist.Location = new System.Drawing.Point(btntbcopy.Location.X + btntbcopy.Width, btntbcopy.Location.Y);
            btncascopy.Location = new System.Drawing.Point(btntbcopy.Location.X - btntbcopy.Size.Width, btncascopy.Location.Y);

            lblErr.Location = new System.Drawing.Point(btntbcopy.Location.X, lblErr.Location.Y);
            lblNoErr.Location = new System.Drawing.Point(lblErr.Location.X + lblErr.Size.Width, lblErr.Location.Y);
            lblexception.Location = new System.Drawing.Point(lblErr.Location.X, lblErr.Location.Y - lblexception.Size.Height - padding);


            locations = new System.Drawing.Point[] {
                new System.Drawing.Point(lblErr.Location.X, lblErr.Location.Y + lblErr.Size.Height*1 + 10),
                new System.Drawing.Point(lblErr.Location.X, lblErr.Location.Y + lblErr.Size.Height*2 + 10),
                new System.Drawing.Point(lblErr.Location.X, lblErr.Location.Y + lblErr.Size.Height*3 + 10),
                new System.Drawing.Point(lblErr.Location.X, lblErr.Location.Y + lblErr.Size.Height*4 + 10)
            };


            lblinstmiftxt.Location = new System.Drawing.Point(btntbcopy.Location.X, btntbcopy.Location.Y + btntbcopy.Size.Height + padding);

            lblinstmifwidth.Location = new System.Drawing.Point(lblinstmiftxt.Location.X, lblinstmiftxt.Location.Y + lblinstmiftxt.Size.Height + padding);
            cmbinstwidth.Location = new System.Drawing.Point(lblinstmifwidth.Location.X, lblinstmifwidth.Location.Y + lblinstmifwidth.Size.Height);

            cmbinstdepth.Location = new System.Drawing.Point(cmbinstwidth.Location.X + cmbinstwidth.Size.Width, cmbinstwidth.Location.Y);
            lblinstmifdepth.Location = new System.Drawing.Point(cmbinstdepth.Location.X, cmbinstdepth.Location.Y - lblinstmifdepth.Size.Height);


            lbldatamiftxt.Location = new System.Drawing.Point(cmbinstwidth.Location.X, cmbinstwidth.Location.Y + cmbinstwidth.Size.Height + padding);

            lbldatamifwidth.Location = new System.Drawing.Point(lbldatamiftxt.Location.X, lbldatamiftxt.Location.Y + lbldatamiftxt.Size.Height + padding);
            cmbdatawidth.Location = new System.Drawing.Point(lbldatamifwidth.Location.X, lbldatamifwidth.Location.Y + lbldatamifwidth.Size.Height);

            cmbdatadepth.Location = new System.Drawing.Point(cmbdatawidth.Location.X + cmbdatawidth.Size.Width, cmbdatawidth.Location.Y);
            lbldatamifdepth.Location = new System.Drawing.Point(cmbdatadepth.Location.X, cmbdatadepth.Location.Y - lbldatamifdepth.Size.Height);


            int j = 0;
            for (int i = 0; i < errors.Length; i++)
            {
                if (errors[i].Visible)
                    errors[i].Location = locations[j++];
            }

        }
        private void Form1_Resize(object sender, EventArgs e)
        {
            layout_size();
        }
        private void Form1_Load(object sender, EventArgs e)
        {
            layout_size();
            curr_cpu = (LibCPU.CPU_type)cmbcpulist.SelectedIndex;
            errors = new Label[] {
                lblErrInfloop,
                lblErrInvinst,
                lblErrInvlabel,
                lblErrMultlabels,
            };

            cmbcpulist.SelectedIndex = 1;
            cmbinstdepth.SelectedIndex = 0;
            cmbinstwidth.SelectedIndex = 0;
            cmbdatawidth.SelectedIndex = 0;
            cmbdatadepth.SelectedIndex = 0;
        }
        private void cmbcpulist_SelectedIndexChanged(object sender, EventArgs e)
        {
            curr_cpu = (LibCPU.CPU_type)cmbcpulist.SelectedIndex;
            input_TextChanged(input, e);
        }
        private void btncascopy_Click(object sender, EventArgs e)
        {
            StringBuilder to_copy = get_insts_string(CopyType.CAS);
            if (to_copy.Length > 0)
                Clipboard.SetText(to_copy.ToString());
            else
                Clipboard.SetText(" ");
        }
        private void input_TextChanged(object sender, EventArgs e)
        {
            lblErrInfloop.Visible = false;
            List<string> code = input.Lines.ToList();
            clean_comments(ref code);
            (List<string> data_dir, List<string> text_dir) = Get_directives(code);
            curr_data_dir = data_dir;
            curr_text_dir = text_dir;

            (_, List<string> dm_vals, List<KeyValuePair<string, int>> addresses) = assemble_data_dir(curr_data_dir);
            foreach (KeyValuePair<string, int> address in addresses)
            {
                for (int i = 0; i < curr_text_dir.Count; i++)
                {
                    curr_text_dir[i] = Replace(curr_text_dir[i], $@"\b{Escape(address.Key)}\b", address.Value.ToString());
                }
            }
            Assemble();
            curr_data = dm_vals;

            (int cycles, LibCPU.MIPS.Exceptions excep, LibCPU.MIPS.CPU cpu) = SimulateCPU(m_prog.mc);

            lblexception.Visible = excep != LibCPU.MIPS.Exceptions.NONE;
            
            update(m_prog.mc, cycles, excep, cpu.regs, cpu.DM);

            lblNoErr.Visible = !(lblErrInfloop.Visible || lblErrInvinst.Visible || lblErrInvlabel.Visible || lblErrMultlabels.Visible || lblexception.Visible);

            int j = 0;
            for (int i = 0; i < errors.Length; i++)
            {
                if (errors[i].Visible)
                    errors[i].Location = locations[j++];
            }
        }
        private void MIF_COMBO_BOX_CHANGED_INDEX(object sender, EventArgs e)
        {
            int val = (int)Math.Pow(2, ((ComboBox)sender).SelectedIndex);
            if (((ComboBox)sender).Tag.ToString() == "instwidth")
            {
                MIFinstwidth = val;
            }
            else if (((ComboBox)sender).Tag.ToString() == "instdepth")
            {
                MIFinstdepth = val;
            }
            else if (((ComboBox)sender).Tag.ToString() == "datawidth")
            {
                MIFdatawidth = val;
            }
            else if (((ComboBox)sender).Tag.ToString() == "datadepth")
            {
                MIFdatadepth = val;
            }
        }
        StringBuilder GetIMMIF(int width, int depth, int from_base)
        {
            StringBuilder sb = new StringBuilder();
            sb.Append(GetMIFHeader(width, depth, "HEX", "HEX"));
            sb.Append(ToMIFentries(0, m_prog.mc, width, from_base));
            sb.Append($"[{m_prog.mc.Count:X}..{(depth - 1):X}] : 0;\n");
            sb.Append(GetMIFTail());

            return sb;
        }







        StringBuilder get_insts_string(CopyType copyType)
        {
            StringBuilder to_copy = new StringBuilder();
            if (copyType == CopyType.TB_copy)
            {
                for (int i = 0; i < m_prog.mc.Count; i++)
                {
                    string hex = Convert.ToInt32(m_prog.mc[i], 2).ToString("X").PadLeft(8, '0');
                    string temp = ($"InstMem[{i,3}] <= 32'h{hex}; // {curr_insts[i],-20}").Trim() + '\n';
                    to_copy.Append(temp);
                }
            }
            else if (copyType == CopyType.CAS)
            {
                for (int i = 0; i < m_prog.mc.Count; i++)
                {
                    string temp = ($"\"{m_prog.mc[i]}\", // {curr_insts[i],-20}").Trim() + '\n';
                    to_copy.Append(temp);
                }
            }
            return to_copy;
        }
        private void btn_TB_copy(object sender, EventArgs e)
        {
            StringBuilder to_copy = get_insts_string(CopyType.TB_copy);
            int i = 0;
            to_copy.Append("\n\n");
            curr_data.ForEach(x => to_copy.Append($"DataMem[{i++}] = 32'd{x};\n"));
            if (to_copy.Length > 0)
                Clipboard.SetText(to_copy.ToString());
            else
                Clipboard.SetText(" ");

            StringBuilder sb = GetIMMIF(MIFinstwidth, MIFinstdepth, 2);
            File.WriteAllText("./INSTRUCTION_MIF_FILE.mif", sb.ToString());

            StringBuilder sb2 = GetDMMIF(curr_data, MIFdatawidth, MIFdatadepth, 10);
            File.WriteAllText("./DATA_MIF_FILE.mif", sb2.ToString());
        }
        private void input_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.Control && e.KeyCode == Keys.S)
            {
                SaveFileDialog saveFileDialog = new();
                DialogResult dialogResult = saveFileDialog.ShowDialog();
                if (dialogResult == DialogResult.OK)
                {
                    string file_path = saveFileDialog.FileName;

                    List<string> saved = [];
                    saved.Add("# CODE");
                    saved.AddRange([.. input.Lines]);
                    File.WriteAllLines(file_path + ".txt", [.. saved]);
                }
            }
        }
    }
}
