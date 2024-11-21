﻿using ProjectCPUCL;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Diagnostics.Eventing.Reader;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Windows.Forms;
using static ProjectCPUCL.MIPS;


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
        List<string> curr_data_dir = new List<string>();
        List<string> curr_text_dir = new List<string>();
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
        (int, Exceptions, CPU) SimulateCPU(List<string> mc)
        {
            (_, List<string> dm_vals) = assemble_data_dir(curr_data_dir);
            CPU cpu = new CPU().Init();
            if (curr_cpu == CPU_type.SingleCycle)
            {
                SingleCycle sc = new SingleCycle(mc, dm_vals);
                (int cycles, Exceptions excep) = sc.Run();
                cpu.regs = sc.regs;
                cpu.DM = sc.DM;
                return (cycles, excep, cpu);
            }
            else if (curr_cpu == CPU_type.PipeLined)
            {
                CPU5STAGE pl = new CPU5STAGE(mc, dm_vals);
                (int cycles, Exceptions excep) = pl.Run();
                cpu.regs = pl.regs;
                cpu.DM = pl.DM;
                return (cycles, excep, cpu);
            }
            else
                return (0, Exceptions.EXCEPTION, new CPU());
        }

        StringBuilder get_regs_DM(List<int> regs, List<string> DM)
        {
            //List<string> toout = new List<string>();
            StringBuilder toout = new StringBuilder();
            toout.Append(get_regs(regs));
            toout.Append(get_DM(DM));
            return toout;
        }
        void update(List<string> mc, int cycles, Exceptions excep, List<int> regs, List<string> DM)
        {
            if (excep == Exceptions.INVALID_INST)
            {
                lblcycles.Text = "0";
            }
            else if (excep == Exceptions.INF_LOOP)
            {   
                lblErrInfloop.Visible = true;
            }
            else if (excep == Exceptions.NONE && cycles != 0)
            {
                lblcycles.Text = cycles.ToString();
                StringBuilder  toout = get_regs_DM(regs, DM);
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
            int w = 1200;
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
            lblexception.Location = new System.Drawing.Point(lblErr.Location.X, lblErr.Location.Y - lblexception.Size.Height - padding);

            
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
        void get_directives(List<string> src)
        {
            src.ForEach(x => x = x.ToString().Trim(' '));

            int data_index = src.IndexOf(".data");
            int text_index = src.IndexOf(".text");

            curr_data_dir.Clear();
            curr_text_dir.Clear();

            if (data_index != -1 && text_index  != -1)
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


            (int cycles, Exceptions excep, CPU cpu) = SimulateCPU(mc);

            lblexception.Visible = excep != Exceptions.NONE;

            update(mc, cycles, excep, cpu.regs, cpu.DM);

            lblNoErr.Visible = !(lblErrInfloop.Visible || lblErrInvinst.Visible || lblErrInvlabel.Visible || lblErrMultlabels.Visible);
            
            int j = 0;
            for (int i = 0; i < errors.Length; i++)
            {
                if (errors[i].Visible)
                    errors[i].Location = locations[j++];
            }
        }
    }
}

