using System;
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
            ASSEMBLERMIPS.TOP_MAIN();
            output.Lines = ASSEMBLERMIPS.output.Lines;
            lblinvinst.Visible = ASSEMBLERMIPS.lblinvinst.Visible;
            lblinvlabel.Visible = ASSEMBLERMIPS.lblinvlabel.Visible;
            lblmultlabels.Visible = ASSEMBLERMIPS.lblmultlabels.Visible;
            lblnumofinst.Text = ASSEMBLERMIPS.lblnumofinst.Text;
        }
    }
}
// list of instructions to check the outputed machine code matches the MIPS ISA and for debugging
/*
add x1, x3, x4
addu x1, x2, x3
sub x1, x2, x3
subu x1, x2, x3
and x1, x2, x3
or x1, x2, x3
xor x1, x2, x3
nor x1, x2, x3
slt x1, x2, x3
sll x1, x2, 3
sll x1, x2, -1
sll x1, x2, 255
srl x1, x2, 7
srl x1, x2, -1
srl x1, x2, 255
jr x1

///////////////////////////

addi x3, x4, -1
addi x3, x4, 255
addi x3, x4, 254
addi x3, x4, 20

andi x3, x4, -1
andi x3, x4, 255
andi x3, x4, 254
andi x3, x4, 20

ori x3, x4, -1
ori x3, x4, 255
ori x3, x4, 254
ori x3, x4, 20

xori x3, x4, -1
xori x3, x4, 255
xori x3, x4, 254
xori x3, x4, 20


lw x6, x7, 0
lw x6, x7, -1
lw x6, x7, 235
lw x6, x7, 1204

sw x6, x7, 0
sw x6, x7, -1
sw x6, x7, 235
sw x6, x7, 1204
*/
