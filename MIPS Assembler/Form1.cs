using System;
using System.Collections.Generic;
using System.Windows.Forms;

namespace Assembler
{
    public partial class Assembler : Form
    {
        public Assembler()
        {
            InitializeComponent();
        }

        // this is the entry point of the entire process because we want to process the input only if the input is changed
        private void Input_TextChanged(object sender, EventArgs e)
        {
            ASSEMBLERMIPS.input.Lines = input.Lines;
            (List<string> mc, List<List<string>> insts) = ASSEMBLERMIPS.TOP_MAIN();
            output.Lines = mc.ToArray();
            lblinvinst.Visible = ASSEMBLERMIPS.lblinvinst.Visible;
            lblinvlabel.Visible = ASSEMBLERMIPS.lblinvlabel.Visible;
            lblmultlabels.Visible = ASSEMBLERMIPS.lblmultlabels.Visible;
            lblnumofinst.Text = ASSEMBLERMIPS.lblnumofinst.Text;
        }
    }
}

