.text 
main: 
# Initialize registers 
ORI $2, $0, 0x1          
ORI $3, $0, 0x0          
ORI $4, $0, 0xA          
SUM_LOOP: 
ADD  $3, $3, $2          
ADDI $2, $2, 1           
SLT  $5, $4, $2 
BEQ  $5, $0, SUM_LOOP    
SW   $3, 0x0($0)      

END: 
NOP                     

# End program 

