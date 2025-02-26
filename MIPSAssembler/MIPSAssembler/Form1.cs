

using System.Collections.Generic;
using System.Text;
using static System.Text.RegularExpressions.Regex;
using static LibAN.LibAN;
namespace MIPSAssembler
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        Point[] locations = [];
        Label[] errors = [];
        List<string> curr_text_dir = [];
        List<string> curr_data_dir = [];
        List<string> curr_insts = [];
        MIPSASSEMBLER.Program m_prog = new();
        int HANDLER_ADDR = 1000;
        private readonly List<string> excep_mc = [
                    "11111100000000000000000000000000", // hlt
                    "00100000000111111111111111111111", // addi x31 x0 -1
                    "11111100000000000000000000000000", // hlt
                ];
        private readonly List<string> excep_insts = [
                    "hlt",
                    "addi x31 x0 -1",
                    "hlt",
                ];
        // this is the entry point of the entire process because we want to process the input only if the input is changed

        void Assemble(List<KeyValuePair<string, int>> addresses)
        {
            foreach (KeyValuePair<string, int> address in addresses)
            {
                for (int i = 0; i < curr_text_dir.Count; i++)
                {
                    curr_text_dir[i] = Replace(curr_text_dir[i], $@"\b{Escape(address.Key)}\b", address.Value.ToString());
                }
            }
            MIPSASSEMBLER.MIPSASSEMBLER assembler = new();
            MIPSASSEMBLER.Program? program = assembler.ASSEMBLE(curr_text_dir);
            if (program.HasValue)
            {
                m_prog = program.Value;
                curr_insts = assembler.GetInstsAsText(m_prog);
            }
            else
            {
                m_prog.instructions.Clear();
                m_prog.mc.Clear();
                curr_insts.Clear();
            }
            lblErrInvinst.Visible = assembler.lblINVINST;
            lblErrInvlabel.Visible = assembler.lblinvlabel;
            lblErrMultlabels.Visible = assembler.lblmultlabels;
            lblnumofinst.Text = m_prog.mc.Count.ToString();


            curr_insts.AddRange(excep_insts);

            lblNoErr.Visible = !(lblErrInvinst.Visible || lblErrInvlabel.Visible || lblErrMultlabels.Visible);
        }
        private void Input_TextChanged(object sender, EventArgs e)
        {
            List<string> code = [.. input.Lines];
            clean_comments(ref code);
            (List<string> data_dir, List<string> text_dir) = Get_directives(code);
            curr_data_dir = data_dir;
            curr_text_dir = text_dir;


            List<string> to_out = [];
            (_ , _, List<KeyValuePair<string, int>> addresses) = assemble_data_dir(curr_data_dir);
            Assemble(addresses);

            to_out.AddRange(m_prog.mc);
            output.Lines = [.. to_out];
            lblnumofinst.Text = m_prog.mc.Count.ToString();

            Update_error_locations();
        }
        private void Layout_size()
        {
            int w = 1100;
            int h = 600;
            int padding = 20;
            Width = (Width < w) ? w : Width;
            Height = (Height < h) ? h : Height;
            int p = Width / 3;
            input.Size = new Size(p, Height - 100);


            output.Location = new Point(p + 50, output.Location.Y);
            output.Size = new Size((Width - p) - 300, Height - 100);

            lblnumofinsttxt.Location = new Point(output.Location.X, output.Location.Y - lblnumofinsttxt.Size.Height);
            lblnumofinst.Location = new Point(lblnumofinsttxt.Location.X + lblnumofinsttxt.Size.Width, lblnumofinsttxt.Location.Y);

            btncopymc.Location = new Point(output.Location.X + output.Size.Width - btncopymc.Size.Width, output.Location.Y - btncopymc.Size.Height);
            lblErr.Location = new Point(output.Location.X + output.Size.Width + padding, output.Location.Y);
            lblNoErr.Location = new Point(lblErr.Location.X + lblErr.Size.Width, lblErr.Location.Y);


            locations = [
                new Point(lblErr.Location.X, lblErr.Location.Y + lblErr.Size.Height*1 + 10),
                new Point(lblErr.Location.X, lblErr.Location.Y + lblErr.Size.Height*2 + 10),
                new Point(lblErr.Location.X, lblErr.Location.Y + lblErr.Size.Height*3 + 10),
                new Point(lblErr.Location.X, lblErr.Location.Y + lblErr.Size.Height*4 + 10)
            ];

            Update_error_locations();
        }
        private static string? PopF(ref List<string> vals)
        {
            if (vals.Count == 0)
            {
                return null;
            }
            string val = vals.First();
            vals.RemoveAt(0);
            return val;
        }
        void HandleCommand(List<string> args)
        {
            PopF(ref args); // pop the default argument which is the path of the current program
            if (args.Count == 0)
            {
                MIPSASSEMBLER.MIPSASSEMBLER.Assert("Missing arguments");
            }
            string? arg = PopF(ref args);
            if (arg == null)
            {
                MIPSASSEMBLER.MIPSASSEMBLER.Assert($"No argumnets provided");
            }
            else if (arg.ToLower() != "gen")
            {
                MIPSASSEMBLER.MIPSASSEMBLER.Assert($"Invalid argument: {arg}");
            }
            string? source_filepath = PopF(ref args);
            string? MC_filepath = PopF(ref args);
            string? DM_filepath = PopF(ref args);
            string? IM_INIT_filepath = PopF(ref args);
            string? DM_INIT_filepath = PopF(ref args);
            string? IM_MIF_filepath = PopF(ref args);
            string? DM_MIF_filepath = PopF(ref args);

            List<string> DM_INIT = [], DM = [];
            if (source_filepath != null)
            {
                List<string> src = File.ReadAllLines(source_filepath).ToList();
                clean_comments(ref src);
                (List<string> data_dir, List<string> text_dir) = Get_directives(src);
                curr_data_dir = data_dir;
                curr_text_dir = text_dir;
                (List<string> DM_INIT1, List<string> DM1, List<KeyValuePair<string, int>> addresses) = assemble_data_dir(curr_data_dir);
                DM_INIT = DM_INIT1;
                DM = DM1;
                Assemble(addresses);
            }

            List<string> mc = [];
            
            if (lblNoErr.Visible)
            {
                mc.AddRange(m_prog.mc);
            }
            if (MC_filepath != null)
                File.WriteAllLines(MC_filepath, mc);
            if (DM_filepath != null)
                File.WriteAllLines(DM_filepath, DM);

            if (IM_INIT_filepath != null)
            {
                List<string> IM_INIT = get_IM_INIT(mc);
                File.WriteAllLines(IM_INIT_filepath, IM_INIT);
            }
            if (DM_INIT_filepath != null)
                File.WriteAllLines(DM_INIT_filepath, DM_INIT);

            if (IM_MIF_filepath != null)
                File.WriteAllText(IM_MIF_filepath, GetIMMIF(32, 2048, 2).ToString());
            if (DM_MIF_filepath != null)
                File.WriteAllText(DM_MIF_filepath, GetDMMIF(DM, 32, 4096, 10).ToString());


            Close(); // for now we will close and not parse any other commands
        }
        private void Assembler_Load(object sender, EventArgs e)
        {
            List<string> args = Environment.GetCommandLineArgs().ToList();
            if (args.Count > 1)
                HandleCommand(args);

            Layout_size();
            errors = [
                lblErrInvinst,
                lblErrInvlabel,
                lblErrMultlabels,
            ];
        }
        void Update_error_locations()
        {
            int j = 0;
            for (int i = 0; i < errors.Length; i++)
            {
                if (errors[i].Visible)
                    errors[i].Location = locations[j++];
            }
        }
        private void Assembler_Resize(object sender, EventArgs e)
        {
            Layout_size();
        }
        StringBuilder GetIMMIF(int width, int depth, int from_base)
        {
            StringBuilder sb = new StringBuilder();
            sb.Append(GetMIFHeader(width, depth, "HEX", "HEX"));
            sb.Append(ToMIFentries(0, m_prog.mc, width, from_base));
            
            sb.Append($"[{m_prog.mc.Count:X}..{(HANDLER_ADDR - 2):X}] : 0;\n");

            sb.Append(ToMIFentries(HANDLER_ADDR - 1, excep_mc, width, from_base));

            sb.Append($"[{HANDLER_ADDR + 2:X}..{(depth - 1):X}] : 0;\n");
            sb.Append(GetMIFTail());

            return sb;
        }
        string get_entry_IM_INIT(string mc, string inst, int i)
        {
            string hex = Convert.ToInt32(mc, 2).ToString("X").PadLeft(8, '0');
            return ($"InstMem[{i,2}] <= 32'h{hex};// {inst,-20}").Trim();
        }
        List<string> get_IM_INIT(List<string> mc)
        {
            List<string> IM_INIT = [];
            for (int i = 0; i < mc.Count; i++)
            {
                IM_INIT.Add(get_entry_IM_INIT(mc[i], curr_insts[i], i));
            }
            
            for (int i = 0; i < excep_mc.Count; i++)
            {
                IM_INIT.Add(get_entry_IM_INIT(excep_mc[i], curr_insts[mc.Count + i], HANDLER_ADDR - 1 + i));
            }


            return IM_INIT;
        }


        private void btncopymc_Click(object sender, EventArgs e)
        {
            string tb_tocopy = "";
            for (int i = 0; i < m_prog.mc.Count; i++)
            {
                string hex = Convert.ToInt32(m_prog.mc[i], 2).ToString("X").PadLeft(8, '0');
                string temp = ($"Bin: \"{m_prog.mc[i]}\", Hex: 0x{hex}; // {curr_insts[i],-20}").Trim() + '\n';
                tb_tocopy += temp;
            }
            if (tb_tocopy.Length > 0)
                Clipboard.SetText(tb_tocopy);
            else
                Clipboard.SetText(" ");
        }
        private void Assembler_KeyDown(object sender, KeyEventArgs e)
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
