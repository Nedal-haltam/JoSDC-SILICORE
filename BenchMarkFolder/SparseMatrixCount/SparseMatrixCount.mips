.data 
matrix:   .word 1, 0, 0, 0, 3, 5, 0, 0, 0, 0, 22, 0   # 4x3 matrix (row-major order) 
 
.text 
        # Initializations 
        ADDI $8  , $0, 0              # Zero counter 
        ADDI $16 , $0, 4              # Rows 
        ADDI $17 , $0, 3              # Columns 
        ADDI $20 , $0, 0              # Base address of the matrix 
        ADDI $9  , $0, 0              # rowIndex 
 
outerLoop: 
        SLT  $11, $9, $16             # Check if rowIndex < Rows 
        BEQ  $11, $0, exitOuter 
        
        # Precompute row base offset: rowIndex * Cols 
        ADDI $14, $0, 0               # Reset base offset accumulator 
        ADDI $15, $0, 0               # Initialize loop counter 
 
Multiply: 
        # Multiply rowIndex * Cols by repeated addition 
        SLT  $11, $15, $9 
        BEQ  $11, $0, endMultiply 
        ADD  $14, $14, $17           # Accumulate: base offset += Cols 
        ADDI $15, $15, 1             # Increment loop counter 
        JAL  Multiply 
 
endMultiply: 
        # Choose one of these Insertion based on your memory  
        # For Word addressable             # For byte addressable  
        ADD $14, $14, $0                 #     SLL  $14, $14, 2 
        ADD  $14, $14, $20           # Base address for current row 
        ADDI $10, $0, 0              # colIndex 
 
innerLoop: 
        SLT  $11, $10, $17           # Check if colIndex < Cols 
        BEQ  $11, $0, exitInner 
        # Choose one of these Insertion based on your memory  
        # For Word addressable             # For byte addressable  
        ADD $15, $10, $0                 # SLL  $15, $10, 2      
  
        ADD  $24, $14, $15           # Base row address + column offset 
        LW   $24, matrix($24)             # Load element: matrix[rowIndex][colIndex]          
        BNE  $24, $0, notZero        # Check if element != 0 
        ADDI $8, $8, 1               # Increment zero counter if element == 0 
 
notZero: 
        ADDI $10, $10, 1             # Increment colIndex 
        JAL  innerLoop 
 
exitInner:   
        ADDI $9, $9, 1               # Increment rowIndex 
        JAL  outerLoop 
 
exitOuter: 
        NOP 