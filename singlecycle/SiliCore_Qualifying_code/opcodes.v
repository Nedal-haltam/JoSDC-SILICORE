
// TODO:
// -add all the instruction that is supported in the real time cas for the single cycle and then walkthrough every module and see
//  what should you modify in it to support the new instructions, and then go to the pipelined
// -and after that use all the tests (UTB, sort, ...) to test the SW and the HW


parameter RType = 6'h0;
parameter nop = 6'd0, hlt_inst = 6'b111111;
parameter add = 6'h20, addu = 6'h21, sub = 6'h22, subu = 6'h23,  and_ = 6'h24, or_ = 6'h25, xor_ = 6'h26, nor_ = 6'h27, slt = 6'h2a,
          sgt = 6'h2b, sll = 6'h00, srl = 6'h02, jr = 6'h08;
parameter addi = 6'h08, andi = 6'h0C, ori = 6'h0D, xori = 6'h0E, slti = 6'h2a, lw = 6'h23, sw = 6'h2B, beq = 6'h04, bne = 6'h05;
parameter j = 6'h02, jal = 6'h03;


  