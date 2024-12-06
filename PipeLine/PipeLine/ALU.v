module ALU(A, B, res, ZF, CF, ALUOP);

parameter bit_width = 32; // BIT WIDTH
input [bit_width-1:0] A,B;
input [3:0] ALUOP;
output reg [bit_width-1:0] res;
output wire ZF;
output reg CF;
  
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

  always @(*) begin

case (ALUOP)

    4'b0000: begin
    {CF , res} <= A + B;
    end
    4'b0001: begin
    {CF , res} <= A - B;
    end   
    4'b0010: begin
    {CF , res} <= A & B;
    end   
    4'b0011: begin
    {CF , res} <= A | B;
    end   
    4'b0100: begin
    {CF , res} <= A ^ B;
    end
    4'b0101: begin
	 {CF , res} <= ~(A | B);
    end
    4'b0110: begin
    CF <= (B > bit_width) ? 0 : CF&(B == 0) | (A[bit_width - B])&(B != 0);
    res <= A << B;
    end
    4'b0111: begin
    CF <= (B > bit_width) ? 0 : CF&(B == 0) | (A[B - 1])&(B != 0);
    res <= A >> B;
    end
    4'b1000: begin
    CF <= 0;
    res <= ($signed(A) < $signed(B)) ? 32'd1 : 32'd0;
    end
    4'b1001: begin
    CF <= 0;
    res <= ($signed(A) > $signed(B)) ? 32'd1 : 32'd0;
    end
endcase
    // the zero flag is high if and only if all bits are low so I did an or gate first (as a reduction operator) 
    // and then invert it

end
    assign ZF = ~(|res);
endmodule