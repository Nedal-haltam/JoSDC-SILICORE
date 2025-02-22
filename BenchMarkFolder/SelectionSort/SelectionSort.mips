.data 
  Arr: .word 0x5, 0x7, 0x2, 0xF, 0xA, 0x10, 0x30, 0x1, 0xFF, 0x55, 0x0, 0x6, 0xAB, 0xAD, 0x99, 0x33, 0x1, 0x16, 0x22, 0x79  
  
 .text
  ADDI $13, $0, 20 
  ADD  $11, $0, $0 
    
LOOP1:  XOR $21, $11, $0 
  # this line is commented, use it for byte addressing memory 
  # SLL $21, $11, 2 
  ADD  $12, $0, $0 
   
LOOP2:  XOR $22, $12, $0 
  # this line is commented, use it for byte addressing memory 
  # SLL $22, $12, 2 
  LW $8, 0x0($21) 
  LW $9, 0x0($22) 
   
IF:  SLT $10, $8, $9    
  BEQ $10, $0, ENDIF 
  ADD $3, $8, $0 
  ADD $8, $9, $0 
  ADD $9, $3, $0 
  SW $8, 0x0($21) 
  SW $9, 0x0($22) 
   
ENDIF:  ADDI $12, $12, 1 
  SLT $10, $12, $13    
  BNE $10, $0, LOOP2 
  ADDI $11, $11, 1 
  SLT $10, $11, $13  
  BNE $10, $0, LOOP1 
