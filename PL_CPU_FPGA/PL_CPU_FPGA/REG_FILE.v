
module REG_FILE(rd_reg1, rd_reg2, wr_reg, wr_data, rd_data1, rd_data2, reg_wr,clk, rst);///
parameter bit_width = 32;

input [bit_width-1:0] wr_data;
input [4:0] rd_reg1, rd_reg2, wr_reg;
input reg_wr, clk, rst;

output [bit_width-1:0] rd_data1;
output [bit_width-1:0] rd_data2;

reg [bit_width-1:0] reg_file [31:0];


integer i;
 


always@ (posedge clk , posedge rst) begin
    
if (rst) begin
  for (i = 0; i < 32; i = i + 1)
    reg_file[i] = 0;

end
else begin
  if(wr_reg != 0 && reg_wr == 1'b1)
	reg_file[wr_reg] <= wr_data;
	
	reg_file[0] <= 32'd0;
end

end

assign rd_data1 = reg_file[rd_reg1];
assign rd_data2 = reg_file[rd_reg2];


`ifdef sim
initial begin
  #(`MAX_CLOCKS + `reset + 1);
  // iterating through the register file to check if the program changed the contents correctly
  $display("Reading Register File : ");
  for (integer i = 31; i >= 0; i = i - 1)
    $display("index = %d , reg_out : signed = %d , unsigned = %d",i, $signed(reg_file[i]), $unsigned(reg_file[i]));
end 
`endif



endmodule