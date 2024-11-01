transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+D:/JoSDC\ Comp\ Folder/Qualifying\ phase\ (0)/Qualifying\ Phase/SiliCore_Qualifying_code/SiliCore_Qualifying_code/SiliCore_Qualifying_code {D:/JoSDC Comp Folder/Qualifying phase (0)/Qualifying Phase/SiliCore_Qualifying_code/SiliCore_Qualifying_code/SiliCore_Qualifying_code/testbench.v}
vlog -vlog01compat -work work +incdir+D:/JoSDC\ Comp\ Folder/Qualifying\ phase\ (0)/Qualifying\ Phase/SiliCore_Qualifying_code/SiliCore_Qualifying_code/SiliCore_Qualifying_code {D:/JoSDC Comp Folder/Qualifying phase (0)/Qualifying Phase/SiliCore_Qualifying_code/SiliCore_Qualifying_code/SiliCore_Qualifying_code/processor.v}
vlog -vlog01compat -work work +incdir+D:/JoSDC\ Comp\ Folder/Qualifying\ phase\ (0)/Qualifying\ Phase/SiliCore_Qualifying_code/SiliCore_Qualifying_code/SiliCore_Qualifying_code {D:/JoSDC Comp Folder/Qualifying phase (0)/Qualifying Phase/SiliCore_Qualifying_code/SiliCore_Qualifying_code/SiliCore_Qualifying_code/controlUnit.v}
vlog -vlog01compat -work work +incdir+D:/JoSDC\ Comp\ Folder/Qualifying\ phase\ (0)/Qualifying\ Phase/SiliCore_Qualifying_code/SiliCore_Qualifying_code/SiliCore_Qualifying_code {D:/JoSDC Comp Folder/Qualifying phase (0)/Qualifying Phase/SiliCore_Qualifying_code/SiliCore_Qualifying_code/SiliCore_Qualifying_code/ALU.v}
vlog -vlog01compat -work work +incdir+D:/JoSDC\ Comp\ Folder/Qualifying\ phase\ (0)/Qualifying\ Phase/SiliCore_Qualifying_code/SiliCore_Qualifying_code/SiliCore_Qualifying_code {D:/JoSDC Comp Folder/Qualifying phase (0)/Qualifying Phase/SiliCore_Qualifying_code/SiliCore_Qualifying_code/SiliCore_Qualifying_code/signextender.v}
vlog -vlog01compat -work work +incdir+D:/JoSDC\ Comp\ Folder/Qualifying\ phase\ (0)/Qualifying\ Phase/SiliCore_Qualifying_code/SiliCore_Qualifying_code/SiliCore_Qualifying_code {D:/JoSDC Comp Folder/Qualifying phase (0)/Qualifying Phase/SiliCore_Qualifying_code/SiliCore_Qualifying_code/SiliCore_Qualifying_code/programCounter.v}
vlog -vlog01compat -work work +incdir+D:/JoSDC\ Comp\ Folder/Qualifying\ phase\ (0)/Qualifying\ Phase/SiliCore_Qualifying_code/SiliCore_Qualifying_code/SiliCore_Qualifying_code {D:/JoSDC Comp Folder/Qualifying phase (0)/Qualifying Phase/SiliCore_Qualifying_code/SiliCore_Qualifying_code/SiliCore_Qualifying_code/mux2x1.v}
vlog -vlog01compat -work work +incdir+D:/JoSDC\ Comp\ Folder/Qualifying\ phase\ (0)/Qualifying\ Phase/SiliCore_Qualifying_code/SiliCore_Qualifying_code/SiliCore_Qualifying_code {D:/JoSDC Comp Folder/Qualifying phase (0)/Qualifying Phase/SiliCore_Qualifying_code/SiliCore_Qualifying_code/SiliCore_Qualifying_code/adder.v}
vlog -vlog01compat -work work +incdir+D:/JoSDC\ Comp\ Folder/Qualifying\ phase\ (0)/Qualifying\ Phase/SiliCore_Qualifying_code/SiliCore_Qualifying_code/SiliCore_Qualifying_code {D:/JoSDC Comp Folder/Qualifying phase (0)/Qualifying Phase/SiliCore_Qualifying_code/SiliCore_Qualifying_code/SiliCore_Qualifying_code/ANDGate.v}
vlog -vlog01compat -work work +incdir+D:/JoSDC\ Comp\ Folder/Qualifying\ phase\ (0)/Qualifying\ Phase/SiliCore_Qualifying_code/SiliCore_Qualifying_code/SiliCore_Qualifying_code {D:/JoSDC Comp Folder/Qualifying phase (0)/Qualifying Phase/SiliCore_Qualifying_code/SiliCore_Qualifying_code/SiliCore_Qualifying_code/instructionMemory.v}
vlog -vlog01compat -work work +incdir+D:/JoSDC\ Comp\ Folder/Qualifying\ phase\ (0)/Qualifying\ Phase/SiliCore_Qualifying_code/SiliCore_Qualifying_code/SiliCore_Qualifying_code {D:/JoSDC Comp Folder/Qualifying phase (0)/Qualifying Phase/SiliCore_Qualifying_code/SiliCore_Qualifying_code/SiliCore_Qualifying_code/dataMemory.v}
vlog -vlog01compat -work work +incdir+D:/JoSDC\ Comp\ Folder/Qualifying\ phase\ (0)/Qualifying\ Phase/SiliCore_Qualifying_code/SiliCore_Qualifying_code/SiliCore_Qualifying_code {D:/JoSDC Comp Folder/Qualifying phase (0)/Qualifying Phase/SiliCore_Qualifying_code/SiliCore_Qualifying_code/SiliCore_Qualifying_code/registerFile.v}

vlog -vlog01compat -work work +incdir+D:/JoSDC\ Comp\ Folder/Qualifying\ phase\ (0)/Qualifying\ Phase/SiliCore_Qualifying_code/SiliCore_Qualifying_code/SiliCore_Qualifying_code {D:/JoSDC Comp Folder/Qualifying phase (0)/Qualifying Phase/SiliCore_Qualifying_code/SiliCore_Qualifying_code/SiliCore_Qualifying_code/testbench.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  testbench.v

add wave *
view structure
view signals
run -all
