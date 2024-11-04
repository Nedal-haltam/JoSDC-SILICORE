
// TODO:
// -add all the instruction that is supported in the real time cas for the single cycle and then walkthrough every module and see
//  what should you modify in it to support the new instructions, and then go to the pipelined
// -and after that use all the tests (UTB, sort, ...) to test the SW and the HW

parameter _RType = 6'h0, _addi = 6'h8, _lw = 6'h23, _sw = 6'h2b, _beq = 6'h4; // correct opcodes
parameter _add_ = 6'h20, _sub_ = 6'h22, _and_ = 6'h24, _or_ = 6'h25, _slt_ = 6'h2a, hlt_inst = 6'b111111; // correct functions


  