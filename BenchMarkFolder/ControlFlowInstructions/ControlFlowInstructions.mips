 .text  
main:  
  # Initialize registers with immediate values  
  ADDI $1, $0, -5         
  ADDI $2, $0, 5          
  ADDI $3, $0, 5      
  ADDI $4, $0, 23
   
L1:  
  #  Test BEQ       
  BEQ $2, $3, L2    
  NOP          # No operation / SLL $0, $0, 0        
  JAL L1              
L2:  
  # Test BNE   
  BNE $2, $3, L3   
L3:  
  NOP              
L4:  
  # Test BLTZ  
  BLTZ $1, L5      
  NOP              
  JAL L4             
L5:  
  #  Test BGEZ   
  BGEZ $2, L6      
  NOP             
  JAL L5             
L6:  
  #  Test JAL  
  JAL L7                
  NOP                 
  JAL L6             
L7:  
  #  Test JR   
  JR $4            
  NOP               
  JAL L7                
L8:  
  NOP             # end of test cases