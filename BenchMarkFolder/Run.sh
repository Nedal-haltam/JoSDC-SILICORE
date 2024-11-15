#!/bin/bash

# for a given bench mark their will be a folder with the name of the benchmark
# and inside that folder their will be a file named with the same name for simplicity and because simplicity favours regularity
RunBenchMark_SW()
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
    CAS_OUT_SC=$ProgFolder""$ProgName"_CAS_OUT_SC.txt"
    CAS_OUT_PL=$ProgFolder""$ProgName"_CAS_OUT_PL.txt"
    # define the program and its arguments
    CAS="../CycleAccurateSimulator/bin/Debug/net8.0/CAS.exe"
    
    CAS_ARGS="sim singlecycle $CAS_IN $CAS_OUT_SC"
    # run the CAS on the single cycle
    $CAS $CAS_ARGS

    CAS_ARGS="sim pipeline $CAS_IN $CAS_OUT_PL"
    # run the CAS on the PipeLined
    $CAS $CAS_ARGS
}


# TODO: compare the output of the single cycle with the pipline CPU's and then do the comparison with the HW design
RunBenchMark_SW "Program"

# TODO: run the benchmark on the hardware and then compare them
# RunBenchMark_HW 

read -p "Press Enter to exit"
# if [ $? -eq 0 ]; then
#     echo "Script executed successfully!"
# else
#     echo "An error occurred."
# fi
# read -p "Press Enter to close the window..."
