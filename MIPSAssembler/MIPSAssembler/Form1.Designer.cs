namespace MIPSAssembler
{
    partial class Form1
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
            input = new RichTextBox();
            output = new RichTextBox();
            lblnumofinsttxt = new Label();
            lblnumofinst = new Label();
            lblErrInvlabel = new Label();
            lblErrMultlabels = new Label();
            lblNoErr = new Label();
            lblErr = new Label();
            lblErrInvinst = new Label();
            btncopymc = new Button();
            SuspendLayout();
            // 
            // input
            // 
            input.Anchor = AnchorStyles.Top | AnchorStyles.Bottom | AnchorStyles.Left;
            input.Font = new Font("Microsoft Sans Serif", 12F, FontStyle.Regular, GraphicsUnit.Point, 0);
            input.Location = new Point(16, 74);
            input.Margin = new Padding(4, 5, 4, 5);
            input.Name = "input";
            input.Size = new Size(457, 575);
            input.TabIndex = 0;
            input.Text = "";
            input.TextChanged += Input_TextChanged;
            input.KeyDown += Assembler_KeyDown;
            // 
            // output
            // 
            output.Anchor = AnchorStyles.Top | AnchorStyles.Bottom | AnchorStyles.Left;
            output.Font = new Font("Microsoft Sans Serif", 12F, FontStyle.Regular, GraphicsUnit.Point, 0);
            output.Location = new Point(509, 74);
            output.Margin = new Padding(4, 5, 4, 5);
            output.Name = "output";
            output.Size = new Size(527, 575);
            output.TabIndex = 1;
            output.Text = "";
            // 
            // lblnumofinsttxt
            // 
            lblnumofinsttxt.Anchor = AnchorStyles.Top | AnchorStyles.Bottom | AnchorStyles.Right;
            lblnumofinsttxt.AutoSize = true;
            lblnumofinsttxt.Location = new Point(452, 49);
            lblnumofinsttxt.Margin = new Padding(4, 0, 4, 0);
            lblnumofinsttxt.Name = "lblnumofinsttxt";
            lblnumofinsttxt.Size = new Size(171, 20);
            lblnumofinsttxt.TabIndex = 2;
            lblnumofinsttxt.Text = "Number of Instructions : ";
            // 
            // lblnumofinst
            // 
            lblnumofinst.Anchor = AnchorStyles.Top | AnchorStyles.Bottom | AnchorStyles.Right;
            lblnumofinst.AutoSize = true;
            lblnumofinst.Location = new Point(645, 49);
            lblnumofinst.Margin = new Padding(4, 0, 4, 0);
            lblnumofinst.Name = "lblnumofinst";
            lblnumofinst.Size = new Size(17, 20);
            lblnumofinst.TabIndex = 3;
            lblnumofinst.Text = "0";
            // 
            // lblErrInvlabel
            // 
            lblErrInvlabel.Anchor = AnchorStyles.Top | AnchorStyles.Bottom | AnchorStyles.Left | AnchorStyles.Right;
            lblErrInvlabel.AutoSize = true;
            lblErrInvlabel.ForeColor = Color.Red;
            lblErrInvlabel.Location = new Point(1052, 142);
            lblErrInvlabel.Margin = new Padding(4, 0, 4, 0);
            lblErrInvlabel.Name = "lblErrInvlabel";
            lblErrInvlabel.Size = new Size(172, 20);
            lblErrInvlabel.TabIndex = 4;
            lblErrInvlabel.Text = "Invalid Label(s) detected";
            lblErrInvlabel.Visible = false;
            // 
            // lblErrMultlabels
            // 
            lblErrMultlabels.Anchor = AnchorStyles.Top | AnchorStyles.Bottom | AnchorStyles.Left | AnchorStyles.Right;
            lblErrMultlabels.AutoSize = true;
            lblErrMultlabels.ForeColor = Color.Red;
            lblErrMultlabels.Location = new Point(1052, 179);
            lblErrMultlabels.Margin = new Padding(4, 0, 4, 0);
            lblErrMultlabels.Name = "lblErrMultlabels";
            lblErrMultlabels.Size = new Size(200, 20);
            lblErrMultlabels.TabIndex = 5;
            lblErrMultlabels.Text = "Redundent Label(s) detected";
            lblErrMultlabels.Visible = false;
            // 
            // lblNoErr
            // 
            lblNoErr.Anchor = AnchorStyles.Top | AnchorStyles.Bottom | AnchorStyles.Left | AnchorStyles.Right;
            lblNoErr.AutoSize = true;
            lblNoErr.ForeColor = Color.Red;
            lblNoErr.Location = new Point(1103, 74);
            lblNoErr.Margin = new Padding(4, 0, 4, 0);
            lblNoErr.Name = "lblNoErr";
            lblNoErr.Size = new Size(136, 20);
            lblNoErr.TabIndex = 26;
            lblNoErr.Text = "No Errors Detected";
            lblNoErr.Visible = false;
            // 
            // lblErr
            // 
            lblErr.Anchor = AnchorStyles.Top | AnchorStyles.Bottom | AnchorStyles.Left | AnchorStyles.Right;
            lblErr.AutoSize = true;
            lblErr.ForeColor = Color.Red;
            lblErr.Location = new Point(1049, 74);
            lblErr.Margin = new Padding(4, 0, 4, 0);
            lblErr.Name = "lblErr";
            lblErr.Size = new Size(50, 20);
            lblErr.TabIndex = 25;
            lblErr.Text = "Errors:";
            // 
            // lblErrInvinst
            // 
            lblErrInvinst.Anchor = AnchorStyles.Top | AnchorStyles.Bottom | AnchorStyles.Left | AnchorStyles.Right;
            lblErrInvinst.AutoSize = true;
            lblErrInvinst.ForeColor = Color.Red;
            lblErrInvinst.Location = new Point(1049, 109);
            lblErrInvinst.Margin = new Padding(4, 0, 4, 0);
            lblErrInvinst.Name = "lblErrInvinst";
            lblErrInvinst.Size = new Size(189, 20);
            lblErrInvinst.TabIndex = 23;
            lblErrInvinst.Text = "Invalid Instruction detected";
            lblErrInvinst.Visible = false;
            // 
            // btncopymc
            // 
            btncopymc.Location = new Point(892, 36);
            btncopymc.Margin = new Padding(3, 4, 3, 4);
            btncopymc.Name = "btncopymc";
            btncopymc.Size = new Size(144, 29);
            btncopymc.TabIndex = 27;
            btncopymc.Text = "Copy Macine Code";
            btncopymc.UseVisualStyleBackColor = true;
            btncopymc.Click += btncopymc_Click;
            // 
            // Form1
            // 
            AutoScaleDimensions = new SizeF(8F, 20F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(1319, 670);
            Controls.Add(btncopymc);
            Controls.Add(lblNoErr);
            Controls.Add(lblErr);
            Controls.Add(lblErrInvinst);
            Controls.Add(lblErrMultlabels);
            Controls.Add(lblErrInvlabel);
            Controls.Add(lblnumofinst);
            Controls.Add(lblnumofinsttxt);
            Controls.Add(output);
            Controls.Add(input);
            Margin = new Padding(4, 5, 4, 5);
            Name = "Form1";
            Text = "Form1";
            Load += Assembler_Load;
            Resize += Assembler_Resize;
            ResumeLayout(false);
            PerformLayout();
        }

        #endregion

        private System.Windows.Forms.RichTextBox input;
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
