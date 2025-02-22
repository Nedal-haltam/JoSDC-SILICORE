
    .data 
value: .word 0x5                    # sample data for loading 
 
    .text 
main: 
    # Immediate instructions to initialize registers 
    ADDI $1, $0, 0xA                 
    ORI  $2, $0, 0xB                 
    XORI $3, $0, 0xC                 
 
    # Basic ALU operations 
    ADD  $4, $1, $2                  
    SUB  $5, $4, $3                  
    AND  $6, $1, $3                  
    OR   $7, $2, $3                  
    NOR  $8, $2, $3                  
    XOR  $9, $1, $2                  
 
    # Comparison operations 
    SLT  $10, $1, $2                 
    SGT  $11, $3, $1                 
 
    # Shift operations 
    SLL  $12, $1, 2                  
    SRL  $13, $2, 1                  
 
    # Load and store word instructions 
    LW   $14, 0x0($0) 
    SW   $4, 0x0($0)  