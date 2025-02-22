    .data 
Array: .word 0x10, 0xF, 0x5, 0x9, 0x20, 0x19, 0x4, 0x1E, 0x9, 0xB 
 
    .text 
main: 
    # Initialize registers 
    ORI  $2 , $0, 0x0       
    ADDI $20, $0, 0xA       
    XORI $31, $0, 0x1       
    ANDI $5 , $0, 0x0       
    LW   $10, 0x0($5)       
    LW   $15, 0x0($5)       
 
LOOP: 
    ADDI $2,  $2, 1         
    SGT  $25, $20, $2       
    BNE  $25, $31, END      
 
    # Choose one of these Insertion based on your memory 
    # For Word addressable        # For byte addressable 
    ADD  $5, $2, $0             # SLL  $5, $2, 2        
 
    LW   $16, 0x0($5)       
    SGT  $26, $16, $10      
    BEQ  $26, $0, MIN       
    OR   $10, $16, $0       
    J    LOOP 
 
MIN: 
    SLT  $27, $16, $15      
    BEQ  $27, $0, LOOP      
    ADD  $15, $16, $0       
    J    LOOP               
 
END: 
    NOP # (NOP equals to SLL $0, $0, 0) 