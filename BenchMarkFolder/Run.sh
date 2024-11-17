#!/bin/bash

# for a given bench mark their will be a folder with the name of the benchmark
# and inside that folder their will be a file named with the same name for simplicity and because simplicity favours regularity

ASSEMBLER_EXT="MC.txt"
CAS_EXT_SC="CAS_SC_OUT.txt"
CAS_EXT_PL="CAS_PL_OUT.txt"


Run_BenchMark_SW()
{
    ProgName=$1
    ProgFolder="./$ProgName/"
    ProgCode="./$ProgName/$ProgName.txt"

    # define the I/O
    ASSEMBLER_IN=$ProgCode
    ASSEMBLER_OUT_TO_CAS=$ProgFolder""$ASSEMBLER_EXT
    ASSEMBLER_OUT_TO_HW=$ProgFolder"IM_INIT.v"
    # define the program and its arguments
    ASSEMBLER="../MIPSAssembler/bin/Debug/Assembler.exe"
    ASSEMBLER_ARGS="gen $ASSEMBLER_IN $ASSEMBLER_OUT_TO_CAS $ASSEMBLER_OUT_TO_HW"
    # run the the assembler
    printf "[INFO]: Assembling "$ProgName"...\n"
    $ASSEMBLER $ASSEMBLER_ARGS

    printf "[INFO]: "$ProgName" Assembled Successfully\n"

    # define the I/O
    CAS_IN=$ASSEMBLER_OUT_TO_CAS
    CAS_SC_OUT=$ProgFolder""$CAS_EXT_SC
    CAS_PL_OUT=$ProgFolder""$CAS_EXT_PL
    # define the program and its arguments
    CAS="../CycleAccurateSimulator/bin/Debug/net8.0/CAS.exe"
    
    CAS_ARGS="sim singlecycle $CAS_IN $CAS_SC_OUT"
    # run the CAS on the single cycle
    printf "[INFO]: Simulating "$ProgName" on the Single Cycle\n"
    $CAS $CAS_ARGS

    printf "[INFO]: "$ProgName" simulated successfully on the Single Cycle\n"

    CAS_ARGS="sim pipeline $CAS_IN $CAS_PL_OUT"
    # run the CAS on the PipeLine
    printf "[INFO]: Simulating "$ProgName" on the PipeLine\n"
    $CAS $CAS_ARGS

    printf "[INFO]: "$ProgName" simulated successfully on the PipeLine\n"


    
    STATS=$ProgFolder"stats.txt"
    printf "Software Stats: \n" > $STATS

    printf "\tSingleCycle: \n" >> $STATS
    printf "\t\t" >> $STATS
    sed -n '$p'  "$CAS_SC_OUT" >> $STATS
    printf "\tPipLined: \n" >> $STATS
    printf "\t\t" >> $STATS
    sed -n '$p'  "$CAS_PL_OUT" >> $STATS

    sed -i '$d' "$CAS_SC_OUT"
    sed -i '$d' "$CAS_PL_OUT"

    printf "[INFO]: Comparing Software Outputs\n"

    if diff "$CAS_SC_OUT" "$CAS_PL_OUT" > /dev/null; then
        printf "[INFO]: Files are identical.\n"
    else
        printf "[INFO]: Files are different. Detailed differences:\n"
        diff -a --color=always "$CAS_SC_OUT" "$CAS_PL_OUT"
    fi
}

RunBenchMark_HW()
{
    ProgName=$1
    ProgFolder="./$ProgName/"
    printf "[INFO]: simulating on single cycle hardware\n"
    BASE_PATH="../singlecycle/SiliCore_Qualifying_code/"
    VERILOG_EXT_SC="VERILOG_SC.vvp"
    VERILOG_EXT_SC_OUT="VERILOG_SC_OUT.txt"
    VERILOG_SC=$ProgFolder""$VERILOG_EXT_SC
    VERILOG_SC_OUT=$ProgFolder""$VERILOG_EXT_SC_OUT
    iverilog -I$BASE_PATH -I$ProgFolder -o $VERILOG_SC -D VCD_OUT=\"$ProgFolder"SingleCycle_WaveForm.vcd"\" $BASE_PATH"SingleCycle_sim.v"
    vvp $VERILOG_SC > $VERILOG_SC_OUT

    printf "[INFO]: simulating on pipeline hardware\n"
    BASE_PATH="../PL_CPU_FPGA/PL_CPU_FPGA/"
    VERILOG_EXT_PL="VERILOG_PL.vvp"
    VERILOG_EXT_PL_OUT="VERILOG_PL_OUT.txt"
    VERILOG_PL=$ProgFolder""$VERILOG_EXT_PL
    VERILOG_PL_OUT=$ProgFolder""$VERILOG_EXT_PL_OUT
    iverilog -I $BASE_PATH -I$ProgFolder -o $VERILOG_PL -D VCD_OUT=\"$ProgFolder"PipeLine_WaveForm.vcd"\" $BASE_PATH"PL_CPU_sim.v"
    vvp $VERILOG_PL > $VERILOG_PL_OUT




    sed -i '1d' "$VERILOG_SC_OUT"
    sed -i '1d' "$VERILOG_PL_OUT"
    sed -i '$d' "$VERILOG_SC_OUT"
    sed -i '$d' "$VERILOG_PL_OUT"


    STATS=$ProgFolder"stats.txt"
    printf "\n\nHardWare Stats: \n" >> $STATS

    printf "\tSingleCycle: \n" >> $STATS
    printf "\t\t" >> $STATS
    sed -n '$p' "$VERILOG_SC_OUT" >> $STATS
    printf "\tPipLined: \n" >> $STATS
    printf "\t\t" >> $STATS
    sed -n '$p'  "$VERILOG_PL_OUT" >> $STATS
    
    sed -i '$d' "$VERILOG_SC_OUT"
    sed -i '$d' "$VERILOG_PL_OUT"

    printf "[INFO]: Comparing HardWare Outputs\n"

    if diff "$VERILOG_SC_OUT" "$VERILOG_PL_OUT" > /dev/null; then
        printf "[INFO]: Files are identical.\n"
    else
        printf "[INFO]: Files are different. Detailed differences:\n"
        diff -a --color=always "$VERILOG_SC_OUT" "$VERILOG_PL_OUT"
    fi
}





Run_BenchMark_SW "code"
RunBenchMark_HW "code"
# TODO: compare HW / SW

read -p "Press Enter to exit"
# if [ $? -eq 0 ]; then
#     printf "Script executed successfully!\n"
# else
#     printf "An error occurred."
# fi
