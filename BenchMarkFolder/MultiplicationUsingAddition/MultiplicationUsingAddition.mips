
.text

XORI $24, $0, 0x5  # num1 = 5 
XORI $25, $0, 0x3  # num2 = 3 
 
JAL Mul_Fun 
J Finish 
 
########### 
Mul_Fun :  
 ANDI $23, $0, 0  # mulOut = 0 (initilize) 
 ADDI $22, $25, -1 # i = num2-1 (initilize by value of num2-1) 
 
Mul_Loop :   
 ADD  $23, $23, $24 # mulOut += num1 
 ADDI $22, $22, -1 # i-- 
 BGEZ $22, Mul_Loop 
 JR $31 
########### 
  
Finish : NOP 