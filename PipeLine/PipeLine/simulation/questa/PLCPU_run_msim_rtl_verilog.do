transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SILICORE/PipeLine/PipeLine {D:/GitHub Repos/JoSDC-SILICORE/PipeLine/PipeLine/MUX_4x1.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SILICORE/PipeLine/PipeLine {D:/GitHub Repos/JoSDC-SILICORE/PipeLine/PipeLine/ALU.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SILICORE/PipeLine/PipeLine {D:/GitHub Repos/JoSDC-SILICORE/PipeLine/PipeLine/REG_FILE.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SILICORE/PipeLine/PipeLine {D:/GitHub Repos/JoSDC-SILICORE/PipeLine/PipeLine/EX_MEM_buffer.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SILICORE/PipeLine/PipeLine {D:/GitHub Repos/JoSDC-SILICORE/PipeLine/PipeLine/PC_register.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SILICORE/PipeLine/PipeLine {D:/GitHub Repos/JoSDC-SILICORE/PipeLine/PipeLine/IF_stage.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SILICORE/PipeLine/PipeLine {D:/GitHub Repos/JoSDC-SILICORE/PipeLine/PipeLine/MEM_stage.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SILICORE/PipeLine/PipeLine {D:/GitHub Repos/JoSDC-SILICORE/PipeLine/PipeLine/WB_stage.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SILICORE/PipeLine/PipeLine {D:/GitHub Repos/JoSDC-SILICORE/PipeLine/PipeLine/IM.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SILICORE/PipeLine/PipeLine {D:/GitHub Repos/JoSDC-SILICORE/PipeLine/PipeLine/DM.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SILICORE/PipeLine/PipeLine {D:/GitHub Repos/JoSDC-SILICORE/PipeLine/PipeLine/CompareEqual.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SILICORE/PipeLine/PipeLine {D:/GitHub Repos/JoSDC-SILICORE/PipeLine/PipeLine/InstMem.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SILICORE/PipeLine/PipeLine {D:/GitHub Repos/JoSDC-SILICORE/PipeLine/PipeLine/forwarda.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SILICORE/PipeLine/PipeLine {D:/GitHub Repos/JoSDC-SILICORE/PipeLine/PipeLine/forwardb.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SILICORE/PipeLine/PipeLine {D:/GitHub Repos/JoSDC-SILICORE/PipeLine/PipeLine/forwardc.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SILICORE/PipeLine/PipeLine {D:/GitHub Repos/JoSDC-SILICORE/PipeLine/PipeLine/pc_src_mux.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SILICORE/PipeLine/PipeLine {D:/GitHub Repos/JoSDC-SILICORE/PipeLine/PipeLine/forwarding_stage.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SILICORE/PipeLine/PipeLine {D:/GitHub Repos/JoSDC-SILICORE/PipeLine/PipeLine/branchdecision.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SILICORE/PipeLine/PipeLine {D:/GitHub Repos/JoSDC-SILICORE/PipeLine/PipeLine/ALU_OPER.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SILICORE/PipeLine/PipeLine {D:/GitHub Repos/JoSDC-SILICORE/PipeLine/PipeLine/IF_ID_buffer.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SILICORE/PipeLine/PipeLine {D:/GitHub Repos/JoSDC-SILICORE/PipeLine/PipeLine/ID_EX_buffer.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SILICORE/PipeLine/PipeLine {D:/GitHub Repos/JoSDC-SILICORE/PipeLine/PipeLine/MEM_WB_buffer.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SILICORE/PipeLine/PipeLine {D:/GitHub Repos/JoSDC-SILICORE/PipeLine/PipeLine/control_unit.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SILICORE/PipeLine/PipeLine {D:/GitHub Repos/JoSDC-SILICORE/PipeLine/PipeLine/Immed_Gen_unit.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SILICORE/PipeLine/PipeLine {D:/GitHub Repos/JoSDC-SILICORE/PipeLine/PipeLine/ID_stage.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SILICORE/PipeLine/PipeLine {D:/GitHub Repos/JoSDC-SILICORE/PipeLine/PipeLine/EX_stage.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SILICORE/PipeLine/PipeLine {D:/GitHub Repos/JoSDC-SILICORE/PipeLine/PipeLine/DataMemory_IP.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SILICORE/PipeLine/PipeLine {D:/GitHub Repos/JoSDC-SILICORE/PipeLine/PipeLine/PL_CPU.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SILICORE/PipeLine/PipeLine {D:/GitHub Repos/JoSDC-SILICORE/PipeLine/PipeLine/branchresolver.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SILICORE/PipeLine/PipeLine {D:/GitHub Repos/JoSDC-SILICORE/PipeLine/PipeLine/branchpredictor.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SILICORE/PipeLine/PipeLine {D:/GitHub Repos/JoSDC-SILICORE/PipeLine/PipeLine/stalldetectionunit.v}

vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SILICORE/PipeLine/PipeLine {D:/GitHub Repos/JoSDC-SILICORE/PipeLine/PipeLine/PipeLine_sim.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L fiftyfivenm_ver -L rtl_work -L work -voptargs="+acc"  PipeLine_sim

add wave *
view structure
view signals
run -all
