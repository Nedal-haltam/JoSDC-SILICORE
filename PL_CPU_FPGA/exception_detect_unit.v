

module exception_detect_unit(ID_PC, ID_opcode, excep_flag, id_flush, EX_FLUSH, MEM_FLUSH, clk, rst);
	
input clk, rst;
input [31:0] ID_PC;
input [6:0] ID_opcode;
//  output reg excep_flag, id_flush, EX_FLUSH, MEM_FLUSH;
output reg excep_flag, id_flush, EX_FLUSH, MEM_FLUSH;

initial { excep_flag, id_flush, EX_FLUSH, MEM_FLUSH } <= 0;

parameter numofinst = 24;
parameter [0 : 7 * numofinst - 1] opcodes  = {7'h20, 7'h22, 7'h21, 7'h23, 7'h48, 7'h24, 7'h4c, 7'h25, 7'h4d, 7'h26, 
		    7'h4e, 7'h27, 7'h00, 7'h02, 7'h63, 7'h6b, 7'h44, 7'h45, 7'h50, 7'h51, 
			7'h42, 7'h43, 7'h08, 7'h2a };

parameter add = 7'h20, sub = 7'h22, addu = 7'h21, subu = 7'h23, addi = 7'h48, and_ = 7'h24, andi = 7'h4c, or_ = 7'h25, ori = 7'h4d, xor_ = 7'h26, 
		    xori = 7'h4e, nor_ = 7'h27, sll = 7'h00, srl = 7'h02, lw = 7'h63, sw = 7'h6b, beq = 7'h44, bne = 7'h45, blt = 7'h50, bge = 7'h51, 
			 j = 7'h42, jal = 7'h43, jr = 7'h08, slt = 7'h2a, hlt = 7'b1111111;


  always@(negedge clk) begin
    // if invalid or unsupported opcode then there is an exception
	if (rst == 1'b1)
		{ excep_flag, id_flush, EX_FLUSH, MEM_FLUSH } <= 0;
	else begin
		case (ID_opcode)
			add, sub, addu, subu, addi, and_, andi, or_, ori, xor_, xori, nor_, sll, srl, lw, sw, beq, bne, blt, bge, j, jal, jr, slt, hlt: 
			begin
			{ excep_flag, id_flush, EX_FLUSH, MEM_FLUSH } <= 0;
			end		
			default:
			begin
			excep_flag <= 1'b1;
			id_flush   <= 1'b1;
			end		 
		endcase
	end

			

  end
	
endmodule