transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SILICORE/singlecycle/SiliCore_Qualifying_code {D:/GitHub Repos/JoSDC-SILICORE/singlecycle/SiliCore_Qualifying_code/registerFile.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SILICORE/singlecycle/SiliCore_Qualifying_code {D:/GitHub Repos/JoSDC-SILICORE/singlecycle/SiliCore_Qualifying_code/ALU.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SILICORE/singlecycle/SiliCore_Qualifying_code {D:/GitHub Repos/JoSDC-SILICORE/singlecycle/SiliCore_Qualifying_code/programCounter.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SILICORE/singlecycle/SiliCore_Qualifying_code {D:/GitHub Repos/JoSDC-SILICORE/singlecycle/SiliCore_Qualifying_code/mux2x1.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SILICORE/singlecycle/SiliCore_Qualifying_code {D:/GitHub Repos/JoSDC-SILICORE/singlecycle/SiliCore_Qualifying_code/DataMemory_IP.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SILICORE/singlecycle/SiliCore_Qualifying_code {D:/GitHub Repos/JoSDC-SILICORE/singlecycle/SiliCore_Qualifying_code/SingleCycle_sim.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SILICORE/singlecycle/SiliCore_Qualifying_code {D:/GitHub Repos/JoSDC-SILICORE/singlecycle/SiliCore_Qualifying_code/dm.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SILICORE/singlecycle/SiliCore_Qualifying_code {D:/GitHub Repos/JoSDC-SILICORE/singlecycle/SiliCore_Qualifying_code/controlUnit.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SILICORE/singlecycle/SiliCore_Qualifying_code {D:/GitHub Repos/JoSDC-SILICORE/singlecycle/SiliCore_Qualifying_code/sc_cpu.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SILICORE/singlecycle/SiliCore_Qualifying_code {D:/GitHub Repos/JoSDC-SILICORE/singlecycle/SiliCore_Qualifying_code/branchcontroller.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SILICORE/singlecycle/SiliCore_Qualifying_code {D:/GitHub Repos/JoSDC-SILICORE/singlecycle/SiliCore_Qualifying_code/im.v}

vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SILICORE/singlecycle/SiliCore_Qualifying_code {D:/GitHub Repos/JoSDC-SILICORE/singlecycle/SiliCore_Qualifying_code/SingleCycle_sim.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L fiftyfivenm_ver -L rtl_work -L work -voptargs="+acc"  SingleCycle_sim

add wave *
view structure
view signals
run -all
