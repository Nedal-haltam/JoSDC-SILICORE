module controlUnit(opcode, funct, rst,
				   RegDst, MemReadEn, MemtoReg,
				   ALUOp, MemWriteEn, RegWriteEn, ALUSrc, hlt);
				   
		
	// inputs 
	input wire [5:0] opcode, funct; // correct inputs and sizes
	input rst; // added reset input signal
	
	// outputs (signals)
	output reg RegDst, MemReadEn, MemtoReg, MemWriteEn, RegWriteEn, ALUSrc, hlt; // correct outputs
	output reg [2:0] ALUOp;
	
	// parameters (opcodes/functs)
`include "opcodes.v"	
	
	// unit logic - generate signals
	always @(*) begin
		
		// Bug ID = 21, initialize control signals to zeros when reseting
		if(~rst) begin // initializes all output signals to zero when the reset signal is set
			// Bug ID = 6: non-blocking used to assign signal values
			RegDst <= 1'b0;  MemReadEn <= 1'b0; MemtoReg <= 1'b0;
			MemWriteEn <= 1'b0; RegWriteEn <= 1'b0; ALUSrc <= 1'b0;
			ALUOp <= 3'b0; hlt <= 1'b0;
		end
		else begin
			// initializes all output signals to zero
			RegDst <= 1'b0;  MemReadEn <= 1'b0; MemtoReg <= 1'b0;
			MemWriteEn <= 1'b0; RegWriteEn <= 1'b0; ALUSrc <= 1'b0;
			ALUOp <= 3'b0; hlt <= 1'b0;

			case(opcode)


				hlt_inst: begin
					hlt <= 1'b1;

				end
					
				_RType : begin
					
					RegDst <= 1'b1; // correct signal - destination register is rd
					MemReadEn <= 1'b0; // correct signal - no memory read
					MemtoReg <= 1'b0; // correct signal - will write back to rd from ALU
					MemWriteEn <= 1'b0; // correct signal - no memory write
					RegWriteEn <= 1'b1; // correct signal - will write back to rd
					ALUSrc <= 1'b0; // correct signal - operand taken from register file
						
					case (funct) 
						
						_add_ : begin
							ALUOp <= 3'b000; // correct op - add = 0
						end
							
						_sub_ : begin
							ALUOp <= 3'b001; // correct op - sub = 1
						end
							
						_and_ : begin
							ALUOp <= 3'b010; // correct op - and = 2
						end
							
						_or_ : begin 
							ALUOp <= 3'b011; // Bug ID = 22: correct op - or = 3
						end
							
						_slt_ : begin
							ALUOp <= 3'b100; // correct op - compare = 4
						end
						
						default: RegWriteEn <= 1'b0; // Bug ID = 7: ensures register file is not changed for invalid funct
					
					endcase
					
				end
					
				_addi : begin
					RegDst <= 1'b0; // correct signal - destinaiton is rt
					MemReadEn <= 1'b0; // correct signal - no memory read
					MemtoReg <= 1'b0; // correct signal - will write back to rt from ALU
					ALUOp <= 3'b000; // correct op - add = 0
					MemWriteEn <= 1'b0; // correct signal - no memory write
					RegWriteEn <= 1'b1; // correct signal - will write back to rt
					ALUSrc <= 1'b1; // correct signal - operand is the immediate	
				end
					
				_lw : begin
					RegDst <= 1'b0; // Bug ID = 1: was 1, changed to 0 - destination register is rt
					MemReadEn <= 1'b1; // Bug ID = 2: was 0, changed to 1 - will read from memory
					ALUOp <= 3'b000; // correct op - add = 0
					MemWriteEn <= 1'b0; // Bug ID = 3: was 1, changed to 0 - will not write to memory 
					RegWriteEn <= 1'b1; // correct signal - will write back to rt
					ALUSrc <= 1'b1; // correct signal - operand is the immediate
					MemtoReg <= 1'b1; // Bug ID = 4: added signal - write back to register from data memory
				end
					
				_sw : begin
					MemReadEn <= 1'b0; // correct signal - will not read from memory
					ALUOp <= 3'b000; // correct op - add = 0
					MemWriteEn <= 1'b1; // correct signal - will write to data memory
					RegWriteEn <= 1'b0; // correct signal - will not write back to register file
					ALUSrc <= 1'b1; // correct signal - operand is immediate			
				end
					
				_beq : begin
					MemReadEn <= 1'b0; // correct signal - will not read from memory
					ALUOp <= 3'b001; // correct signal - sub = 1
					MemWriteEn <= 1'b0; // correct signal - will not write to memory
					RegWriteEn <= 1'b0; // correct signal - will not write to register file
					ALUSrc <= 1'b0; // Bug ID =  5: was 1, changed to 0 - operand is rt
				end
				
				default: ;
			endcase
		end	
	end
	
	
endmodule