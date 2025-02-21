`define MEMORY_SIZE 2048
`define MEMORY_BITS 11

module InstQ
(
    input clk, rst,
    input  [31:0] PC_from_assign,
    input  [31:0] PC,
    
    output reg [ 11:0] opcode1,
    output reg [ 4:0] rs1, rt1, rd1, shamt1,
    output reg [15:0] immediate1,
    output reg [25:0] address1,
    output reg [31:0] pc1,

    output reg [ 11:0] opcode2,
    output reg [ 4:0] rs2, rt2, rd2, shamt2,
    output reg [15:0] immediate2,
    output reg [25:0] address2,
    output reg [31:0] pc2,


    output reg VALID_Inst
);

wire [31:0] inst1, inst2;



`ifdef vscode
    reg [31:0] InstMem [0 : (`MEMORY_SIZE-1)];
    assign inst1 = InstMem[PC + 2'd0];
    assign inst2 = InstMem[PC + 2'd1];
`else
    `ifdef VGA
        reg [31:0] InstMem [0 : (`MEMORY_SIZE-1)];
        assign inst1 = InstMem[PC + 2'd0];
        assign inst2 = InstMem[PC + 2'd1];
    `else
        instmemoryip lksdjfkldsj
        (
            .address(PC_from_assign),
            .clock(clk),
            .q(inst1)
        );
    `endif
`endif


always@(negedge clk, posedge rst) begin
    if (rst) begin
        opcode1 <= 0;
        opcode2 <= 0;
        VALID_Inst <= 1'b0;
    end
    else begin
        if (inst1[31:26] == 0)
            opcode1    <= { inst1[31:26], inst1[5:0] };
        else
            opcode1    <= { inst1[31:26], 6'd0 };

        rs1         <= inst1[25:21];
        rt1         <= inst1[20:16];
        rd1         <= inst1[15:11];
        shamt1      <= inst1[10:6];
        immediate1  <= inst1[15:0];
        address1    <= inst1[25:0];
        pc1         <= PC;

        if (inst2[31:26] == 0)
            opcode2    <= { inst2[31:26], inst2[5:0] };
        else
            opcode2    <= { inst2[31:26], 6'd0 };

        rs2         <= inst2[25:21];
        rt2         <= inst2[20:16];
        rd2         <= inst2[15:11];
        shamt2      <= inst2[10:6];
        immediate2  <= inst2[15:0];
        address2    <= inst2[25:0];
        pc2         <= PC;


        VALID_Inst <= (0 <= PC && PC <= (`MEMORY_SIZE-1));
    end
end


`ifdef vscode
    integer i;
    initial begin
    for (i = 0; i <= (`MEMORY_SIZE-1); i = i + 1)
        InstMem[i] <= 0;

    `ifdef test
        `include "./Instruction Queue/IM_INIT.INIT"
    `else
        `include "IM_INIT.INIT"
    `endif
    end
`else
    `ifdef VGA
        initial begin
            `include "code.txt"
        end
    `endif
`endif

endmodule


/*

`define MEMORY_SIZE 2048
`define MEMORY_BITS 11

module InstQ
(
    input clk, rst,
    input  [31:0] PC_from_assign,
    input  [31:0] PC,
    
    output reg [ 11:0] opcode1,
    output reg [ 4:0] rs1, rt1, rd1, shamt1,
    output reg [15:0] immediate1,
    output reg [25:0] address1,
    output reg [31:0] pc1,

    output reg [ 11:0] opcode2,
    output reg [ 4:0] rs2, rt2, rd2, shamt2,
    output reg [15:0] immediate2,
    output reg [25:0] address2,
    output reg [31:0] pc2,


    output reg VALID_Inst
);

wire [31:0] inst1, inst2;
`ifdef vscode
    reg [31:0] InstMem [0 : (`MEMORY_SIZE-1)];
    assign inst1 = InstMem[PC + 2'd0];
    assign inst2 = InstMem[PC + 2'd1];
`else
instmemoryip instruction_memory
(
	.address_a(PC_from_assign + 2'd0),
	.address_b(PC_from_assign + 2'd1),
	.clock_a(clk),
	.clock_b(clk),
	.data_a(32'd0),
	.data_b(32'd0),
	.wren_a(1'b0),
	.wren_b(1'b0),
	.q_a(inst1),
	.q_b(inst2)
);

`endif


always@(negedge clk, posedge rst) begin
    if (rst) begin
        opcode1 <= 0;
        opcode2 <= 0;
        VALID_Inst <= 1'b0;
    end
    else begin
        if (inst1[31:26] == 0)
            opcode1    <= { inst1[31:26], inst1[5:0] };
        else
            opcode1    <= { inst1[31:26], 6'd0 };

        rs1         <= inst1[25:21];
        rt1         <= inst1[20:16];
        rd1         <= inst1[15:11];
        shamt1      <= inst1[10:6];
        immediate1  <= inst1[15:0];
        address1    <= inst1[25:0];
        pc1         <= PC;

        if (inst2[31:26] == 0)
            opcode2    <= { inst2[31:26], inst2[5:0] };
        else
            opcode2    <= { inst2[31:26], 6'd0 };

        rs2         <= inst2[25:21];
        rt2         <= inst2[20:16];
        rd2         <= inst2[15:11];
        shamt2      <= inst2[10:6];
        immediate2  <= inst2[15:0];
        address2    <= inst2[25:0];
        pc2         <= PC;


        VALID_Inst <= (0 <= PC && PC <= (`MEMORY_SIZE-1));
    end
end


// `ifdef vscode

integer i;
initial begin

for (i = 0; i <= (`MEMORY_SIZE-1); i = i + 1)
    InstMem[i] <= 0;

`ifdef test
`include "./Instruction Queue/IM_INIT.INIT"
`else
`include "IM_INIT.INIT"
`endif
end

// `endif

endmodule


*/


