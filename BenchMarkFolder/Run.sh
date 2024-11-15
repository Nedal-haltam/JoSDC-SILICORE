#!/bin/bash

# for a given bench mark their will be a folder with the name of the benchmark
# and inside that folder their will be a file named with the same name for simplicity and because simplicity favours regularity
RunBenchMark()
{
    ProgName=$1
    ProgFolder="./"$ProgName"/"
    ProgCode="./"$ProgName"/"$ProgName".txt"

    # define the I/O
    ASSEMBLER_IN=$ProgCode
    ASSEMBLER_OUT=$ProgFolder""$ProgName"_MC.txt"
    # define the program and its arguments
    ASSEMBLER="../MIPSAssembler/bin/Debug/Assembler.exe"
    ASSEMBLER_ARGS="gen $ASSEMBLER_IN $ASSEMBLER_OUT"
    # run the the assembler
    $ASSEMBLER $ASSEMBLER_ARGS

    # define the I/O
    CAS_IN=$ASSEMBLER_OUT
    CAS_OUT=$ProgFolder""$ProgName"_CAS_OUT.txt"
    # define the program and its arguments
    CAS="../CycleAccurateSimulator/bin/Debug/net8.0/CAS.exe"
    CAS_ARGS="sim singlecycle $CAS_IN $CAS_OUT"
    # run the CAS
    $CAS $CAS_ARGS
}



RunBenchMark "Program"

read -p "Press Enter to exit"
# if [ $? -eq 0 ]; then
#     echo "Script executed successfully!"
# else
#     echo "An error occurred."
# fi
# read -p "Press Enter to close the window..."
