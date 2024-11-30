using MIPSASSEMBLER;
using System.Text;

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
        List<string> curr_mc = [];
        List<string> curr_insts = [];
        MIPSASSEMBLER.Program m_prog = new();
        private readonly List<string> excep_mc = [
                    "11111100000000000000000000000000", // hlt
                    "00100000000111111111111111111111", // addi x31 x0 -1
                    "11111100000000000000000000000000", // hlt
                ];
        private readonly List<string> excep_insts = [
                    "hlt",
                    "addi x31, x0, -1",
                    "hlt",
                ];
        // this is the entry point of the entire process because we want to process the input only if the input is changed

        void Assemble(string[] input)
        {
            m_prog = new();
            MIPSASSEMBLER.MIPSASSEMBLER assembler = new MIPSASSEMBLER.MIPSASSEMBLER();
            MIPSASSEMBLER.Program? program = assembler.ASSEMBLE(input.ToList());
            if (program.HasValue)
            {
                m_prog = program.Value;
                curr_mc = program.Value.mc;
                curr_insts = assembler.GetInstsAsText(m_prog);
            }
            else
            {
                curr_mc.Clear();
                curr_insts.Clear();
            }
            lblErrInvinst.Visible = assembler.lblINVINST;
            lblErrInvlabel.Visible = assembler.lblinvlabel;
            lblErrMultlabels.Visible = assembler.lblmultlabels;


            curr_insts.AddRange(excep_insts);

            lblNoErr.Visible = !(lblErrInvinst.Visible || lblErrInvlabel.Visible || lblErrMultlabels.Visible);
        }


        void Get_directives(List<string> src)
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



        private void Input_TextChanged(object sender, EventArgs e)
        {
            List<string> code = [.. input.Lines];
            clean_comments(ref code);
            Get_directives(code);
            List<string> to_out = [];

            //(to_out, _ ) = assemble_data_dir(curr_data_dir);
            Assemble([.. curr_text_dir]);

            to_out.AddRange(curr_mc);
            output.Lines = [.. to_out];
            lblnumofinst.Text = curr_mc.Count.ToString();

            Update_error_locations();
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

        private static T PopF<T>(ref List<T> vals)
        {
            T val = vals.First();
            vals.RemoveAt(0);
            return val;
        }


        void assert(string msg)
        {
            Console.ForegroundColor = ConsoleColor.Red;
            Console.Error.WriteLine(msg);
            Console.ResetColor();
            Environment.Exit(1);
        }

        string get_entry_IM_INIT(string mc, string inst, int i)
        {
            string hex = Convert.ToInt32(mc, 2).ToString("X").PadLeft(8, '0');
            return ($"InstMem[{i,2}] <= 32'h{hex};// {inst,-20}").Trim();
        }


        void clean_comments(ref List<string> code)
        {
            for (int i = 0; i < code.Count; i++)
            {
                if (code[i].Contains("//"))
                {
                    code[i] = code[i].Substring(0, code[i].IndexOf('/'));
                }
                else if (code[i].Contains('#'))
                {
                    code[i] = code[i].Substring(0, code[i].IndexOf('#'));
                }

            }
        }
        /*
        .data
        value: .word 0X5 # sample data for loading
        .text
        main:
        # Immediate instructions to initialize registers
        ADDI $1, $0, 0xA
        ORI $2, $0, 0xB
        XORI $3, $0, 0xC
        # Basic ALU operations
        ADD $4, $1, $2
        SUB $5, $4, $3
        AND $6, $1, $3
        OR $7, $2, $3
        NOR $8, $2, $3
        XOR $9, $1, $2
        # Comparison operations
        SLT $10, $1, $2
        SGT $11, $3, $1
        # Shift operations
        SLL $12, $1, 2
        SRL $13, $2, 1
        # Load and store word instructions
        LW $14, $0, 0
        SW $4, $0, 0
        */
        (List<string>, List<string>) assemble_data_dir(List<string> data_dir)
        {
            List<string> data = [];
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
            List<string> DM_INIT = [];
            List<string> DM_vals = [];
            for (int i = 0; i < data.Count; i++)
            {
                DM_vals.Add(data[i].ToString());
                string temp = $"DataMem[{i,2}] <= 32'd{data[i]};";
                DM_INIT.Add(temp);
            }

            return (DM_INIT, DM_vals);
        }


        List<string> get_IM_INIT(List<string> mc)
        {
            List<string> IM_INIT = [];
            for (int i = 0; i < mc.Count; i++)
            {
                IM_INIT.Add(get_entry_IM_INIT(mc[i], curr_insts[i], i));
            }
            int HANDLER_ADDR = 1000;
            for (int i = 0; i < excep_mc.Count; i++)
            {
                IM_INIT.Add(get_entry_IM_INIT(excep_mc[i], curr_insts[mc.Count + i], HANDLER_ADDR - 1 + i));
            }


            return IM_INIT;
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
            sb.Append($"[{curr_mc.Count:X}..{(depth - excep_mc.Count - 1):X}] : 0;\n");
            sb.Append(ToMIFentries(depth - excep_mc.Count, excep_mc, width, from_base));
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

        void HandleCommand(List<string> args)
        {
            PopF(ref args);
            if (args.Count != 8)
            {
                assert("Missing arguments");
            }
            string arg = PopF(ref args).ToLower();
            string source_filepath = PopF(ref args);
            string MC_filepath = PopF(ref args);
            string DM_filepath = PopF(ref args);
            string IM_INIT_filepath = PopF(ref args);
            string DM_INIT_filepath = PopF(ref args);
            string IM_MIF_filepath = PopF(ref args);
            string DM_MIF_filepath = PopF(ref args);
            if (arg == "gen")
            {
                List<string> src = File.ReadAllLines(source_filepath).ToList();
                clean_comments(ref src);
                Get_directives(src.ToList());

                Assemble(curr_text_dir.ToArray());

                List<string> mc = [];

                if (lblNoErr.Visible)
                {
                    mc.AddRange(curr_mc);
                }
                File.WriteAllLines(MC_filepath, mc);

                List<string> IM_INIT = get_IM_INIT(mc);
                File.WriteAllLines(IM_INIT_filepath, IM_INIT);

                (List<string> DM_INIT, List<string> DM) = assemble_data_dir(curr_data_dir);
                File.WriteAllLines(DM_filepath, DM);
                File.WriteAllLines(DM_INIT_filepath, DM_INIT);


                File.WriteAllText(IM_MIF_filepath, GetIMMIF().ToString());
                File.WriteAllText(DM_MIF_filepath, GetDMMIF(DM).ToString());


                Close(); // for now we will close and not parse any other commands
            }
            else
            {
                assert($"Invalid argument: {arg}");
            }
        }

        private void Assembler_Load(object sender, EventArgs e)
        {
            List<string> args = Environment.GetCommandLineArgs().ToList();
            if (args.Count > 1)
                HandleCommand(args);

            Layout_size();
            errors = new Label[] {
                lblErrInvinst,
                lblErrInvlabel,
                lblErrMultlabels,
            };
        }

        private void Assembler_Resize(object sender, EventArgs e)
        {
            Layout_size();
        }

        private void btncopymc_Click(object sender, EventArgs e)
        {
            string tb_tocopy = "";
            for (int i = 0; i < curr_mc.Count; i++)
            {
                string hex = Convert.ToInt32(curr_mc[i], 2).ToString("X").PadLeft(8, '0');
                string temp = ($"Bin: \"{curr_mc[i]}\", Hex: 0x{hex}; // {curr_insts[i],-20}").Trim() + '\n';
                tb_tocopy += temp;
            }
            if (tb_tocopy.Length > 0)
                Clipboard.SetText(tb_tocopy);
            else
                Clipboard.SetText(" ");

            //Bin: "00100000000000010000000000000001", Hex: 0x20010001; // addi x1 x0 1
        }

        private void Assembler_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.Control && e.KeyCode == Keys.S)
            {
                SaveFileDialog saveFileDialog = new SaveFileDialog();
                DialogResult dialogResult = saveFileDialog.ShowDialog();
                if (dialogResult == DialogResult.OK)
                {
                    string file_path = saveFileDialog.FileName;

                    List<string> saved = [];
                    saved.Add("# CODE");
                    saved.AddRange(input.Lines.ToList());
                    File.WriteAllLines(file_path, saved.ToArray());
                }
            }
        }
    }
}
