using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices.ComTypes;
using System.Text;
using System.Windows.Forms;
using static System.Runtime.CompilerServices.RuntimeHelpers;
using static System.Windows.Forms.LinkLabel;
using static System.Windows.Forms.VisualStyles.VisualStyleElement.TextBox;

namespace Assembler
{
    public partial class Assembler : Form
    {
        public Assembler()
        {
            InitializeComponent();
        }

        System.Drawing.Point[] locations = new System.Drawing.Point[0];
        Label[] errors = new Label[0];
        List<string> curr_text_dir = new List<string>();
        List<string> curr_data_dir = new List<string>();
        List<string> curr_mc = new List<string>();
        List<List<string>> curr_insts = new List<List<string>>();
        List<string> hlt_seq = new List<string>() {
                    "11111100000000000000000000000000", // hlt
                    "00100000000111111111111111111111", // addi x31 x0 -1
                    "11111100000000000000000000000000", // hlt
                };
        List<List<string>> hlt_seq_insts = new List<List<string>>()
                {
                    new List<string>(){ "hlt" },
                    new List<string>(){ "addi", "x31", "x0", "-1" },
                    new List<string>(){ "hlt" },
                };
        // this is the entry point of the entire process because we want to process the input only if the input is changed

        void assemble(string[] input)
        {
            ASSEMBLERMIPS.input.Lines = input;
            (List<string> mc, List<List<string>> insts) = ASSEMBLERMIPS.TOP_MAIN();
            curr_mc = mc;
            curr_mc.Add("11111100000000000000000000000000");
            curr_insts = insts;
            curr_insts.Add(new List<string>() { "hlt" });
            lblErrInvinst.Visible = ASSEMBLERMIPS.lblinvinst.Visible;
            lblErrInvlabel.Visible = ASSEMBLERMIPS.lblinvlabel.Visible;
            lblErrMultlabels.Visible = ASSEMBLERMIPS.lblmultlabels.Visible;


            curr_insts.AddRange(hlt_seq_insts);

            lblNoErr.Visible = !(lblErrInvinst.Visible || lblErrInvlabel.Visible || lblErrMultlabels.Visible);
        }


        void get_directives(List<string> src)
        {
            src.ForEach(x => x = x.ToString().Trim(' '));

            int data_index = src.IndexOf(".data");
            int text_index = src.IndexOf(".text");

            curr_data_dir.Clear();
            curr_text_dir.Clear();

            if (data_index != -1)
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
            List<string> code = input.Lines.ToList();
            clean_comments(ref code);
            get_directives(code);
            List<string> to_out = new List<string>();

            //(to_out, _ ) = assemble_data_dir(curr_data_dir);
            assemble(curr_text_dir.ToArray());
            
            to_out.AddRange(curr_mc);
            output.Lines = to_out.ToArray();
            lblnumofinst.Text = curr_mc.Count.ToString();

            update_error_locations();
        }

        void update_error_locations()
        {
            int j = 0;
            for (int i = 0; i < errors.Length; i++)
            {
                if (errors[i].Visible)
                    errors[i].Location = locations[j++];
            }
        }


        private void layout_size()
        {
            int w = 1100;
            int h = 600;
            int padding = 20;
            Width = (Width < w) ? w : Width;
            Height = (Height < h) ? h : Height;
            int p = Width / 3;
            input.Size = new System.Drawing.Size(p, Height - 100);


            output.Location = new System.Drawing.Point(p + 50, output.Location.Y);
            output.Size = new System.Drawing.Size((Width - p) - 250, Height - 100);

            lblnumofinsttxt.Location = new System.Drawing.Point(output.Location.X, output.Location.Y - lblnumofinsttxt.Size.Height);
            lblnumofinst.Location = new System.Drawing.Point(lblnumofinsttxt.Location.X + lblnumofinsttxt.Size.Width, lblnumofinsttxt.Location.Y);

            btncopymc.Location = new System.Drawing.Point(output.Location.X + output.Size.Width - btncopymc.Size.Width, output.Location.Y - btncopymc.Size.Height);
            lblErr.Location = new System.Drawing.Point(output.Location.X + output.Size.Width + padding, output.Location.Y);
            lblNoErr.Location = new System.Drawing.Point(lblErr.Location.X + lblErr.Size.Width, lblErr.Location.Y);


            locations = new System.Drawing.Point[] {
                new System.Drawing.Point(lblErr.Location.X, lblErr.Location.Y + lblErr.Size.Height*1 + 10),
                new System.Drawing.Point(lblErr.Location.X, lblErr.Location.Y + lblErr.Size.Height*2 + 10),
                new System.Drawing.Point(lblErr.Location.X, lblErr.Location.Y + lblErr.Size.Height*3 + 10),
                new System.Drawing.Point(lblErr.Location.X, lblErr.Location.Y + lblErr.Size.Height*4 + 10)
            };

            update_error_locations();
        }

        private T popF<T>(ref List<T> vals)
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
                else if (code[i].Contains("#"))
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


        List<string> get_IM_INIT(List<string> mc)
        {
            List<string> IM_INIT = new List<string>();
            for (int i = 0; i < mc.Count; i++)
            {
                string inst = "";
                curr_insts[i].ForEach(x => { inst += x + " "; });
                IM_INIT.Add(get_entry_IM_INIT(mc[i], inst, i));
            }
            int HANDLER_ADDR = 1000;
            for (int i = 0; i < hlt_seq.Count; i++)
            {
                string inst = "";
                foreach (string tt in curr_insts[i])
                    inst += tt + " ";
                IM_INIT.Add(get_entry_IM_INIT(hlt_seq[i], inst, HANDLER_ADDR - 1 + i));
            }


            return IM_INIT;
        }


        void HandleCommand(List<string> args)
        {
            popF(ref args);
            if (args.Count != 6)
            {
                assert("Missing arguments");
            }
            string arg = popF(ref args).ToLower();
            string source_filepath = popF(ref args);
            string MC_filepath = popF(ref args);
            string DM_filepath = popF(ref args);
            string IM_INIT_filepath = popF(ref args);
            string DM_INIT_filepath = popF(ref args);
            if (arg == "gen")
            {
                List<string> src = File.ReadAllLines(source_filepath).ToList();
                clean_comments(ref src);
                get_directives(src.ToList());

                assemble(curr_text_dir.ToArray());

                List<string> mc = new List<string>();

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
                
                Close(); // for now we will close and not parse any other commands
            }
            else
            {
                assert($"Invalid argument {arg}");
            }
        }

        private void Assembler_Load(object sender, EventArgs e)
        {
            List<string> args = Environment.GetCommandLineArgs().ToList();
            if (args.Count > 1)
                HandleCommand(args);

            layout_size();
            errors = new Label[] {
                lblErrInvinst,
                lblErrInvlabel,
                lblErrMultlabels,
            };
        }

        private void Assembler_Resize(object sender, EventArgs e)
        {
            layout_size();
        }

        private void btncopymc_Click(object sender, EventArgs e)
        {
            string tb_tocopy = "";
            for (int i = 0; i < curr_mc.Count; i++)
            {
                string hex = Convert.ToInt32(curr_mc[i], 2).ToString("X").PadLeft(8, '0');
                string inst = "";
                curr_insts[i].ForEach(x => { inst += x + " "; });
                string temp = ($"Bin: \"{curr_mc[i]}\", Hex: 0x{hex}; // {inst,-20}").Trim() + '\n';
                tb_tocopy += temp;
            }
            if (tb_tocopy.Length > 0)
                Clipboard.SetText(tb_tocopy);
            else
                Clipboard.SetText(" ");

            /*
            Bin: "00100000000000010000000000000001", Hex: 0x20010001; // addi x1 x0 1

             */
        }
    }
}

