
.text

main:
# the final Fibonacci value is in register $3
# the number of iteration is specified by the value
# of register $6

ADDI $4, $0, 0
ADDI $2, $0, 0
ADDI $3, $0, 1
# if we increased the number of iterations we will see clearly that the prediction works even better
# it will introduce a number of bubbles (NOPs) but these will be less over large number of iterations
ADDI $6, $0, 45
JAL FIB

J END
FIB:
ADD $5, $3, $0
ADD $3, $2, $3
ADD $2, $5, $0
ADDI $4, $4, 1
BEQ $4, $6, FINISH
J FIB
FINISH:
JR $31

END: