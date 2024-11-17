transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SSOOO-CPU/PL_CPU_FPGA/PL_CPU_FPGA {D:/GitHub Repos/JoSDC-SSOOO-CPU/PL_CPU_FPGA/PL_CPU_FPGA/MUX_4x1.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SSOOO-CPU/PL_CPU_FPGA/PL_CPU_FPGA {D:/GitHub Repos/JoSDC-SSOOO-CPU/PL_CPU_FPGA/PL_CPU_FPGA/MUX_8x1.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SSOOO-CPU/PL_CPU_FPGA/PL_CPU_FPGA {D:/GitHub Repos/JoSDC-SSOOO-CPU/PL_CPU_FPGA/PL_CPU_FPGA/ALU.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SSOOO-CPU/PL_CPU_FPGA/PL_CPU_FPGA {D:/GitHub Repos/JoSDC-SSOOO-CPU/PL_CPU_FPGA/PL_CPU_FPGA/REG_FILE.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SSOOO-CPU/PL_CPU_FPGA/PL_CPU_FPGA {D:/GitHub Repos/JoSDC-SSOOO-CPU/PL_CPU_FPGA/PL_CPU_FPGA/Branch_or_Jump_TargGen.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SSOOO-CPU/PL_CPU_FPGA/PL_CPU_FPGA {D:/GitHub Repos/JoSDC-SSOOO-CPU/PL_CPU_FPGA/PL_CPU_FPGA/EX_MEM_buffer.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SSOOO-CPU/PL_CPU_FPGA/PL_CPU_FPGA {D:/GitHub Repos/JoSDC-SSOOO-CPU/PL_CPU_FPGA/PL_CPU_FPGA/PC_register.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SSOOO-CPU/PL_CPU_FPGA/PL_CPU_FPGA {D:/GitHub Repos/JoSDC-SSOOO-CPU/PL_CPU_FPGA/PL_CPU_FPGA/IF_stage.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SSOOO-CPU/PL_CPU_FPGA/PL_CPU_FPGA {D:/GitHub Repos/JoSDC-SSOOO-CPU/PL_CPU_FPGA/PL_CPU_FPGA/MEM_stage.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SSOOO-CPU/PL_CPU_FPGA/PL_CPU_FPGA {D:/GitHub Repos/JoSDC-SSOOO-CPU/PL_CPU_FPGA/PL_CPU_FPGA/WB_stage.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SSOOO-CPU/PL_CPU_FPGA/PL_CPU_FPGA {D:/GitHub Repos/JoSDC-SSOOO-CPU/PL_CPU_FPGA/PL_CPU_FPGA/IM.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SSOOO-CPU/PL_CPU_FPGA/PL_CPU_FPGA {D:/GitHub Repos/JoSDC-SSOOO-CPU/PL_CPU_FPGA/PL_CPU_FPGA/DM.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SSOOO-CPU/PL_CPU_FPGA/PL_CPU_FPGA {D:/GitHub Repos/JoSDC-SSOOO-CPU/PL_CPU_FPGA/PL_CPU_FPGA/CPU5STAGE.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SSOOO-CPU/PL_CPU_FPGA/PL_CPU_FPGA {D:/GitHub Repos/JoSDC-SSOOO-CPU/PL_CPU_FPGA/PL_CPU_FPGA/opcodes.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SSOOO-CPU/PL_CPU_FPGA/PL_CPU_FPGA {D:/GitHub Repos/JoSDC-SSOOO-CPU/PL_CPU_FPGA/PL_CPU_FPGA/ALU_OPER.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SSOOO-CPU/PL_CPU_FPGA/PL_CPU_FPGA {D:/GitHub Repos/JoSDC-SSOOO-CPU/PL_CPU_FPGA/PL_CPU_FPGA/IF_ID_buffer.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SSOOO-CPU/PL_CPU_FPGA/PL_CPU_FPGA {D:/GitHub Repos/JoSDC-SSOOO-CPU/PL_CPU_FPGA/PL_CPU_FPGA/ID_EX_buffer.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SSOOO-CPU/PL_CPU_FPGA/PL_CPU_FPGA {D:/GitHub Repos/JoSDC-SSOOO-CPU/PL_CPU_FPGA/PL_CPU_FPGA/MEM_WB_buffer.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SSOOO-CPU/PL_CPU_FPGA/PL_CPU_FPGA {D:/GitHub Repos/JoSDC-SSOOO-CPU/PL_CPU_FPGA/PL_CPU_FPGA/control_unit.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SSOOO-CPU/PL_CPU_FPGA/PL_CPU_FPGA {D:/GitHub Repos/JoSDC-SSOOO-CPU/PL_CPU_FPGA/PL_CPU_FPGA/Immed_Gen_unit.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SSOOO-CPU/PL_CPU_FPGA/PL_CPU_FPGA {D:/GitHub Repos/JoSDC-SSOOO-CPU/PL_CPU_FPGA/PL_CPU_FPGA/ID_stage.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SSOOO-CPU/PL_CPU_FPGA/PL_CPU_FPGA {D:/GitHub Repos/JoSDC-SSOOO-CPU/PL_CPU_FPGA/PL_CPU_FPGA/EX_stage.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SSOOO-CPU/PL_CPU_FPGA/PL_CPU_FPGA {D:/GitHub Repos/JoSDC-SSOOO-CPU/PL_CPU_FPGA/PL_CPU_FPGA/exception_detect_unit.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SSOOO-CPU/PL_CPU_FPGA/PL_CPU_FPGA {D:/GitHub Repos/JoSDC-SSOOO-CPU/PL_CPU_FPGA/PL_CPU_FPGA/forwarda.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SSOOO-CPU/PL_CPU_FPGA/PL_CPU_FPGA {D:/GitHub Repos/JoSDC-SSOOO-CPU/PL_CPU_FPGA/PL_CPU_FPGA/forwardb.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SSOOO-CPU/PL_CPU_FPGA/PL_CPU_FPGA {D:/GitHub Repos/JoSDC-SSOOO-CPU/PL_CPU_FPGA/PL_CPU_FPGA/forwardc.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SSOOO-CPU/PL_CPU_FPGA/PL_CPU_FPGA {D:/GitHub Repos/JoSDC-SSOOO-CPU/PL_CPU_FPGA/PL_CPU_FPGA/branchresolver.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SSOOO-CPU/PL_CPU_FPGA/PL_CPU_FPGA {D:/GitHub Repos/JoSDC-SSOOO-CPU/PL_CPU_FPGA/PL_CPU_FPGA/stalldetectionunit.v}

vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SSOOO-CPU/PL_CPU_FPGA/PL_CPU_FPGA {D:/GitHub Repos/JoSDC-SSOOO-CPU/PL_CPU_FPGA/PL_CPU_FPGA/PL_CPU_mod.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  PC_CPU_mod.v

add wave *
view structure
view signals
run -all
