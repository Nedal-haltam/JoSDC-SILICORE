
module InstQ
(
    input clk, rst,
    input  [31:0] PC,
    
    output reg [ 11:0] opcode,
    output reg [ 4:0] rs, rt, rd, shamt,
    output reg [15:0] immediate,
    output reg [25:0] address,
    output reg [31:0] pc,
    output reg VALID_Inst
);


reg [31:0] InstMem [1023:0];

wire [31:0] inst;

assign inst = InstMem[PC];


always@(negedge clk, posedge rst) begin
    if (rst) begin
        opcode <= 0;
        rs <= 0;
        rt <= 0;
        rd <= 0;
        shamt <= 0;
        immediate <= 0;
        address <= 0;
        VALID_Inst <= 1'b0;
    end
    else begin
        if (inst[31:26] == 0)
            opcode    <= { inst[31:26], inst[5:0] };
        else
            opcode    <= { inst[31:26], 6'd0 };

        rs         <= inst[25:21];
        rt         <= inst[20:16];
        rd         <= inst[15:11];
        shamt      <= inst[10:6];
        immediate  <= inst[15:0];
        address    <= inst[25:0];
        VALID_Inst <= 1'b1;
        pc         <= PC;
    end
end


integer i;
initial begin

for (i = 0; i < 1024; i = i + 1)
    InstMem[i] = 0;


`ifndef test
`include "IM_INIT.INIT"
`else


InstMem[  0] <= 32'h2001007B; // addi $1 $0 123
InstMem[  1] <= 32'h10200003; // beq $1 $0 3
InstMem[  2] <= 32'hAC010000; // sw $1 0 ( $0 )
InstMem[  3] <= 32'h10210002; // beq $1 $1 2
InstMem[  4] <= 32'hAC010001; // sw $1 1 ( $zero )
InstMem[  5] <= 32'hFC000000; // hlt





`endif














/* run the following to simulate in VS Code, note you should be in '\GitHub Repos\JoSDC-SILICORE\SSOOO' in the terminal
> iverilog -o sim -D vscode .\SSOOO_Sim.v
> vvp sim
*/







end


endmodule
