using ProjectCPUCL;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Diagnostics.Eventing.Reader;
using System.Text;
using System.Windows.Forms;


namespace Real_Time_CAS_ASSEM
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }
        List<string> curr_mc = new List<string>();
        List<List<string>> curr_insts = new List<List<string>>();
        CPU_type curr_cpu = CPU_type.SingleCycle;
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
                    string hex = Convert.ToInt32(curr_mc[i], 2).ToString("X").PadLeft(8, '0');
                    string inst = "";
                    curr_insts[i].ForEach(x => { inst += x + " "; });
                    string temp = ($"\"{curr_mc[i]}\", // {inst,-20}").Trim() + '\n';
                    to_copy.Append(temp);
                }
            }
            return to_copy;
        }
        List<string> assemble(string[] input)
        {
            ASSEMBLERMIPS.input.Lines = input;
            (List<string> mc, List<List<string>> insts) = ASSEMBLERMIPS.TOP_MAIN();
            curr_mc = mc;
            curr_insts = insts;
            lblErrInvinst.Visible = ASSEMBLERMIPS.lblinvinst.Visible;
            lblErrInvlabel.Visible = ASSEMBLERMIPS.lblinvlabel.Visible;
            lblErrMultlabels.Visible = ASSEMBLERMIPS.lblmultlabels.Visible;
            lblnumofinst.Text = ASSEMBLERMIPS.lblnumofinst.Text;
            return mc;
        }

        (int, CPU5STAGE) simulatePipeLined(List<string> mc)
        {
            if (mc.Count == 0)
            {
                output.Lines = new string[0];
                return (0, new CPU5STAGE());
            }
            if (mc.Contains(ASSEMBLERMIPS.invinst))
            {
                output.Lines = new string[0];
                return (-1, new CPU5STAGE());
            }
            CPU5STAGE cpu = new CPU5STAGE(mc);
            int cycles = cpu.Run();
            return (cycles, cpu);
        }
        (int, SingleCycle) simulateSingleCycle(List<string> mc)
        {
            if (mc.Count == 0)
            {
                output.Lines = new string[0];
                return (0, new SingleCycle());
            }
            if (mc.Contains(ASSEMBLERMIPS.invinst))
            {
                output.Lines = new string[0];
                return (-1, new SingleCycle());
            }
            SingleCycle cpu = new SingleCycle(mc);
            int cycles = cpu.Run();
            return (cycles, cpu);
        }

        List<string> get_regs_DM(List<int> regs, List<string> DM)
        {
            List<string> toout = new List<string>();
            int i = 0;
            toout.Add("Reg file : ");
            foreach (int reg in regs)
            {
                toout.Add($"index = {i++,2}" + $"{((i <= 10) ? " " : "")}" + $" , signed = {reg,10} , unsigned = {(uint)reg,10}");
            }
            toout.Add("Data Memory : ");
            i = 0;
            foreach (string loc in DM)
            {
                int mem = Convert.ToInt32(loc, 2);
                toout.Add($"index = {i++,2}" + $"{((i <= 10) ? " " : "")}" + $" , signed = {mem,10} , unsigned = {(uint)mem,10}");
                if (i == 50) break;
            }
            return toout;
        }
        void update(List<string> mc, int c, List<int> regs, List<string> DM)
        {
            if (c == -1)
            {
                lblcycles.Text = "0";
            }
            else if (c == -2)
            {
                lblErrInfloop.Visible = true;
            }
            else
            {
                lblcycles.Text = c.ToString();
                lblnumofinst.Text = mc.Count.ToString();
                List<string> toout = get_regs_DM(regs, DM);
                output.Lines = toout.ToArray();
            }
        }

        private void input_TextChanged(object sender, EventArgs e)
        {
            lblErrInfloop.Visible = false;//  1011 0110 0111 0110
                                       //  1011 0110 0111 0110
            List<string> mc = assemble(input.Lines);
            if (curr_cpu == CPU_type.SingleCycle)
            {
                (int c , SingleCycle cpu) = simulateSingleCycle(mc);
                update(mc, c, cpu.regs, cpu.DM);
            }
            else if (curr_cpu == CPU_type.PipeLined)
            {
                (int c, CPU5STAGE cpu) = simulatePipeLined(mc);
                update(mc, c, cpu.regs, cpu.DM);
            }
            lblNoErr.Visible = !(lblErrInfloop.Visible || lblErrInvinst.Visible || lblErrInvlabel.Visible || lblErrMultlabels.Visible);

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

            lblcyclestxt.Location = new System.Drawing.Point(lblnumofinst.Location.X + lblnumofinst.Size.Width + padding, output.Location.Y - lblnumofinsttxt.Size.Height);
            lblcycles.Location = new System.Drawing.Point(lblcyclestxt.Location.X + lblcyclestxt.Size.Width, lblcyclestxt.Location.Y);


            cmbcpulist.Location = new System.Drawing.Point(output.Location.X + output.Width, output.Location.Y);
            btntbcopy.Location = new System.Drawing.Point(cmbcpulist.Location.X, btntbcopy.Location.Y);
            btncascopy.Location = new System.Drawing.Point(btntbcopy.Location.X - btntbcopy.Size.Width, btncascopy.Location.Y);
            lblErr.Location = new System.Drawing.Point(cmbcpulist.Location.X, lblErr.Location.Y);
            lblNoErr.Location = new System.Drawing.Point(lblErr.Location.X + lblErr.Size.Width, lblErr.Location.Y);

            
            locations = new System.Drawing.Point[] { 
                new System.Drawing.Point(lblErr.Location.X, lblErr.Location.Y + lblErr.Size.Height*1 + 10),
                new System.Drawing.Point(lblErr.Location.X, lblErr.Location.Y + lblErr.Size.Height*2 + 10),
                new System.Drawing.Point(lblErr.Location.X, lblErr.Location.Y + lblErr.Size.Height*3 + 10),
                new System.Drawing.Point(lblErr.Location.X, lblErr.Location.Y + lblErr.Size.Height*4 + 10)
            };





        }

        private void Form1_Resize(object sender, EventArgs e)
        {
            layout_size();
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            layout_size();
            cmbcpulist.SelectedIndex = 1;
            curr_cpu = (CPU_type)cmbcpulist.SelectedIndex;
            errors = new Label[] {
                lblErrInfloop,
                lblErrInvinst,
                lblErrInvlabel,
                lblErrMultlabels,
            };
        }

        private void btntbcopy_Click(object sender, EventArgs e)
        {
            StringBuilder to_copy = get_insts_string(CopyType.TB_copy);
            if (to_copy.Length > 0)
                Clipboard.SetText(to_copy.ToString());
            else
                Clipboard.SetText(" ");
        }

        private void cmbcpulist_SelectedIndexChanged(object sender, EventArgs e)
        {
            curr_cpu = (CPU_type)cmbcpulist.SelectedIndex;
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
    }
}

