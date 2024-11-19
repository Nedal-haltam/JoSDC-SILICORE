using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices.ComTypes;
using System.Text;
using System.Windows.Forms;
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
        List<string> curr_mc = new List<string>();
        List<List<string>> curr_insts = new List<List<string>>();
        // this is the entry point of the entire process because we want to process the input only if the input is changed

        void assemble(string[] input)
        {
            ASSEMBLERMIPS.input.Lines = input;
            (List<string> mc, List<List<string>> insts) = ASSEMBLERMIPS.TOP_MAIN();
            curr_mc = mc;
            curr_insts = insts;
            output.Lines = mc.ToArray();
            lblErrInvinst.Visible = ASSEMBLERMIPS.lblinvinst.Visible;
            lblErrInvlabel.Visible = ASSEMBLERMIPS.lblinvlabel.Visible;
            lblErrMultlabels.Visible = ASSEMBLERMIPS.lblmultlabels.Visible;
            lblnumofinst.Text = ASSEMBLERMIPS.lblnumofinst.Text;

            lblNoErr.Visible = !(lblErrInvinst.Visible || lblErrInvlabel.Visible || lblErrMultlabels.Visible);
        }


        (List<string>, List<string>) get_directives(List<string> src)
        {
            src.ForEach(x => x = x.ToString().Trim(' '));

            int data_index = src.IndexOf(".data");
            int text_index = src.IndexOf(".text");

            List<string> data_dir = new List<string>();
            List<string> text_dir = new List<string>();

            if (data_index != -1)
            {
                data_dir = src.GetRange(data_index, text_index - data_index);
            }
            if (text_index != -1)
            {
                text_dir = src.GetRange(text_index + 1, src.Count - text_index - 1);
            }

            return (data_dir, text_dir);
        }



        private void Input_TextChanged(object sender, EventArgs e)
        {
            //if (comment)
            //{
            //    string line = input.Lines[comment_index];
            //    if (line.StartsWith("//"))
            //        line.TrimStart('/');
            //    else
            //        line = "//" + line;

            //    input.Lines[comment_index] = line;
            //}
            (List<string> data_dir, List<string> text_dir) = get_directives(input.Lines.ToList());

            assemble(text_dir.ToArray());

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


        void HandleCommand(List<string> args)
        {
            popF(ref args);
            if (args.Count != 4)
            {
                assert("Missing arguments");
            }
            string arg = popF(ref args).ToLower();
            string source_filepath = popF(ref args);
            string MC_filepath = popF(ref args);
            string IM_INIT_filepath = popF(ref args);
            if (arg == "gen")
            {
                string[] src = File.ReadAllLines(source_filepath);
                (List<string> data_dir, List<string> text_dir) = get_directives(src.ToList());
                assemble(text_dir.ToArray());

                List<string> mc = new List<string>();
                if (!lblNoErr.Visible)
                {
                    mc.Add("No mc to generate because the program is invalid");
                }
                else
                {
                    curr_mc.ForEach(x => mc.Add(x));
                }
                File.WriteAllLines(MC_filepath, mc);
                List<string> IM_INIT = new List<string>();
                for (int i = 0; i < curr_mc.Count; i++)
                {
                    string hex = Convert.ToInt32(curr_mc[i], 2).ToString("X").PadLeft(8, '0');
                    string inst = "";
                    curr_insts[i].ForEach(x => { inst += x + " "; });
                    string temp = ($"InstMem[{i,2}] <= 32'h{hex};// {inst,-20}").Trim();
                    IM_INIT.Add(temp);
                }
                File.WriteAllLines(IM_INIT_filepath, IM_INIT);
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

