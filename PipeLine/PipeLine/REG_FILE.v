
module REG_FILE(Read_reg1, Read_reg2, Write_reg, Write_data, Read_data1, Read_data2, Write_en, clk, rst);

input [31:0] Write_data;
input [4:0] Read_reg1, Read_reg2, Write_reg;
input Write_en, clk, rst;

output reg [31:0] Read_data1;
output reg [31:0] Read_data2;

reg [31:0] reg_file [31:0];


integer i;
always@ (posedge clk , posedge rst) begin
    
if (rst) begin
  for (i = 0; i < 32; i = i + 1)
    reg_file[i] <= 0;
end

else begin
  if(Write_reg && Write_en)
	reg_file[Write_reg] <= Write_data;
	
	reg_file[0] <= 0;
end

end

always@(posedge clk) begin

if (Write_reg == Read_reg1 && Write_reg && Write_en)
  Read_data1 <= Write_data;
else
  Read_data1 <= reg_file[Read_reg1];

end

always@(posedge clk) begin

if (Write_reg == Read_reg2 && Write_reg && Write_en)
  Read_data2 <= Write_data;
else
  Read_data2 <= reg_file[Read_reg2];

end

// assign Read_data1 = reg_file[Read_reg1];
// assign Read_data2 = reg_file[Read_reg2];


`ifdef vscode
initial begin
  #(`MAX_CLOCKS + `reset);
  // iterating through the register file to check if the program changed the contents correctly
  $display("Register file content : ");
  for (integer i = 0; i <= 31; i = i + 1)
    $display("index = %d , reg_out : signed = %d , unsigned = %d",i[31:0], $signed(reg_file[i]), $unsigned(reg_file[i]));
end 
`endif



endmodule