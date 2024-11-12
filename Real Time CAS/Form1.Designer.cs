namespace Real_Time_CAS_ASSEM
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
            this.components = new System.ComponentModel.Container();
            this.input = new System.Windows.Forms.RichTextBox();
            this.timer1 = new System.Windows.Forms.Timer(this.components);
            this.lblErrInvinst = new System.Windows.Forms.Label();
            this.lblErrMultlabels = new System.Windows.Forms.Label();
            this.lblErrInvlabel = new System.Windows.Forms.Label();
            this.lblnumofinst = new System.Windows.Forms.Label();
            this.lblnumofinsttxt = new System.Windows.Forms.Label();
            this.output = new System.Windows.Forms.RichTextBox();
            this.lblcyclestxt = new System.Windows.Forms.Label();
            this.lblcycles = new System.Windows.Forms.Label();
            this.lblErrInfloop = new System.Windows.Forms.Label();
            this.btntbcopy = new System.Windows.Forms.Button();
            this.cmbcpulist = new System.Windows.Forms.ComboBox();
            this.lblErr = new System.Windows.Forms.Label();
            this.lblNoErr = new System.Windows.Forms.Label();
            this.btncascopy = new System.Windows.Forms.Button();
            this.SuspendLayout();
            // 
            // input
            // 
            this.input.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left)));
            this.input.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.input.Location = new System.Drawing.Point(30, 34);
            this.input.Margin = new System.Windows.Forms.Padding(4);
            this.input.Name = "input";
            this.input.Size = new System.Drawing.Size(439, 579);
            this.input.TabIndex = 7;
            this.input.Text = "";
            this.input.TextChanged += new System.EventHandler(this.input_TextChanged);
            // 
            // timer1
            // 
            this.timer1.Enabled = true;
            this.timer1.Interval = 1000;
            // 
            // lblErrInvinst
            // 
            this.lblErrInvinst.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.lblErrInvinst.AutoSize = true;
            this.lblErrInvinst.ForeColor = System.Drawing.Color.Red;
            this.lblErrInvinst.Location = new System.Drawing.Point(1098, 122);
            this.lblErrInvinst.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.lblErrInvinst.Name = "lblErrInvinst";
            this.lblErrInvinst.Size = new System.Drawing.Size(164, 16);
            this.lblErrInvinst.TabIndex = 13;
            this.lblErrInvinst.Text = "Invalid Instruction detected";
            this.lblErrInvinst.Visible = false;
            // 
            // lblErrMultlabels
            // 
            this.lblErrMultlabels.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.lblErrMultlabels.AutoSize = true;
            this.lblErrMultlabels.ForeColor = System.Drawing.Color.Red;
            this.lblErrMultlabels.Location = new System.Drawing.Point(1098, 204);
            this.lblErrMultlabels.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.lblErrMultlabels.Name = "lblErrMultlabels";
            this.lblErrMultlabels.Size = new System.Drawing.Size(181, 16);
            this.lblErrMultlabels.TabIndex = 12;
            this.lblErrMultlabels.Text = "Redundent Label(s) detected";
            this.lblErrMultlabels.Visible = false;
            // 
            // lblErrInvlabel
            // 
            this.lblErrInvlabel.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.lblErrInvlabel.AutoSize = true;
            this.lblErrInvlabel.ForeColor = System.Drawing.Color.Red;
            this.lblErrInvlabel.Location = new System.Drawing.Point(1098, 178);
            this.lblErrInvlabel.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.lblErrInvlabel.Name = "lblErrInvlabel";
            this.lblErrInvlabel.Size = new System.Drawing.Size(154, 16);
            this.lblErrInvlabel.TabIndex = 11;
            this.lblErrInvlabel.Text = "Invalid Label(s) detected";
            this.lblErrInvlabel.Visible = false;
            // 
            // lblnumofinst
            // 
            this.lblnumofinst.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.lblnumofinst.AutoSize = true;
            this.lblnumofinst.Location = new System.Drawing.Point(674, 14);
            this.lblnumofinst.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.lblnumofinst.Name = "lblnumofinst";
            this.lblnumofinst.Size = new System.Drawing.Size(14, 16);
            this.lblnumofinst.TabIndex = 10;
            this.lblnumofinst.Text = "0";
            // 
            // lblnumofinsttxt
            // 
            this.lblnumofinsttxt.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.lblnumofinsttxt.AutoSize = true;
            this.lblnumofinsttxt.Location = new System.Drawing.Point(519, 12);
            this.lblnumofinsttxt.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.lblnumofinsttxt.Name = "lblnumofinsttxt";
            this.lblnumofinsttxt.Size = new System.Drawing.Size(147, 16);
            this.lblnumofinsttxt.TabIndex = 9;
            this.lblnumofinsttxt.Text = "Number of Instructions : ";
            // 
            // output
            // 
            this.output.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left)));
            this.output.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.output.Location = new System.Drawing.Point(523, 34);
            this.output.Margin = new System.Windows.Forms.Padding(4);
            this.output.Name = "output";
            this.output.Size = new System.Drawing.Size(567, 579);
            this.output.TabIndex = 8;
            this.output.Text = "";
            // 
            // lblcyclestxt
            // 
            this.lblcyclestxt.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.lblcyclestxt.AutoSize = true;
            this.lblcyclestxt.Location = new System.Drawing.Point(714, 12);
            this.lblcyclestxt.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.lblcyclestxt.Name = "lblcyclestxt";
            this.lblcyclestxt.Size = new System.Drawing.Size(186, 16);
            this.lblcyclestxt.TabIndex = 14;
            this.lblcyclestxt.Text = "Number of cycles consumed : ";
            // 
            // lblcycles
            // 
            this.lblcycles.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.lblcycles.AutoSize = true;
            this.lblcycles.Location = new System.Drawing.Point(908, 14);
            this.lblcycles.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.lblcycles.Name = "lblcycles";
            this.lblcycles.Size = new System.Drawing.Size(14, 16);
            this.lblcycles.TabIndex = 15;
            this.lblcycles.Text = "0";
            // 
            // lblErrInfloop
            // 
            this.lblErrInfloop.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.lblErrInfloop.AutoSize = true;
            this.lblErrInfloop.ForeColor = System.Drawing.Color.Red;
            this.lblErrInfloop.Location = new System.Drawing.Point(1098, 150);
            this.lblErrInfloop.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.lblErrInfloop.Name = "lblErrInfloop";
            this.lblErrInfloop.Size = new System.Drawing.Size(130, 16);
            this.lblErrInfloop.TabIndex = 16;
            this.lblErrInfloop.Text = "infinite loop detected";
            this.lblErrInfloop.Visible = false;
            // 
            // btntbcopy
            // 
            this.btntbcopy.Location = new System.Drawing.Point(1101, 6);
            this.btntbcopy.Name = "btntbcopy";
            this.btntbcopy.Size = new System.Drawing.Size(95, 29);
            this.btntbcopy.TabIndex = 17;
            this.btntbcopy.Text = "TB_copy";
            this.btntbcopy.UseVisualStyleBackColor = true;
            this.btntbcopy.Click += new System.EventHandler(this.btntbcopy_Click);
            // 
            // cmbcpulist
            // 
            this.cmbcpulist.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cmbcpulist.FormattingEnabled = true;
            this.cmbcpulist.Items.AddRange(new object[] {
            "Pipe Lined",
            "Single Cycle"});
            this.cmbcpulist.Location = new System.Drawing.Point(1101, 41);
            this.cmbcpulist.MaxDropDownItems = 4;
            this.cmbcpulist.Name = "cmbcpulist";
            this.cmbcpulist.Size = new System.Drawing.Size(121, 24);
            this.cmbcpulist.Sorted = true;
            this.cmbcpulist.TabIndex = 18;
            this.cmbcpulist.SelectedIndexChanged += new System.EventHandler(this.cmbcpulist_SelectedIndexChanged);
            // 
            // lblErr
            // 
            this.lblErr.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.lblErr.AutoSize = true;
            this.lblErr.ForeColor = System.Drawing.Color.Red;
            this.lblErr.Location = new System.Drawing.Point(1098, 94);
            this.lblErr.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.lblErr.Name = "lblErr";
            this.lblErr.Size = new System.Drawing.Size(46, 16);
            this.lblErr.TabIndex = 19;
            this.lblErr.Text = "Errors:";
            // 
            // lblNoErr
            // 
            this.lblNoErr.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.lblNoErr.AutoSize = true;
            this.lblNoErr.ForeColor = System.Drawing.Color.Red;
            this.lblNoErr.Location = new System.Drawing.Point(1152, 94);
            this.lblNoErr.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.lblNoErr.Name = "lblNoErr";
            this.lblNoErr.Size = new System.Drawing.Size(122, 16);
            this.lblNoErr.TabIndex = 20;
            this.lblNoErr.Text = "No Errors Detected";
            this.lblNoErr.Visible = false;
            // 
            // btncascopy
            // 
            this.btncascopy.Location = new System.Drawing.Point(1000, 6);
            this.btncascopy.Name = "btncascopy";
            this.btncascopy.Size = new System.Drawing.Size(95, 29);
            this.btncascopy.TabIndex = 21;
            this.btncascopy.Text = "CAS copy";
            this.btncascopy.UseVisualStyleBackColor = true;
            this.btncascopy.Click += new System.EventHandler(this.btncascopy_Click);
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 16F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(1346, 664);
            this.Controls.Add(this.btncascopy);
            this.Controls.Add(this.lblNoErr);
            this.Controls.Add(this.lblErr);
            this.Controls.Add(this.cmbcpulist);
            this.Controls.Add(this.btntbcopy);
            this.Controls.Add(this.lblErrInfloop);
            this.Controls.Add(this.lblcycles);
            this.Controls.Add(this.lblcyclestxt);
            this.Controls.Add(this.input);
            this.Controls.Add(this.lblErrInvinst);
            this.Controls.Add(this.lblErrMultlabels);
            this.Controls.Add(this.lblErrInvlabel);
            this.Controls.Add(this.lblnumofinst);
            this.Controls.Add(this.lblnumofinsttxt);
            this.Controls.Add(this.output);
            this.Name = "Form1";
            this.Text = "Form1";
            this.Load += new System.EventHandler(this.Form1_Load);
            this.Resize += new System.EventHandler(this.Form1_Resize);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.RichTextBox input;
        private System.Windows.Forms.Timer timer1;
        private System.Windows.Forms.Label lblErrInvinst;
        private System.Windows.Forms.Label lblErrMultlabels;
        private System.Windows.Forms.Label lblErrInvlabel;
        private System.Windows.Forms.Label lblnumofinst;
        private System.Windows.Forms.Label lblnumofinsttxt;
        private System.Windows.Forms.RichTextBox output;
        private System.Windows.Forms.Label lblcyclestxt;
        private System.Windows.Forms.Label lblcycles;
        private System.Windows.Forms.Label lblErrInfloop;
        private System.Windows.Forms.Button btntbcopy;
        private System.Windows.Forms.ComboBox cmbcpulist;
        private System.Windows.Forms.Label lblErr;
        private System.Windows.Forms.Label lblNoErr;
        private System.Windows.Forms.Button btncascopy;
    }
}

