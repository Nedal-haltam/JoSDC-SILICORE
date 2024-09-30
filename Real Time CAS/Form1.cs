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

        void copy_insts_to_tb()
        {
            lblnumofinst.Text = curr_mc.Count.ToString();
            string tb_tocopy = "";
            for (int i = 0; i < curr_mc.Count; i++)
            {
                int num = Convert.ToInt32(curr_mc[i], 2);
                string hex = num.ToString("X");
                //tb_tocopy += $"addr_to_wr = {i}; Inst_to_wr = 32'h{hex}; #2; \n";
                tb_tocopy += $"inst_mem[{i}] <= 32'h{hex}; \n";
            }
            if (tb_tocopy.Length > 0)
                Clipboard.SetText(tb_tocopy);
            else
                Clipboard.SetText(" ");
        }
        List<string> assemble(string[] input)
        {
            ASSEMBLERMIPS.input.Lines = input;
            List<string> mc = ASSEMBLERMIPS.TOP_MAIN();
            curr_mc = mc;
            lblinvinst.Visible = ASSEMBLERMIPS.lblinvinst.Visible;
            lblinvlabel.Visible = ASSEMBLERMIPS.lblinvlabel.Visible;
            lblmultlabels.Visible = ASSEMBLERMIPS.lblmultlabels.Visible;
            lblnumofinst.Text = ASSEMBLERMIPS.lblnumofinst.Text;
            return mc;
        }

        (int, CPU5STAGE) simulate(List<string> mc)
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

        List<string> get_regs_DM(CPU5STAGE cpu)
        {
            List<string> toout = new List<string>();
            int i = 0;
            toout.Add("Reg file : ");
            foreach (int reg in cpu.regs)
            {
                toout.Add($"index = {i++,2}" + $"{((i <= 10) ? " " : "")}" + $" , signed = {reg,10} , unsigned = {(uint)reg,10}");
            }
            toout.Add("Data Memory : ");
            i = 0;
            foreach (string loc in cpu.DM)
            {
                int mem = Convert.ToInt32(loc, 2);
                toout.Add($"index = {i++,2}" + $"{((i <= 10) ? " " : "")}" + $" , signed = {mem,10} , unsigned = {(uint)mem,10}");
                if (i == 50) break;
            }
            return toout;
        }
        private void input_TextChanged(object sender, EventArgs e)
        {
            lblinfloop.Visible = false;
            List<string> mc = assemble(input.Lines);
            (int c , CPU5STAGE cpu) = simulate(mc);
        
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
                List<string> toout = get_regs_DM(cpu);
                output.Lines = toout.ToArray();
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
            output.Size = new System.Drawing.Size((Width - p) - 100, Height - 100);
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
            x += lblinfloop.Width + Padding.Size.Width;
            btntbcopy.Location = new System.Drawing.Point(x-10, y-7);
        }

        private void Form1_Resize(object sender, EventArgs e)
        {
            layout_size();
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            layout_size();
        }

        private void btntbcopy_Click(object sender, EventArgs e)
        {
            copy_insts_to_tb();
        }
    }
}
/*
addi x1, x0, 10
l:
sw x2, x2, 0
addi x2, x2, 1
bne x1, x2, l



addi x1, x0, 10
addi x2, x0, 1

l:
sw x1, x1, 0
sub x1, x1, x2
bne x1, x0, l
 */
