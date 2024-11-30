using System.Text;

namespace RealTimeCAS
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }
        List<List<string>> curr_insts = new List<List<string>>();
        List<string> curr_mc = new List<string>();
        List<string> curr_text_dir = new List<string>();
        List<string> curr_data = new List<string>();
        List<string> curr_data_dir = new List<string>();
        int MIFinstwidth = 0;
        int MIFinstdepth = 0;
        int MIFdatawidth = 0;
        int MIFdatadepth = 0;
        LibCPU.CPU_type curr_cpu = LibCPU.CPU_type.SingleCycle;
        System.Drawing.Point[] locations = new System.Drawing.Point[0];
        Label[] errors = new Label[0];
        enum CopyType
        {
            CAS, TB_copy
        }

        StringBuilder get_insts_string(CopyType copyType)
        {
            StringBuilder to_copy = new StringBuilder();
            if (copyType == CopyType.TB_copy)
            {
                for (int i = 0; i < curr_mc.Count; i++)
                {
                    string hex = Convert.ToInt32(curr_mc[i], 2).ToString("X").PadLeft(8, '0');
                    string inst = "";
                    curr_insts[i].ForEach(x => { inst += x + " "; });
                    string temp = ($"InstMem[{i,3}] <= 32'h{hex}; // {inst,-20}").Trim() + '\n';
                    to_copy.Append(temp);
                }
            }
            else if (copyType == CopyType.CAS)
            {
                for (int i = 0; i < curr_mc.Count; i++)
                {
                    string inst = "";
                    curr_insts[i].ForEach(x => { inst += x + " "; });
                    string temp = ($"\"{curr_mc[i]}\", // {inst,-20}").Trim() + '\n';
                    to_copy.Append(temp);
                }
            }
            return to_copy;
        }
        void clean_comments(ref List<string> code)
        {
            for (int i = 0; i < code.Count; i++)
            {
                if (code[i].Contains("//"))
                {
                    code[i] = code[i].Substring(0, code[i].IndexOf('/'));
                }
                else if (code[i].Contains("#"))
                {
                    code[i] = code[i].Substring(0, code[i].IndexOf('#'));
                }

            }
        }
        List<string> assemble(string[] input)
        {
            MIPSASSEMBLER.MIPSASSEMBLER.input = input;
            (List<string> mc, List<List<string>> insts) = MIPSASSEMBLER.MIPSASSEMBLER.TOP_MAIN();
            curr_mc = mc;
            curr_insts = insts;
            lblErrInvinst.Visible = MIPSASSEMBLER.MIPSASSEMBLER.lblinvinst;
            lblErrInvlabel.Visible = MIPSASSEMBLER.MIPSASSEMBLER.lblinvlabel;
            lblErrMultlabels.Visible = MIPSASSEMBLER.MIPSASSEMBLER.lblmultlabels;
            lblnumofinst.Text = MIPSASSEMBLER.MIPSASSEMBLER.lblnumofinst;
            return mc;
        }
        (List<string>, List<string>) assemble_data_dir(List<string> data_dir)
        {
            List<string> data = new List<string>();
            for (int i = 0; i < data_dir.Count; i++)
            {
                int index = data_dir[i].IndexOf(':');
                if (index != -1)
                {
                    string line = data_dir[i].Substring(index + 1);
                    line = line.Trim();
                    line = line.Replace(".word", "");
                    List<string> vals = line.Split(',').ToList();
                    foreach (string val in vals)
                    {
                        int number = 0;
                        string snum = val.ToLower().Trim();
                        try
                        {
                            if (snum.StartsWith("0x"))
                                number = Convert.ToInt32(snum, 16);
                            else
                                number = Convert.ToInt32(snum);
                        }
                        catch (Exception)
                        {
                            number = 0;
                        }
                        data.Add(number.ToString());
                    }

                }

            }
            List<string> DM_INIT = new List<string>();
            List<string> DM_vals = new List<string>();
            for (int i = 0; i < data.Count; i++)
            {
                DM_vals.Add(data[i].ToString());
                string temp = $"DataMem[{i,2}] <= 32'd{data[i]};";
                DM_INIT.Add(temp);
            }

            return (DM_INIT, DM_vals);
        }
        (int, LibCPU.MIPS.Exceptions, LibCPU.MIPS.CPU) SimulateCPU(List<string> mc)
        {
            (_, List<string> dm_vals) = assemble_data_dir(curr_data_dir);
            LibCPU.MIPS.CPU cpu = new LibCPU.MIPS.CPU().Init();
            if (curr_cpu == LibCPU.CPU_type.SingleCycle)
            {
                LibCPU.SingleCycle sc = new LibCPU.SingleCycle(mc, dm_vals);
                (int cycles, LibCPU.MIPS.Exceptions excep) = sc.Run();
                cpu.regs = sc.regs;
                cpu.DM = sc.DM;
                return (cycles, excep, cpu);
            }
            else if (curr_cpu == LibCPU.CPU_type.PipeLined)
            {
                LibCPU.CPU5STAGE pl = new LibCPU.CPU5STAGE(mc, dm_vals);
                (int cycles, LibCPU.MIPS.Exceptions excep) = pl.Run();
                cpu.regs = pl.regs;
                cpu.DM = pl.DM;
                return (cycles, excep, cpu);
            }
            else
                return (0, LibCPU.MIPS.Exceptions.EXCEPTION, new LibCPU.MIPS.CPU());
        }

        StringBuilder get_regs_DM(List<int> regs, List<string> DM)
        {
            //List<string> toout = new List<string>();
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
            }
            else if (excep == LibCPU.MIPS.Exceptions.NONE && cycles != 0)
            {
                lblcycles.Text = cycles.ToString();
                StringBuilder toout = get_regs_DM(regs, DM);
                output.Lines = toout.ToString().Split('\n');
            }
            else
            {
                lblcycles.Text = "0";
                StringBuilder toout = new StringBuilder();
                toout.Append("Reg file : \n");
                for (int i = 0; i < 32; i++) toout.Append($"index = {i,2} , signed = {0,10} , unsigned = {(uint)0,10}\n");
                toout.Append("Data Memory : \n");
                for (int i = 0; i < 20; i++) toout.Append($"Mem[{i,2}] = {0,10}\n");
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

        string GetMIFentry(string addr, string value)
        {
            return $"{addr} : {value};";
        }

        StringBuilder ToMIFentries(int start_address, List<string> list, int width, int from_base)
        {
            StringBuilder sb = new StringBuilder();

            for (int i = 0; i < list.Count; i++)
            {
                string address = (start_address + i).ToString("X");
                string value = Convert.ToInt32(list[i], from_base).ToString("X").PadLeft(width / 4, '0');
                string entry = GetMIFentry(address, value);
                sb.Append(entry + '\n');
            }

            return sb;
        }

        StringBuilder GetMIFHeader(int width, int depth, string address_radix, string data_radix)
        {
            StringBuilder sb = new StringBuilder();
            sb.Append($"WIDTH={width};\n");
            sb.Append($"DEPTH={depth};\n");
            sb.Append($"ADDRESS_RADIX={address_radix};\n");
            sb.Append($"DATA_RADIX={data_radix};\n");
            sb.Append("CONTENT BEGIN\n");

            return sb;
        }

        StringBuilder GetMIFTail()
        {
            return new StringBuilder("END;\n");
        }

        StringBuilder GetIMMIF()
        {
            int width = 32;
            int depth = 1024;
            int from_base = 2;
            StringBuilder sb = new StringBuilder();
            sb.Append(GetMIFHeader(width, depth, "HEX", "HEX"));
            sb.Append(ToMIFentries(0, curr_mc, width, from_base));
            sb.Append($"[{curr_mc.Count:X}..{(depth - 1):X}] : 0;\n");
            sb.Append(GetMIFTail());

            return sb;
        }

        StringBuilder GetDMMIF(List<string> DM)
        {
            int width = 32;
            int depth = 1024;
            int from_base = 10;
            StringBuilder sb = new StringBuilder();
            sb.Append(GetMIFHeader(width, depth, "HEX", "HEX"));
            sb.Append(ToMIFentries(0, DM, width, from_base));
            sb.Append($"[{DM.Count:X}..{(depth - 1):X}] : 0;\n");
            sb.Append(GetMIFTail());

            return sb;
        }

        private void btntbcopy_Click(object sender, EventArgs e)
        {
            StringBuilder to_copy = get_insts_string(CopyType.TB_copy);
            int i = 0;
            to_copy.Append("\n\n");
            curr_data.ForEach(x => to_copy.Append($"DataMem[{i++}] = 32'd{x};\n"));
            if (to_copy.Length > 0)
                Clipboard.SetText(to_copy.ToString());
            else
                Clipboard.SetText(" ");

            File.WriteAllText("./INSTRUCTION_MIF_FILE.mif", GetIMMIF().ToString());

            File.WriteAllText("./DATA_MIF_FILE.mif", GetDMMIF(curr_data).ToString());
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
        void get_directives(List<string> src)
        {
            src.ForEach(x => x = x.ToString().Trim(' '));

            int data_index = src.IndexOf(".data");
            int text_index = src.IndexOf(".text");

            curr_data_dir.Clear();
            curr_text_dir.Clear();

            if (data_index != -1 && text_index != -1)
            {
                curr_data_dir = src.GetRange(data_index, text_index - data_index);
            }
            if (text_index != -1)
            {
                curr_text_dir = src.GetRange(text_index + 1, src.Count - text_index - 1);
            }
        }
        private void input_TextChanged(object sender, EventArgs e)
        {
            lblErrInfloop.Visible = false;
            List<string> code = input.Lines.ToList();
            clean_comments(ref code);
            get_directives(code);
            List<string> mc = assemble(curr_text_dir.ToArray());
            (_, List<string> temp) = assemble_data_dir(curr_data_dir);
            curr_data = temp;

            (int cycles, LibCPU.MIPS.Exceptions excep, LibCPU.MIPS.CPU cpu) = SimulateCPU(mc);

            lblexception.Visible = excep != LibCPU.MIPS.Exceptions.NONE;

            update(mc, cycles, excep, cpu.regs, cpu.DM);

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

        private void input_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.Control && e.KeyCode == Keys.S)
            {
                SaveFileDialog saveFileDialog = new SaveFileDialog();
                DialogResult dialogResult = saveFileDialog.ShowDialog();
                if (dialogResult == DialogResult.OK)
                {
                    string file_path = saveFileDialog.FileName;

                    List<string> saved = new List<string>();
                    saved.Add("# CODE");
                    saved.AddRange(input.Lines.ToList());
                    File.WriteAllLines(file_path, saved.ToArray());
                }
            }
        }
    }
}
