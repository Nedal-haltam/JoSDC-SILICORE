
// module processor(clk, rst, PC);

module processor(input_clk, rst, PC, regs0, regs1, regs2, regs3, regs4, regs5, cycles_consumed, clkout);
	//inputs
	input input_clk, rst;
	wire clk;
	//outputs
	output clkout;
	output [5:0] PC;
	output reg [31:0] cycles_consumed;
	
	wire [31:0] instruction, writeData, readData1, readData2, extImm, ALUin2, ALUResult, memoryReadData;
	wire [15:0] imm;
	wire [5:0] opCode, funct, nextPC, PCPlus1, adderResult;
	wire [4:0] rs, rt, rd, WriteRegister;
	wire [2:0] ALUOp;
	wire RegDst, Branch, MemReadEn, MemtoReg, MemWriteEn, RegWriteEn, ALUSrc, zero, PCsrc, hlt;

	
	output [31 : 0] regs0;
	output [31 : 0] regs1;
	output [31 : 0] regs2;
	output [31 : 0] regs3;
	output [31 : 0] regs4;
	output [31 : 0] regs5;	
	
	
	assign opCode = instruction[31:26];
	assign rd = instruction[15:11];
	assign rs = instruction[25:21];
	assign rt = instruction[20:16];
	assign imm = instruction[15:0];
	assign funct = instruction[5:0];

	or hlt_logic(clk, input_clk, hlt);

	assign clkout = clk;
	
	
	
	always@(posedge clk , negedge rst) begin
	if (~rst)
		cycles_consumed <= 32'd0;
	else
		cycles_consumed <= cycles_consumed + 32'd1;

end
	
	programCounter pc(.clk(clk), .rst(rst), .PCin(nextPC), .PCout(PC));
	
	adder PCAdder(.in1(PC), .in2(6'b1), .out(PCPlus1));	
	

IM instructionMemory(.address(PC), .q(instruction));
// `ifdef sim
// `else
// 	instructionMemory IM(.address(nextPC), .clock(clk), .q(instruction));
// `endif	

	controlUnit CU(.opCode(opCode), .funct(funct), .rst(rst),
				      .RegDst(RegDst), .Branch(Branch), .MemReadEn(MemReadEn), .MemtoReg(MemtoReg),
				      .ALUOp(ALUOp), .MemWriteEn(MemWriteEn), .RegWriteEn(RegWriteEn), .ALUSrc(ALUSrc), .hlt(hlt));
	
	mux2x1 #(5) RFMux(.in1(rt), .in2(rd), .s(RegDst), .out(WriteRegister));
	
	registerFile RF(.clk(clk), .rst(rst), .we(RegWriteEn), 					
					    .readRegister1(rs), .readRegister2(rt), .writeRegister(WriteRegister),
					    .writeData(writeData), .readData1(readData1), .readData2(readData2),.regs0(regs0), .regs1(regs1), 
						 .regs2(regs2), .regs3(regs3), .regs4(regs4), .regs5(regs5));
					 
	SignExtender SignExtend(.in(imm), .out(extImm));
	
	mux2x1 #(32) ALUMux(.in1(readData2), .in2(extImm), .s(ALUSrc), .out(ALUin2));
	
	ALU alu(.operand1(readData1), .operand2(ALUin2), .opSel(ALUOp), .result(ALUResult), .zero(zero));
	
	ANDGate branchAnd(.in1(zero), .in2(Branch), .out(PCsrc));
	
	adder branchAdder(.in1(PC), .in2(imm[5:0]), .out(adderResult));
	
`ifdef sim
	DM dataMemory(.address(ALUResult[7:0]), .clock(clk), .data(readData2), .rden(MemReadEn), .wren(MemWriteEn), .q(memoryReadData));
`else
	dataMemory DM(.address(ALUResult[7:0]), .clock(clk), .data(readData2), .rden(MemReadEn), .wren(MemWriteEn), .q(memoryReadData));
`endif	

	mux2x1 #(32) WBMux(.in1(ALUResult), .in2(memoryReadData), .s(MemtoReg), .out(writeData));
	mux2x1 #(6) PCMux(.in1(PCPlus1), .in2(adderResult), .s(PCsrc), .out(nextPC));
	
endmodule
