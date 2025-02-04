# initializing the memory with reversed order array and with duplicates and negatives



.text

main:
# range : -10 : 10 (duplicates)
ADDI $1, $0, 10

# number of elements = 42 (0 -> 41)
# $11 = 41 = 4 * $1 + 1
SLL $11, $1, 2
ADDI $11, $11, 1

# index
ADDI $2, $0, 0
ADD $3, $0, $1

init:
sub $8, $2, $11
BGEZ $8, EXITINIT
SW $3, 0x0($2)
SW $3, 0x1($2)
ADDI $2, $2, 2
ADDI $3, $3, -1
BEQ $0, $0, init
EXITINIT:

ADDI $3, $0, 0
L1:
BEQ $3, $11, EXITL1

# j
ADDI $4, $0, 0
ADD $7, $0, $11
SUB $7, $7, $3
L2:
BEQ $4, $7, EXITL2

LW $5, 0x0($4)
LW $6, 0x1($4)
sub $8, $5, $6
BLTZ $8, else
SW $5, 0x1($4)
SW $6, 0x0($4)
else:

ADDI $4, $4, 1
BEQ $0, $0, L2
EXITL2:

ADDI $3, $3, 1
BEQ $0, $0, L1
EXITL1: