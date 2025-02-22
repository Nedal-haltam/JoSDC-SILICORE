.data
Arr: .word 0x5, 0x7, 0x2, 0xF, 0xA, 0x10, 0x30, 0x1, 0xFF, 0x55


.text

main:
ADDI $20, $0, 10
ADDI $19, $0, 2
ADDI  $22, $0, -1



FOR_LOOP:

SUB $31, $19, $20
BGEZ $31, EXIT
LW   $8, 0($19)
ADDI $2, $19, -1


WHILE_LOOP:


SGT  $3, $2, $22
BEQ  $3, $0, EXIT_WHILE

LW   $5, 0($2)
SGT  $4, $5, $8
AND  $7, $3, $4
BEQ  $7, $0, EXIT_WHILE

ADDI $6, $2, 1
SW   $5, 0($6)
ADDI $2, $2, -1
J    WHILE_LOOP

EXIT_WHILE:

ADDI $2, $2, 1
SW   $8, 0($2)
ADDI $19, $19, 1

J    FOR_LOOP

EXIT: