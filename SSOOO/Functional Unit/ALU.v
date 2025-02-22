


`define MEMORY_SIZE 2048
`define MEMORY_BITS 11
`define ROB_SIZE_bits (4)
`define BUFFER_SIZE_bitslsbuffer (4)
`define BUFFER_SIZE_bitsRS (4)
`define ROB_SIZE ((1 << `ROB_SIZE_bits))


module ALU
(
    input clk, rst,
    input [`ROB_SIZE_bits:0] ROBEN,
    input [11:0] opcode,
    input is_beq, is_bne,
    input [31:0] A, B,
    input [3:0] ALUOP,


    output reg [31:0] FU_res,
    output reg FU_Branch_Decision,
    output reg [`ROB_SIZE_bits:0] FU_ROBEN,
    output reg [11:0] FU_opcode,
    output FU_Is_Free
);

`ifdef vscode
`include "opcodes.txt"
`else
`include "../opcodes.txt"
`endif  
// ALUOP -> OP 
// 0000   -> add
// 0001   -> sub
// 0010   -> and
// 0011   -> or
// 0100   -> xor
// 0101   -> nor
// 0110   -> shift left here we shift A, B times
// 0111   -> shift right
// 1000   -> if (A < B) then 1 else 0 (aka. slt)
// 1001   -> if (A > B) then 1 else 0 (aka. sgt)
// this module takes the opcode and based on it. it decides what operation the ALU should do.



reg [31:0] Reg_res;
wire is_equal;
compare_equal compare(is_equal, A, B);


always @(*) begin

case (ALUOP)

    4'b0000: begin
    Reg_res <= A + B;
    end
    4'b0001: begin
    Reg_res <= A - B;
    end   
    4'b0010: begin
    Reg_res <= A & B;
    end   
    4'b0011: begin
    Reg_res <= A | B;
    end   
    4'b0100: begin
    Reg_res <= A ^ B;
    end
    4'b0101: begin
	 Reg_res <= ~(A | B);
    end
    4'b0110: begin
    Reg_res <= A << B;
    end
    4'b0111: begin
    Reg_res <= A >> B;
    end
    4'b1000: begin
    Reg_res <= ($signed(A) < $signed(B)) ? 32'd1 : 32'd0;
    end
    4'b1001: begin
    Reg_res <= ($signed(A) > $signed(B)) ? 32'd1 : 32'd0;
    end
endcase
end


assign FU_Is_Free = 1'b1;
always@(negedge clk, posedge rst) begin
    if (rst) begin
        FU_res <= 0;
        FU_opcode <= 0;
        FU_ROBEN <= 0;
        FU_Branch_Decision <= 0;
    end
    else begin
        FU_ROBEN <= ROBEN;
        FU_res <= Reg_res;
        FU_opcode <= opcode;
        FU_Branch_Decision <= (is_beq && is_equal) || (is_bne && ~is_equal);
    end
end


endmodule