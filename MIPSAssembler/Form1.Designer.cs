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
            this.lblnumofinsttxt = new System.Windows.Forms.Label();
            this.lblnumofinst = new System.Windows.Forms.Label();
            this.lblErrInvlabel = new System.Windows.Forms.Label();
            this.lblErrMultlabels = new System.Windows.Forms.Label();
            this.lblNoErr = new System.Windows.Forms.Label();
            this.lblErr = new System.Windows.Forms.Label();
            this.lblErrInvinst = new System.Windows.Forms.Label();
            this.btncopymc = new System.Windows.Forms.Button();
            this.SuspendLayout();
            // 
            // input
            // 
            this.input.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left)));
            this.input.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.input.Location = new System.Drawing.Point(16, 59);
            this.input.Margin = new System.Windows.Forms.Padding(4);
            this.input.Name = "input";
            this.input.Size = new System.Drawing.Size(457, 604);
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
            | System.Windows.Forms.AnchorStyles.Left)));
            this.output.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.output.Location = new System.Drawing.Point(509, 59);
            this.output.Margin = new System.Windows.Forms.Padding(4);
            this.output.Name = "output";
            this.output.Size = new System.Drawing.Size(527, 604);
            this.output.TabIndex = 1;
            this.output.Text = "";
            // 
            // lblnumofinsttxt
            // 
            this.lblnumofinsttxt.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.lblnumofinsttxt.AutoSize = true;
            this.lblnumofinsttxt.Location = new System.Drawing.Point(510, 39);
            this.lblnumofinsttxt.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.lblnumofinsttxt.Name = "lblnumofinsttxt";
            this.lblnumofinsttxt.Size = new System.Drawing.Size(147, 16);
            this.lblnumofinsttxt.TabIndex = 2;
            this.lblnumofinsttxt.Text = "Number of Instructions : ";
            // 
            // lblnumofinst
            // 
            this.lblnumofinst.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.lblnumofinst.AutoSize = true;
            this.lblnumofinst.Location = new System.Drawing.Point(703, 39);
            this.lblnumofinst.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.lblnumofinst.Name = "lblnumofinst";
            this.lblnumofinst.Size = new System.Drawing.Size(14, 16);
            this.lblnumofinst.TabIndex = 3;
            this.lblnumofinst.Text = "0";
            // 
            // lblErrInvlabel
            // 
            this.lblErrInvlabel.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.lblErrInvlabel.AutoSize = true;
            this.lblErrInvlabel.ForeColor = System.Drawing.Color.Red;
            this.lblErrInvlabel.Location = new System.Drawing.Point(1052, 114);
            this.lblErrInvlabel.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.lblErrInvlabel.Name = "lblErrInvlabel";
            this.lblErrInvlabel.Size = new System.Drawing.Size(154, 16);
            this.lblErrInvlabel.TabIndex = 4;
            this.lblErrInvlabel.Text = "Invalid Label(s) detected";
            this.lblErrInvlabel.Visible = false;
            // 
            // lblErrMultlabels
            // 
            this.lblErrMultlabels.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.lblErrMultlabels.AutoSize = true;
            this.lblErrMultlabels.ForeColor = System.Drawing.Color.Red;
            this.lblErrMultlabels.Location = new System.Drawing.Point(1052, 143);
            this.lblErrMultlabels.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.lblErrMultlabels.Name = "lblErrMultlabels";
            this.lblErrMultlabels.Size = new System.Drawing.Size(181, 16);
            this.lblErrMultlabels.TabIndex = 5;
            this.lblErrMultlabels.Text = "Redundent Label(s) detected";
            this.lblErrMultlabels.Visible = false;
            // 
            // lblNoErr
            // 
            this.lblNoErr.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.lblNoErr.AutoSize = true;
            this.lblNoErr.ForeColor = System.Drawing.Color.Red;
            this.lblNoErr.Location = new System.Drawing.Point(1103, 59);
            this.lblNoErr.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.lblNoErr.Name = "lblNoErr";
            this.lblNoErr.Size = new System.Drawing.Size(122, 16);
            this.lblNoErr.TabIndex = 26;
            this.lblNoErr.Text = "No Errors Detected";
            this.lblNoErr.Visible = false;
            // 
            // lblErr
            // 
            this.lblErr.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.lblErr.AutoSize = true;
            this.lblErr.ForeColor = System.Drawing.Color.Red;
            this.lblErr.Location = new System.Drawing.Point(1049, 59);
            this.lblErr.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.lblErr.Name = "lblErr";
            this.lblErr.Size = new System.Drawing.Size(46, 16);
            this.lblErr.TabIndex = 25;
            this.lblErr.Text = "Errors:";
            // 
            // lblErrInvinst
            // 
            this.lblErrInvinst.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.lblErrInvinst.AutoSize = true;
            this.lblErrInvinst.ForeColor = System.Drawing.Color.Red;
            this.lblErrInvinst.Location = new System.Drawing.Point(1049, 87);
            this.lblErrInvinst.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.lblErrInvinst.Name = "lblErrInvinst";
            this.lblErrInvinst.Size = new System.Drawing.Size(164, 16);
            this.lblErrInvinst.TabIndex = 23;
            this.lblErrInvinst.Text = "Invalid Instruction detected";
            this.lblErrInvinst.Visible = false;
            // 
            // btncopymc
            // 
            this.btncopymc.Location = new System.Drawing.Point(892, 29);
            this.btncopymc.Name = "btncopymc";
            this.btncopymc.Size = new System.Drawing.Size(144, 23);
            this.btncopymc.TabIndex = 27;
            this.btncopymc.Text = "Copy Macine Code";
            this.btncopymc.UseVisualStyleBackColor = true;
            this.btncopymc.Click += new System.EventHandler(this.btncopymc_Click);
            // 
            // Assembler
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 16F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(1377, 679);
            this.Controls.Add(this.btncopymc);
            this.Controls.Add(this.lblNoErr);
            this.Controls.Add(this.lblErr);
            this.Controls.Add(this.lblErrInvinst);
            this.Controls.Add(this.lblErrMultlabels);
            this.Controls.Add(this.lblErrInvlabel);
            this.Controls.Add(this.lblnumofinst);
            this.Controls.Add(this.lblnumofinsttxt);
            this.Controls.Add(this.output);
            this.Controls.Add(this.input);
            this.Margin = new System.Windows.Forms.Padding(4);
            this.Name = "Assembler";
            this.Text = "Form1";
            this.Load += new System.EventHandler(this.Assembler_Load);
            this.Resize += new System.EventHandler(this.Assembler_Resize);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.RichTextBox input;
        private System.Windows.Forms.Timer timer1;
        private System.Windows.Forms.RichTextBox output;
        private System.Windows.Forms.Label lblnumofinsttxt;
        private System.Windows.Forms.Label lblnumofinst;
        private System.Windows.Forms.Label lblErrMultlabels;
        private System.Windows.Forms.Label lblNoErr;
        private System.Windows.Forms.Label lblErr;
        private System.Windows.Forms.Label lblErrInvinst;
        private System.Windows.Forms.Label lblErrInvlabel;
        private System.Windows.Forms.Button btncopymc;
    }
}

