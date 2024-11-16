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
    echo "[INFO]: Assembling "$ProgName"..."
    $ASSEMBLER $ASSEMBLER_ARGS

    echo "[INFO]: "$ProgName" Assembled Successfully"

    # define the I/O
    CAS_IN=$ASSEMBLER_OUT_TO_CAS
    CAS_SC_OUT=$ProgFolder""$CAS_EXT_SC
    CAS_PL_OUT=$ProgFolder""$CAS_EXT_PL
    # define the program and its arguments
    CAS="../CycleAccurateSimulator/bin/Debug/net8.0/CAS.exe"
    
    CAS_ARGS="sim singlecycle $CAS_IN $CAS_SC_OUT"
    # run the CAS on the single cycle
    echo "[INFO]: Simulating "$ProgName" on the Single Cycle"
    $CAS $CAS_ARGS

    echo "[INFO]: "$ProgName" simulated successfully on the Single Cycle"

    CAS_ARGS="sim pipeline $CAS_IN $CAS_PL_OUT"
    # run the CAS on the PipeLine
    echo "[INFO]: Simulating "$ProgName" on the PipeLine"
    $CAS $CAS_ARGS

    echo "[INFO]: "$ProgName" simulated successfully on the PipeLine"


    echo "[INFO]: Comparing Software Outputs"
    

    if diff "$CAS_SC_OUT" "$CAS_PL_OUT" > /dev/null; then
        echo "[INFO]: Files are identical."
    else
        echo "Files are different. Detailed differences:"
        diff -a --color=always "$CAS_SC_OUT" "$CAS_PL_OUT" # Unified diff format
    fi
}

RunBenchMark_HW()
{
    ProgName=$1
    ProgFolder="./$ProgName/"

    BASE_PATH="../singlecycle/SiliCore_Qualifying_code/"
    VERILOG_EXT_SC="VERILOG_SC.vvp"
    VERILOG_EXT_SC_OUT="VERILOG_SC_OUT.txt"
    VERILOG_SC=$ProgFolder""$VERILOG_EXT_SC
    VERILOG_SC_OUT=$ProgFolder""$VERILOG_EXT_SC_OUT
    iverilog -I$BASE_PATH -I$ProgFolder -o $VERILOG_SC -D VCD_OUT=\"$ProgFolder"SingleCycle_WaveForm.vcd"\" $BASE_PATH"SingleCycle_sim.v"
    vvp $VERILOG_SC > $VERILOG_SC_OUT

    BASE_PATH="../PL_CPU_FPGA/PL_CPU_FPGA/"
    VERILOG_EXT_PL="VERILOG_PL.vvp"
    VERILOG_EXT_PL_OUT="VERILOG_PL_OUT.txt"
    VERILOG_PL=$ProgFolder""$VERILOG_EXT_PL
    VERILOG_PL_OUT=$ProgFolder""$VERILOG_EXT_PL_OUT
    iverilog -I $BASE_PATH -I$ProgFolder -o $VERILOG_PL -D VCD_OUT=\"$ProgFolder"PipeLine_WaveForm.vcd"\" $BASE_PATH"PL_CPU_sim.v"
    vvp $VERILOG_PL > $VERILOG_PL_OUT
}





Run_BenchMark_SW "Program"
# # TODO: compare SC with PL (hardware wise)
RunBenchMark_HW "Program"
# TODO: compare HW / SW

read -p "Press Enter to exit"
# if [ $? -eq 0 ]; then
#     echo "Script executed successfully!"
# else
#     echo "An error occurred."
# fi
# read -p "Press Enter to close the window..."
