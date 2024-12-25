module InstQ
(
    input clk, rst,
    input  [31:0] PC,
    
    output reg [ 11:0] opcode,
    output reg [ 4:0] rs, rt, rd, shamt,
    output reg [15:0] immediate,
    output reg [25:0] address,
    output reg VALID_Inst
);


reg [31:0] InstMem [63:0];

wire [31:0] inst;

assign inst = InstMem[PC];


always@(posedge clk, posedge rst) begin
    if (rst) begin
        opcode = 0;
        rs = 0;
        rt = 0;
        rd = 0;
        shamt = 0;
        immediate = 0;
        address = 0;
        VALID_Inst = 1'b0;
    end
    else begin
        if (inst[31:26] == 0)
            opcode    = { inst[31:26], inst[5:0] };
        else
            opcode    = { inst[31:26], 6'd0 };

        rs        = inst[25:21];
        rt        = inst[20:16];
        rd        = inst[15:11];
        shamt     = inst[10:6];
        immediate = inst[15:0];
        address   = inst[25:0];
        VALID_Inst = 1'b1;
    end
end


// here we initialze the instruction Memory using the Real time CAS
initial begin


InstMem[  0] <= 32'h2001007B; // addi $1 $zero 123
InstMem[  1] <= 32'h00211020; // add $2 $1 $1
InstMem[  2] <= 32'h2042007B; // addi $2 $2 123
InstMem[  3] <= 32'h20030000; // addi $3 $zero 0
InstMem[  4] <= 32'h206303E7; // addi $3 $3 999
InstMem[  5] <= 32'hFC000000; // hlt

end


endmodule
