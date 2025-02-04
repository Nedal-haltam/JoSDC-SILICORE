namespace RealTimeCAS
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
            lblErrInvinst = new Label();
            lblErrMultlabels = new Label();
            lblErrInvlabel = new Label();
            lblnumofinst = new Label();
            lblnumofinsttxt = new Label();
            lblcyclestxt = new Label();
            lblcycles = new Label();
            lblErrInfloop = new Label();
            btntbcopy = new Button();
            cmbcpulist = new ComboBox();
            lblErr = new Label();
            lblNoErr = new Label();
            btncascopy = new Button();
            lblexception = new Label();
            output = new RichTextBox();
            cmbinstwidth = new ComboBox();
            cmbinstdepth = new ComboBox();
            lblinstmiftxt = new Label();
            lblinstmifwidth = new Label();
            lblinstmifdepth = new Label();
            lbldatamifdepth = new Label();
            lbldatamifwidth = new Label();
            lbldatamiftxt = new Label();
            cmbdatadepth = new ComboBox();
            cmbdatawidth = new ComboBox();
            SuspendLayout();
            // 
            // input
            // 
            input.Anchor = AnchorStyles.Top | AnchorStyles.Bottom | AnchorStyles.Left;
            input.Font = new Font("Microsoft Sans Serif", 12F, FontStyle.Regular, GraphicsUnit.Point, 0);
            input.Location = new Point(30, 42);
            input.Margin = new Padding(4, 5, 4, 5);
            input.Name = "input";
            input.Size = new Size(439, 501);
            input.TabIndex = 7;
            input.Text = "";
            input.TextChanged += input_TextChanged;
            input.KeyDown += input_KeyDown;
            // 
            // lblErrInvinst
            // 
            lblErrInvinst.Anchor = AnchorStyles.Top | AnchorStyles.Bottom | AnchorStyles.Left | AnchorStyles.Right;
            lblErrInvinst.AutoSize = true;
            lblErrInvinst.ForeColor = Color.Red;
            lblErrInvinst.Location = new Point(1098, 392);
            lblErrInvinst.Margin = new Padding(4, 0, 4, 0);
            lblErrInvinst.Name = "lblErrInvinst";
            lblErrInvinst.Size = new Size(189, 20);
            lblErrInvinst.TabIndex = 13;
            lblErrInvinst.Text = "Invalid Instruction detected";
            lblErrInvinst.Visible = false;
            // 
            // lblErrMultlabels
            // 
            lblErrMultlabels.Anchor = AnchorStyles.Top | AnchorStyles.Bottom | AnchorStyles.Left | AnchorStyles.Right;
            lblErrMultlabels.AutoSize = true;
            lblErrMultlabels.ForeColor = Color.Red;
            lblErrMultlabels.Location = new Point(1098, 495);
            lblErrMultlabels.Margin = new Padding(4, 0, 4, 0);
            lblErrMultlabels.Name = "lblErrMultlabels";
            lblErrMultlabels.Size = new Size(200, 20);
            lblErrMultlabels.TabIndex = 12;
            lblErrMultlabels.Text = "Redundent Label(s) detected";
            lblErrMultlabels.Visible = false;
            // 
            // lblErrInvlabel
            // 
            lblErrInvlabel.Anchor = AnchorStyles.Top | AnchorStyles.Bottom | AnchorStyles.Left | AnchorStyles.Right;
            lblErrInvlabel.AutoSize = true;
            lblErrInvlabel.ForeColor = Color.Red;
            lblErrInvlabel.Location = new Point(1098, 462);
            lblErrInvlabel.Margin = new Padding(4, 0, 4, 0);
            lblErrInvlabel.Name = "lblErrInvlabel";
            lblErrInvlabel.Size = new Size(172, 20);
            lblErrInvlabel.TabIndex = 11;
            lblErrInvlabel.Text = "Invalid Label(s) detected";
            lblErrInvlabel.Visible = false;
            // 
            // lblnumofinst
            // 
            lblnumofinst.Anchor = AnchorStyles.Top | AnchorStyles.Bottom | AnchorStyles.Left | AnchorStyles.Right;
            lblnumofinst.AutoSize = true;
            lblnumofinst.Location = new Point(674, 18);
            lblnumofinst.Margin = new Padding(4, 0, 4, 0);
            lblnumofinst.Name = "lblnumofinst";
            lblnumofinst.Size = new Size(17, 20);
            lblnumofinst.TabIndex = 10;
            lblnumofinst.Text = "0";
            // 
            // lblnumofinsttxt
            // 
            lblnumofinsttxt.Anchor = AnchorStyles.Top | AnchorStyles.Bottom | AnchorStyles.Left | AnchorStyles.Right;
            lblnumofinsttxt.AutoSize = true;
            lblnumofinsttxt.Location = new Point(519, 15);
            lblnumofinsttxt.Margin = new Padding(4, 0, 4, 0);
            lblnumofinsttxt.Name = "lblnumofinsttxt";
            lblnumofinsttxt.Size = new Size(171, 20);
            lblnumofinsttxt.TabIndex = 9;
            lblnumofinsttxt.Text = "Number of Instructions : ";
            // 
            // lblcyclestxt
            // 
            lblcyclestxt.Anchor = AnchorStyles.Top | AnchorStyles.Bottom | AnchorStyles.Left | AnchorStyles.Right;
            lblcyclestxt.AutoSize = true;
            lblcyclestxt.Location = new Point(714, 15);
            lblcyclestxt.Margin = new Padding(4, 0, 4, 0);
            lblcyclestxt.Name = "lblcyclestxt";
            lblcyclestxt.Size = new Size(207, 20);
            lblcyclestxt.TabIndex = 14;
            lblcyclestxt.Text = "Number of cycles consumed : ";
            // 
            // lblcycles
            // 
            lblcycles.Anchor = AnchorStyles.Top | AnchorStyles.Bottom | AnchorStyles.Left | AnchorStyles.Right;
            lblcycles.AutoSize = true;
            lblcycles.Location = new Point(908, 18);
            lblcycles.Margin = new Padding(4, 0, 4, 0);
            lblcycles.Name = "lblcycles";
            lblcycles.Size = new Size(17, 20);
            lblcycles.TabIndex = 15;
            lblcycles.Text = "0";
            // 
            // lblErrInfloop
            // 
            lblErrInfloop.Anchor = AnchorStyles.Top | AnchorStyles.Bottom | AnchorStyles.Left | AnchorStyles.Right;
            lblErrInfloop.AutoSize = true;
            lblErrInfloop.ForeColor = Color.Red;
            lblErrInfloop.Location = new Point(1098, 428);
            lblErrInfloop.Margin = new Padding(4, 0, 4, 0);
            lblErrInfloop.Name = "lblErrInfloop";
            lblErrInfloop.Size = new Size(153, 20);
            lblErrInfloop.TabIndex = 16;
            lblErrInfloop.Text = "infinite loop detected";
            lblErrInfloop.Visible = false;
            // 
            // btntbcopy
            // 
            btntbcopy.Location = new Point(1101, 8);
            btntbcopy.Margin = new Padding(3, 4, 3, 4);
            btntbcopy.Name = "btntbcopy";
            btntbcopy.Size = new Size(95, 36);
            btntbcopy.TabIndex = 17;
            btntbcopy.Text = "TB_copy";
            btntbcopy.UseVisualStyleBackColor = true;
            btntbcopy.Click += btn_TB_copy;
            // 
            // cmbcpulist
            // 
            cmbcpulist.DropDownStyle = ComboBoxStyle.DropDownList;
            cmbcpulist.FormattingEnabled = true;
            cmbcpulist.Items.AddRange(new object[] { "Pipe Lined", "Single Cycle", "SSOOO" });
            cmbcpulist.Location = new Point(1202, 11);
            cmbcpulist.Margin = new Padding(3, 4, 3, 4);
            cmbcpulist.MaxDropDownItems = 4;
            cmbcpulist.Name = "cmbcpulist";
            cmbcpulist.Size = new Size(121, 28);
            cmbcpulist.Sorted = true;
            cmbcpulist.TabIndex = 18;
            cmbcpulist.SelectedIndexChanged += cmbcpulist_SelectedIndexChanged;
            // 
            // lblErr
            // 
            lblErr.Anchor = AnchorStyles.Top | AnchorStyles.Bottom | AnchorStyles.Left | AnchorStyles.Right;
            lblErr.AutoSize = true;
            lblErr.ForeColor = Color.Red;
            lblErr.Location = new Point(1098, 358);
            lblErr.Margin = new Padding(4, 0, 4, 0);
            lblErr.Name = "lblErr";
            lblErr.Size = new Size(50, 20);
            lblErr.TabIndex = 19;
            lblErr.Text = "Errors:";
            // 
            // lblNoErr
            // 
            lblNoErr.Anchor = AnchorStyles.Top | AnchorStyles.Bottom | AnchorStyles.Left | AnchorStyles.Right;
            lblNoErr.AutoSize = true;
            lblNoErr.ForeColor = Color.Red;
            lblNoErr.Location = new Point(1152, 358);
            lblNoErr.Margin = new Padding(4, 0, 4, 0);
            lblNoErr.Name = "lblNoErr";
            lblNoErr.Size = new Size(136, 20);
            lblNoErr.TabIndex = 20;
            lblNoErr.Text = "No Errors Detected";
            lblNoErr.Visible = false;
            // 
            // btncascopy
            // 
            btncascopy.Location = new Point(1000, 8);
            btncascopy.Margin = new Padding(3, 4, 3, 4);
            btncascopy.Name = "btncascopy";
            btncascopy.Size = new Size(95, 36);
            btncascopy.TabIndex = 21;
            btncascopy.Text = "CAS copy";
            btncascopy.UseVisualStyleBackColor = true;
            btncascopy.Click += btncascopy_Click;
            // 
            // lblexception
            // 
            lblexception.Anchor = AnchorStyles.Top | AnchorStyles.Bottom | AnchorStyles.Left | AnchorStyles.Right;
            lblexception.AutoSize = true;
            lblexception.ForeColor = Color.Red;
            lblexception.Location = new Point(1098, 304);
            lblexception.Margin = new Padding(4, 0, 4, 0);
            lblexception.Name = "lblexception";
            lblexception.Size = new Size(143, 20);
            lblexception.TabIndex = 22;
            lblexception.Text = "Exception Detected!";
            // 
            // output
            // 
            output.Anchor = AnchorStyles.Top | AnchorStyles.Bottom | AnchorStyles.Left;
            output.Font = new Font("Microsoft Sans Serif", 12F, FontStyle.Regular, GraphicsUnit.Point, 0);
            output.Location = new Point(523, 42);
            output.Margin = new Padding(4, 5, 4, 5);
            output.Name = "output";
            output.Size = new Size(567, 501);
            output.TabIndex = 8;
            output.Text = "";
            // 
            // cmbinstwidth
            // 
            cmbinstwidth.DropDownStyle = ComboBoxStyle.DropDownList;
            cmbinstwidth.FormattingEnabled = true;
            cmbinstwidth.Items.AddRange(new object[] { "1", "2", "4", "8", "16", "32", "64" });
            cmbinstwidth.Location = new Point(1101, 119);
            cmbinstwidth.Margin = new Padding(3, 4, 3, 4);
            cmbinstwidth.MaxDropDownItems = 4;
            cmbinstwidth.Name = "cmbinstwidth";
            cmbinstwidth.Size = new Size(95, 28);
            cmbinstwidth.TabIndex = 23;
            cmbinstwidth.Tag = "instwidth";
            cmbinstwidth.SelectedIndexChanged += MIF_COMBO_BOX_CHANGED_INDEX;
            // 
            // cmbinstdepth
            // 
            cmbinstdepth.DropDownStyle = ComboBoxStyle.DropDownList;
            cmbinstdepth.FormattingEnabled = true;
            cmbinstdepth.Items.AddRange(new object[] { "1", "2", "4", "8", "16", "32", "64", "128", "256", "512", "1024", "2048", "4096", "8192" });
            cmbinstdepth.Location = new Point(1202, 119);
            cmbinstdepth.Margin = new Padding(3, 4, 3, 4);
            cmbinstdepth.MaxDropDownItems = 4;
            cmbinstdepth.Name = "cmbinstdepth";
            cmbinstdepth.Size = new Size(95, 28);
            cmbinstdepth.TabIndex = 24;
            cmbinstdepth.Tag = "instdepth";
            cmbinstdepth.SelectedIndexChanged += MIF_COMBO_BOX_CHANGED_INDEX;
            // 
            // lblinstmiftxt
            // 
            lblinstmiftxt.Anchor = AnchorStyles.Top | AnchorStyles.Bottom | AnchorStyles.Left | AnchorStyles.Right;
            lblinstmiftxt.AutoSize = true;
            lblinstmiftxt.Location = new Point(1098, 55);
            lblinstmiftxt.Margin = new Padding(4, 0, 4, 0);
            lblinstmiftxt.Name = "lblinstmiftxt";
            lblinstmiftxt.Size = new Size(161, 20);
            lblinstmiftxt.TabIndex = 25;
            lblinstmiftxt.Text = "Instruction MIF settings";
            // 
            // lblinstmifwidth
            // 
            lblinstmifwidth.Anchor = AnchorStyles.Top | AnchorStyles.Bottom | AnchorStyles.Left | AnchorStyles.Right;
            lblinstmifwidth.AutoSize = true;
            lblinstmifwidth.Location = new Point(1098, 95);
            lblinstmifwidth.Margin = new Padding(4, 0, 4, 0);
            lblinstmifwidth.Name = "lblinstmifwidth";
            lblinstmifwidth.Size = new Size(56, 20);
            lblinstmifwidth.TabIndex = 26;
            lblinstmifwidth.Text = "WIDTH";
            // 
            // lblinstmifdepth
            // 
            lblinstmifdepth.Anchor = AnchorStyles.Top | AnchorStyles.Bottom | AnchorStyles.Left | AnchorStyles.Right;
            lblinstmifdepth.AutoSize = true;
            lblinstmifdepth.Location = new Point(1200, 95);
            lblinstmifdepth.Margin = new Padding(4, 0, 4, 0);
            lblinstmifdepth.Name = "lblinstmifdepth";
            lblinstmifdepth.Size = new Size(55, 20);
            lblinstmifdepth.TabIndex = 27;
            lblinstmifdepth.Text = "DEPTH";
            // 
            // lbldatamifdepth
            // 
            lbldatamifdepth.Anchor = AnchorStyles.Top | AnchorStyles.Bottom | AnchorStyles.Left | AnchorStyles.Right;
            lbldatamifdepth.AutoSize = true;
            lbldatamifdepth.Location = new Point(1201, 201);
            lbldatamifdepth.Margin = new Padding(4, 0, 4, 0);
            lbldatamifdepth.Name = "lbldatamifdepth";
            lbldatamifdepth.Size = new Size(55, 20);
            lbldatamifdepth.TabIndex = 32;
            lbldatamifdepth.Text = "DEPTH";
            // 
            // lbldatamifwidth
            // 
            lbldatamifwidth.Anchor = AnchorStyles.Top | AnchorStyles.Bottom | AnchorStyles.Left | AnchorStyles.Right;
            lbldatamifwidth.AutoSize = true;
            lbldatamifwidth.Location = new Point(1099, 201);
            lbldatamifwidth.Margin = new Padding(4, 0, 4, 0);
            lbldatamifwidth.Name = "lbldatamifwidth";
            lbldatamifwidth.Size = new Size(56, 20);
            lbldatamifwidth.TabIndex = 31;
            lbldatamifwidth.Text = "WIDTH";
            // 
            // lbldatamiftxt
            // 
            lbldatamiftxt.Anchor = AnchorStyles.Top | AnchorStyles.Bottom | AnchorStyles.Left | AnchorStyles.Right;
            lbldatamiftxt.AutoSize = true;
            lbldatamiftxt.Location = new Point(1099, 161);
            lbldatamiftxt.Margin = new Padding(4, 0, 4, 0);
            lbldatamiftxt.Name = "lbldatamiftxt";
            lbldatamiftxt.Size = new Size(124, 20);
            lbldatamiftxt.TabIndex = 30;
            lbldatamiftxt.Text = "Data MIF settings";
            // 
            // cmbdatadepth
            // 
            cmbdatadepth.DropDownStyle = ComboBoxStyle.DropDownList;
            cmbdatadepth.FormattingEnabled = true;
            cmbdatadepth.Items.AddRange(new object[] { "1", "2", "4", "8", "16", "32", "64", "128", "256", "512", "1024", "2048", "4096", "8192" });
            cmbdatadepth.Location = new Point(1203, 225);
            cmbdatadepth.Margin = new Padding(3, 4, 3, 4);
            cmbdatadepth.MaxDropDownItems = 4;
            cmbdatadepth.Name = "cmbdatadepth";
            cmbdatadepth.Size = new Size(95, 28);
            cmbdatadepth.TabIndex = 29;
            cmbdatadepth.Tag = "datadepth";
            cmbdatadepth.SelectedIndexChanged += MIF_COMBO_BOX_CHANGED_INDEX;
            // 
            // cmbdatawidth
            // 
            cmbdatawidth.DropDownStyle = ComboBoxStyle.DropDownList;
            cmbdatawidth.FormattingEnabled = true;
            cmbdatawidth.Items.AddRange(new object[] { "1", "2", "4", "8", "16", "32", "64" });
            cmbdatawidth.Location = new Point(1102, 225);
            cmbdatawidth.Margin = new Padding(3, 4, 3, 4);
            cmbdatawidth.MaxDropDownItems = 4;
            cmbdatawidth.Name = "cmbdatawidth";
            cmbdatawidth.Size = new Size(95, 28);
            cmbdatawidth.TabIndex = 28;
            cmbdatawidth.Tag = "datawidth";
            cmbdatawidth.SelectedIndexChanged += MIF_COMBO_BOX_CHANGED_INDEX;
            // 
            // Form1
            // 
            AutoScaleDimensions = new SizeF(8F, 20F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(1355, 608);
            Controls.Add(lbldatamifdepth);
            Controls.Add(lbldatamifwidth);
            Controls.Add(lbldatamiftxt);
            Controls.Add(cmbdatadepth);
            Controls.Add(cmbdatawidth);
            Controls.Add(lblinstmifdepth);
            Controls.Add(lblinstmifwidth);
            Controls.Add(lblinstmiftxt);
            Controls.Add(cmbinstdepth);
            Controls.Add(cmbinstwidth);
            Controls.Add(lblexception);
            Controls.Add(btncascopy);
            Controls.Add(lblNoErr);
            Controls.Add(lblErr);
            Controls.Add(cmbcpulist);
            Controls.Add(btntbcopy);
            Controls.Add(lblErrInfloop);
            Controls.Add(lblcycles);
            Controls.Add(lblcyclestxt);
            Controls.Add(input);
            Controls.Add(lblErrInvinst);
            Controls.Add(lblErrMultlabels);
            Controls.Add(lblErrInvlabel);
            Controls.Add(lblnumofinst);
            Controls.Add(lblnumofinsttxt);
            Controls.Add(output);
            Margin = new Padding(3, 4, 3, 4);
            Name = "Form1";
            Text = "Form1";
            Load += Form1_Load;
            Resize += Form1_Resize;
            ResumeLayout(false);
            PerformLayout();
        }

        #endregion

        private System.Windows.Forms.RichTextBox input;
        private System.Windows.Forms.Label lblErrInvinst;
        private System.Windows.Forms.Label lblErrMultlabels;
        private System.Windows.Forms.Label lblErrInvlabel;
        private System.Windows.Forms.Label lblnumofinst;
        private System.Windows.Forms.Label lblnumofinsttxt;
        private System.Windows.Forms.Label lblcyclestxt;
        private System.Windows.Forms.Label lblcycles;
        private System.Windows.Forms.Label lblErrInfloop;
        private System.Windows.Forms.Button btntbcopy;
        private System.Windows.Forms.ComboBox cmbcpulist;
        private System.Windows.Forms.Label lblErr;
        private System.Windows.Forms.Label lblNoErr;
        private System.Windows.Forms.Button btncascopy;
        private System.Windows.Forms.Label lblexception;
        private System.Windows.Forms.RichTextBox output;
        private System.Windows.Forms.ComboBox cmbinstwidth;
        private System.Windows.Forms.ComboBox cmbinstdepth;
        private System.Windows.Forms.Label lblinstmiftxt;
        private System.Windows.Forms.Label lblinstmifwidth;
        private System.Windows.Forms.Label lblinstmifdepth;
        private System.Windows.Forms.Label lbldatamifdepth;
        private System.Windows.Forms.Label lbldatamifwidth;
        private System.Windows.Forms.Label lbldatamiftxt;
        private System.Windows.Forms.ComboBox cmbdatadepth;
        private System.Windows.Forms.ComboBox cmbdatawidth;
    }
}
