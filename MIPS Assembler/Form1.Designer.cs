namespace Assembler
{
    partial class Assembler
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            this.input = new System.Windows.Forms.RichTextBox();
            this.timer1 = new System.Windows.Forms.Timer(this.components);
            this.output = new System.Windows.Forms.RichTextBox();
            this.label1 = new System.Windows.Forms.Label();
            this.lblnumofinst = new System.Windows.Forms.Label();
            this.lblinvlabel = new System.Windows.Forms.Label();
            this.lblmultlabels = new System.Windows.Forms.Label();
            this.lblinvinst = new System.Windows.Forms.Label();
            this.SuspendLayout();
            // 
            // input
            // 
            this.input.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.input.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.input.Location = new System.Drawing.Point(16, 59);
            this.input.Margin = new System.Windows.Forms.Padding(4);
            this.input.Name = "input";
            this.input.Size = new System.Drawing.Size(457, 616);
            this.input.TabIndex = 0;
            this.input.Text = "";
            this.input.TextChanged += new System.EventHandler(this.Input_TextChanged);
            // 
            // timer1
            // 
            this.timer1.Enabled = true;
            this.timer1.Interval = 1000;
            // 
            // output
            // 
            this.output.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.output.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.output.Location = new System.Drawing.Point(509, 59);
            this.output.Margin = new System.Windows.Forms.Padding(4);
            this.output.Name = "output";
            this.output.Size = new System.Drawing.Size(700, 616);
            this.output.TabIndex = 1;
            this.output.Text = "";
            // 
            // label1
            // 
            this.label1.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(505, 37);
            this.label1.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(147, 16);
            this.label1.TabIndex = 2;
            this.label1.Text = "Number of Instructions : ";
            // 
            // lblnumofinst
            // 
            this.lblnumofinst.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.lblnumofinst.AutoSize = true;
            this.lblnumofinst.Location = new System.Drawing.Point(698, 37);
            this.lblnumofinst.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.lblnumofinst.Name = "lblnumofinst";
            this.lblnumofinst.Size = new System.Drawing.Size(14, 16);
            this.lblnumofinst.TabIndex = 3;
            this.lblnumofinst.Text = "0";
            // 
            // lblinvlabel
            // 
            this.lblinvlabel.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.lblinvlabel.AutoSize = true;
            this.lblinvlabel.ForeColor = System.Drawing.Color.Red;
            this.lblinvlabel.Location = new System.Drawing.Point(289, 37);
            this.lblinvlabel.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.lblinvlabel.Name = "lblinvlabel";
            this.lblinvlabel.Size = new System.Drawing.Size(154, 16);
            this.lblinvlabel.TabIndex = 4;
            this.lblinvlabel.Text = "Invalid Label(s) detected";
            this.lblinvlabel.Visible = false;
            // 
            // lblmultlabels
            // 
            this.lblmultlabels.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.lblmultlabels.AutoSize = true;
            this.lblmultlabels.ForeColor = System.Drawing.Color.Red;
            this.lblmultlabels.Location = new System.Drawing.Point(59, 37);
            this.lblmultlabels.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.lblmultlabels.Name = "lblmultlabels";
            this.lblmultlabels.Size = new System.Drawing.Size(181, 16);
            this.lblmultlabels.TabIndex = 5;
            this.lblmultlabels.Text = "Redundent Label(s) detected";
            this.lblmultlabels.Visible = false;
            // 
            // lblinvinst
            // 
            this.lblinvinst.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.lblinvinst.AutoSize = true;
            this.lblinvinst.ForeColor = System.Drawing.Color.Red;
            this.lblinvinst.Location = new System.Drawing.Point(725, 37);
            this.lblinvinst.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.lblinvinst.Name = "lblinvinst";
            this.lblinvinst.Size = new System.Drawing.Size(164, 16);
            this.lblinvinst.TabIndex = 6;
            this.lblinvinst.Text = "Invalid Instruction detected";
            this.lblinvinst.Visible = false;
            // 
            // Assembler
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 16F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(1226, 691);
            this.Controls.Add(this.lblinvinst);
            this.Controls.Add(this.lblmultlabels);
            this.Controls.Add(this.lblinvlabel);
            this.Controls.Add(this.lblnumofinst);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.output);
            this.Controls.Add(this.input);
            this.Margin = new System.Windows.Forms.Padding(4);
            this.Name = "Assembler";
            this.Text = "Form1";
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.RichTextBox input;
        private System.Windows.Forms.Timer timer1;
        private System.Windows.Forms.RichTextBox output;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Label lblnumofinst;
        private System.Windows.Forms.Label lblinvlabel;
        private System.Windows.Forms.Label lblmultlabels;
        private System.Windows.Forms.Label lblinvinst;
    }
}

