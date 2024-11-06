using ProjectCPUCL;
using System;
using System.Collections.Generic;
using System.Diagnostics.Eventing.Reader;
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
        void copy_insts_to_tb()
        {
            string tb_tocopy = "";
            for (int i = 0; i < curr_mc.Count; i++)
            {
                string hex = Convert.ToInt32(curr_mc[i], 2).ToString("X").PadLeft(8, '0');
                string inst = "";
                curr_insts[i].ForEach(x => { inst += x + " "; });
                tb_tocopy += $"InstMem[{i, 3}] <= 32'h{hex}; // {inst, -20} \n";
            }
            if (tb_tocopy.Length > 0)
                Clipboard.SetText(tb_tocopy);
            else
                Clipboard.SetText(" ");
        }
        List<string> assemble(string[] input)
        {
            ASSEMBLERMIPS.input.Lines = input;
            (List<string> mc, List<List<string>> insts) = ASSEMBLERMIPS.TOP_MAIN();
            curr_mc = mc;
            curr_insts = insts;
            lblinvinst.Visible = ASSEMBLERMIPS.lblinvinst.Visible;
            lblinvlabel.Visible = ASSEMBLERMIPS.lblinvlabel.Visible;
            lblmultlabels.Visible = ASSEMBLERMIPS.lblmultlabels.Visible;
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
                lblinfloop.Visible = true;
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
            lblinfloop.Visible = false;//  1011 0110 0111 0110
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
        }
        
        private void layout_size()
        {
            int w = 1000;
            int h = 600;
            int x = 0;
            int y = lblnumofinsttxt.Location.Y;
            Width = (Width < w) ? w : Width;
            Height = (Height < h) ? h : Height;
            int p = Width / 3;
            input.Size = new System.Drawing.Size(p, Height - 100);
            output.Location = new System.Drawing.Point(p + 50, output.Location.Y);
            output.Size = new System.Drawing.Size((Width - p) - 200, Height - 100);
            cmbcpulist.Location = new System.Drawing.Point(output.Location.X + output.Width + Padding.Size.Width, output.Location.Y);
            x = output.Location.X;
            lblnumofinsttxt.Location = new System.Drawing.Point(x, y);
            x += lblnumofinsttxt.Width + Padding.Size.Width;
            lblnumofinst.Location = new System.Drawing.Point(x, y);
            x += lblnumofinst.Width + Padding.Size.Width;
            lblinvinst.Location = new System.Drawing.Point(x , y);
            x += lblinvinst.Width + Padding.Size.Width;
            lblcyclestxt.Location = new System.Drawing.Point(x, y);
            x += lblcyclestxt.Width + Padding.Size.Width;
            lblcycles.Location = new System.Drawing.Point(x, y);
            x += lblcycles.Width + Padding.Size.Width;
            lblinfloop.Location = new System.Drawing.Point(x, y);
            x += lblinfloop.Width + Padding.Size.Width*2;
            btntbcopy.Location = new System.Drawing.Point(x-10, y-7);
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
        }

        private void btntbcopy_Click(object sender, EventArgs e)
        {
            copy_insts_to_tb();
        }

        private void cmbcpulist_SelectedIndexChanged(object sender, EventArgs e)
        {
            curr_cpu = (CPU_type)cmbcpulist.SelectedIndex;
            input_TextChanged(input, e);
        }
    }
}

