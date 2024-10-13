module controlUnit(opCode, funct, rst
				   RegDst, Branch, MemReadEn, MemtoReg,
				   ALUOp, MemWriteEn, RegWriteEn, ALUSrc);
				   
		
	// inputs 
	input wire [5:0] opCode, funct; // correct inputs and sizes
	input rst; // added reset input signal
	
	// outputs (signals)
	output reg RegDst, Branch, MemReadEn, MemtoReg, MemWriteEn, RegWriteEn, ALUSrc; // correct outputs
	output reg [2:0] ALUOp;
	
	// parameters (opCodes/functs)
	parameter _RType = 6'h0, _addi = 6'h8, _lw = 6'h23, _sw = 6'h2b, _beq = 6'h4; // correct opcodes
	parameter _add_ = 6'h20, _sub_ = 6'h22, _and_ = 6'h24, _or_ = 6'h25, _slt_ = 6'h2a; // correct functions
	
	
	// unit logic - generate signals
	always @(*) begin
		
		if(~rst) begin // initializes all output signals to zero when the reset signal is set
			RegDst = 1'b0; Branch = 1'b0; MemReadEn = 1'b0; MemtoReg = 1'b0;
			MemWriteEn = 1'b0; RegWriteEn = 1'b0; ALUSrc = 1'b0;
			ALUOp = 3'b0;
		end
		else begin
			// initializes all output signals to zero
			RegDst = 1'b0; Branch = 1'b0; MemReadEn = 1'b0; MemtoReg = 1'b0;
			MemWriteEn = 1'b0; RegWriteEn = 1'b0; ALUSrc = 1'b0;
			ALUOp = 3'b0;

			case(opCode)
					
				_RType : begin
					
					RegDst = 1'b1; // correct signal - destination register is rd
					Branch = 1'b0; // correct signal - not a branch instruction
					MemReadEn = 1'b0; // correct signal - no memory read
					MemtoReg = 1'b0; // correct signal - will write back to rd from ALU
					MemWriteEn = 1'b0; // correct signal - no memory write
					RegWriteEn = 1'b1; // correct signal - will write back to rd
					ALUSrc = 1'b0; // correct signal - operand taken from register file
						
					case (funct) 
						
						_add_ : begin
							ALUOp = 3'b000; // correct op - add = 0
						end
							
						_sub_ : begin
							ALUOp = 3'b001; // correct op - sub = 1
						end
							
						_and_ : begin
							ALUOp = 3'b010; // correct op - and = 2
						end
							
						_or_ : begin
							ALUOp = 3'd011; // correct op - or = 3
						end
							
						_slt_ : begin
							ALUOp = 3'b100; // correct op - compare = 4
						end
						
						default: RegWriteEn = 1'b0; // Bug ID = 7: ensures register file is not changed for invalid funct
					
					endcase
					
				end
					
				_addi : begin
					RegDst = 1'b0; // correct signal - destinaiton is rt
					Branch = 1'b0; // correct signal - not a branch instruction
					MemReadEn = 1'b0; // correct signal - no memory read
					MemtoReg = 1'b0; // correct signal - will write back to rt from ALU
					ALUOp = 3'b000; // correct op - add = 0
					MemWriteEn = 1'b0; // correct signal - no memory write
					RegWriteEn = 1'b1; // correct signal - will write back to rt
					ALUSrc = 1'b1; // correct signal - operand is the immediate	
				end
					
				_lw : begin
					RegDst = 1'b0; // Bug ID = 1: was 1, changed to 0 - destination register is rt
					Branch = 1'b0; // correct signal - not a branch instruction 
					MemReadEn = 1'b1; // Bug ID = 2: was 0, changed to 1 - will read from memory
					ALUOp = 3'b000; // correct op - add = 0
					MemWriteEn = 1'b0; // Bug ID = 3: was 1, changed to 0 - will not write to memory 
					RegWriteEn = 1'b1; // correct signal - will write back to rt
					ALUSrc = 1'b1; // correct signal - operand is the immediate
					MemtoReg = 1'b1; // Bug ID = 4: added signal - write back to register from data memory
				end
					
				_sw : begin
					Branch = 1'b0; // correct signal - not a branch instruction
					MemReadEn = 1'b0; // correct signal - will not read from memory
					ALUOp = 3'b000; // correct op - add = 0
					MemWriteEn = 1'b1; // correct signal - will write to data memory
					RegWriteEn = 1'b0; // correct signal - will not write back to register file
					ALUSrc = 1'b1; // correct signal - operand is immediate			
				end
					
				_beq : begin
					Branch = 1'b1; // correct signal - branch instruction
					MemReadEn = 1'b0; // correct signal - will not read from memory
					ALUOp = 3'b001; // correct signal - sub = 1
					MemWriteEn = 1'b0; // correct signal - will not write to memory
					RegWriteEn = 1'b0; // correct signal - will not write to register file
					ALUSrc = 1'b0; // Bug ID =  5: was 1, changed to 0 - operand is rt
				end
				
				default: begin
					// added signals when opCode is random
					Branch = 1'b0; // prevents random branching 
					MemWriteEn = 1'b0; // prevents writing random values to data memory
					RegWriteEn = 1'b0; // prevents writing random values to register file
				end
			endcase
		end	
	end
	
	
endmodule
