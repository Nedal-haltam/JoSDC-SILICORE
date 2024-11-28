module controlUnit(opcode, funct, rst,
				   RegDst, MemReadEn, MemtoReg,
				   ALUOp, MemWriteEn, RegWriteEn, ALUSrc, hlt);
				   
		
	// inputs 
	input wire [5:0] opcode, funct; // correct inputs and sizes
	input rst; // added reset input signal
	
	// outputs (signals)
	output reg RegDst, MemReadEn, MemtoReg, MemWriteEn, RegWriteEn, ALUSrc, hlt; // correct outputs
	output reg [3:0] ALUOp;
	
	// parameters (opcodes/functs)
`include "opcodes.txt"	
	
	// unit logic - generate signals
	always @(*) begin
		
		if(~rst) begin 
			{RegDst, MemReadEn, MemtoReg, MemWriteEn, RegWriteEn, ALUSrc, ALUOp, hlt} <= 0;
		end
		else begin
			{RegDst, MemReadEn, MemtoReg, MemWriteEn, RegWriteEn, ALUSrc, ALUOp, hlt} = 0;

			case(opcode)


				hlt_inst: begin
					hlt <= 1'b1;
				end
					
				RType : begin
					
					RegDst <= 1'b1; 
					RegWriteEn <= 1'b1; 
						
					case (funct) 
						
						jr : begin
						end


						add, addu : begin
							ALUOp <= 4'd0; 
						end
							
						sub, subu : begin
							ALUOp <= 4'd1; 
						end
							
						and_ : begin
							ALUOp <= 4'd2; 
						end
							
						or_ : begin 
							ALUOp <= 4'd3; 
						end

						xor_ : begin 
							ALUOp <= 4'd4; 
						end

						nor_ : begin 
							ALUOp <= 4'd5; 
						end

						slt : begin 
							ALUOp <= 4'd6; 
						end

						sgt : begin 
							ALUOp <= 4'd7; 
						end

						sll : begin 
							ALUSrc <= 1'b1;
							ALUOp <= 4'd8; 
						end

						srl : begin
							ALUSrc <= 1'b1;
							ALUOp <= 4'd9; 
						end

						jr : begin
							ALUOp <= 4'd0;
						end
						
					endcase
					
				end

				j : begin
				end

				jal : begin
					RegWriteEn <= 1'b1;
					RegDst <= 1'b1;
					ALUSrc <= 1'b1;
				end

				slti : begin
					RegWriteEn <= 1'b1;
					RegDst <= 1'b0;
					ALUSrc <= 1'b1;
					ALUOp <= 4'd6;
				end

					
				addi : begin
					RegWriteEn <= 1'b1; // correct signal - will write back to rt
					ALUSrc <= 1'b1; // correct signal - operand is the immediate	
				end

				andi : begin
					ALUOp <= 4'd2;
					RegWriteEn <= 1'b1; // correct signal - will write back to rt
					ALUSrc <= 1'b1; // correct signal - operand is the immediate	
				end

				ori : begin
					ALUOp <= 4'd3;
					RegWriteEn <= 1'b1; // correct signal - will write back to rt
					ALUSrc <= 1'b1; // correct signal - operand is the immediate	
				end
					
				xori : begin
					ALUOp <= 4'd4;
					RegWriteEn <= 1'b1; // correct signal - will write back to rt
					ALUSrc <= 1'b1; // correct signal - operand is the immediate	
				end

				lw : begin
					MemReadEn <= 1'b1; // Bug ID = 2: was 0, changed to 1 - will read from memory
					RegWriteEn <= 1'b1; // correct signal - will write back to rt
					ALUSrc <= 1'b1; // correct signal - operand is the immediate
					MemtoReg <= 1'b1; // Bug ID = 4: added signal - write back to register from data memory
				end
					
				sw : begin
					MemWriteEn <= 1'b1; // correct signal - will write to data memory
					ALUSrc <= 1'b1; // correct signal - operand is immediate			
				end
					
				beq, bne : begin
					ALUOp <= 4'd1; // correct signal - sub = 1
				end
				
				default: ;
			endcase
		end	
	end
	
	
endmodule