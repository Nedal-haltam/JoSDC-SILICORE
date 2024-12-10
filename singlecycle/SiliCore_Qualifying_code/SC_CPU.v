module SC_CPU(input_clk, rst, PC, cycles_consumed, clk);

	`include "opcodes.txt"
	//inputs
	input input_clk, rst;
	output wire clk;
	//outputs
	output [31:0] PC;
	output reg [31:0] cycles_consumed;
	
	wire [31:0] instruction, wire_instruction, writeData, readData1, readData2, readData1_w, extImm, ALUin2;
	wire [31:0] ALUResult, memoryReadData, immediate, shamt, address, nextPC, PCPlus1, adderResult;
	wire [15:0] imm;
	wire [5:0] opcode, funct;
	wire [4:0] rs, rt, rd, WriteRegister;
	wire [3:0] ALUOp;
	wire RegDst, MemReadEn, MemtoReg, MemWriteEn, RegWriteEn, ALUSrc, zero, hlt;
	wire PCsrc;
	
	
	assign opcode  = (~rst) ? 0 : instruction[31:26];
	assign rd      = (~rst) ? 0 : ((opcode == jal) ? 5'd31 : instruction[15:11]);
	assign rs      = (~rst) ? 0 : instruction[25:21];
	assign rt      = (~rst) ? 0 : instruction[20:16];
	assign imm     = (~rst) ? 0 : instruction[15:0];
	assign shamt   = (~rst) ? 0 : {32'd0, instruction[10:6]};
	assign funct   = (~rst) ? 0 : instruction[5:0];
	assign address = (~rst) ? 0 : {32'd0, instruction[25:0]};


or hlt_logic(clk, input_clk, hlt);
 
	
always@(posedge clk , negedge rst) begin

	if (~rst)
		cycles_consumed <= 32'd0;
	else
		cycles_consumed <= cycles_consumed + 32'd1;

end

BranchController branchcontroller(.opcode(opcode), .funct(funct), .operand1(readData1), .operand2(ALUin2), .PCsrc(PCsrc), .rst(rst));


assign PCPlus1 = PC + 32'd1;
assign adderResult = (opcode == jal || opcode == j) ? address : 
(
	(opcode == 0 && funct == jr) ? readData1 : ( PC + {{32{imm[15]}}, imm})
);


assign nextPC = (PCsrc) ? adderResult : PCPlus1;
programCounter pc(.clk(clk), .rst(rst), .PCin(nextPC), .PCout(PC));	


IM InstMem(.addr(PC), .Data_Out(wire_instruction));

assign instruction = (~rst) ? 0 : wire_instruction;

controlUnit CU(.opcode(opcode), .funct(funct), .rst(rst),
				      .RegDst(RegDst), .MemReadEn(MemReadEn), .MemtoReg(MemtoReg),
				      .ALUOp(ALUOp), .MemWriteEn(MemWriteEn), .RegWriteEn(RegWriteEn), .ALUSrc(ALUSrc), .hlt(hlt));
	
mux2x1 #(5) RFMux(.in1(rt), .in2(rd), .s(RegDst), .out(WriteRegister));
	
registerFile RF(.clk(clk), .rst(rst), .we(RegWriteEn), 					
			    .readRegister1(rs), .readRegister2(rt), .writeRegister(WriteRegister),
			    .writeData(writeData), .readData1(readData1), .readData2(readData2));


assign extImm = (opcode == andi || opcode == ori || opcode == xori) ? {16'd0, imm} : {{16{imm[15]}}, imm};
assign immediate = (opcode == 0 && (funct == sll || funct == srl)) ? shamt : (
	(opcode == jal) ? 32'd1 : extImm
);
mux2x1 #(32) ALUMux(.in1(readData2), .in2(immediate), .s(ALUSrc), .out(ALUin2));
	
assign readData1_w = (opcode == 0 && (funct == sll || funct == srl)) ? readData2 : (
	(opcode == jal) ? PC : readData1
);
ALU alu(.operand1(readData1_w), .operand2(ALUin2), .opSel(ALUOp), .result(ALUResult), .zero(zero));



DM dataMem(.address(ALUResult[31:0]), .clock(~clk), .data(readData2), .rden(MemReadEn), .wren(MemWriteEn), .q(memoryReadData));

mux2x1 #(32) WBMux(.in1(ALUResult), .in2(memoryReadData), .s(MemtoReg), .out(writeData));

	
endmodule
