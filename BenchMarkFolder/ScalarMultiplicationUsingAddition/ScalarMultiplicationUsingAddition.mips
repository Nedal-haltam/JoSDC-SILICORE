
.data
 Arr: .word 0x5, 0x3, 0x2, 0x1, 0x2, 0x10, 0x30, 0x1, 0x1, 0x5  
  
.text
 
ADDI $17, $0, 10  # size = 10 (initilize) 
ANDI $18, $0, 0   # count = 0 (initilize) 
XORI $24, $0, 2   # load the constant C = 2  
 
Outer_Loop: 
 ADD $19, $18, $0 # index = count 
 # this line is for byte addressing memories only 
 # SLL $19, $19, 2 # index = index * 4  
 LW $25, Arr($19) # num1 = Arr[count] 
 JAL Mul_Fun  # call Mul_Fun (C, Arr[count]) 
 SW $23, Arr($19) # Arr[count] = mulOut 
  
 ADDI $18, $18, 1 # count++ 
 SUB  $20, $18, $17 # temp = count - size (check loop condition) 
 BLTZ $20, Outer_Loop 
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