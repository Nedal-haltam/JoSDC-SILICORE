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

        List<string> assemble(string[] input)
        {
            ASSEMBLERMIPS.input.Lines = input;
            List<string> mc = ASSEMBLERMIPS.TOP_MAIN();
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
