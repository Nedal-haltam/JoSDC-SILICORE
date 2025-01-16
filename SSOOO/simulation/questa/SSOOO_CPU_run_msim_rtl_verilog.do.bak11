transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SILICORE/SSOOO {D:/GitHub Repos/JoSDC-SILICORE/SSOOO/SSOOO_Sim.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SILICORE/SSOOO {D:/GitHub Repos/JoSDC-SILICORE/SSOOO/DataMemory_IP.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SILICORE/SSOOO {D:/GitHub Repos/JoSDC-SILICORE/SSOOO/pc_register.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SILICORE/SSOOO/register\ file {D:/GitHub Repos/JoSDC-SILICORE/SSOOO/register file/regfile.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SILICORE/SSOOO/addressunit&ld_st\ buffer {D:/GitHub Repos/JoSDC-SILICORE/SSOOO/addressunit&ld_st buffer/addressunit.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SILICORE/SSOOO/memory\ unit {D:/GitHub Repos/JoSDC-SILICORE/SSOOO/memory unit/dm.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SILICORE/SSOOO/common\ data\ bus {D:/GitHub Repos/JoSDC-SILICORE/SSOOO/common data bus/cdb.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SILICORE/SSOOO {D:/GitHub Repos/JoSDC-SILICORE/SSOOO/SSOOO_CPU.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SILICORE/SSOOO/instruction\ queue {D:/GitHub Repos/JoSDC-SILICORE/SSOOO/instruction queue/instq.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SILICORE/SSOOO/reorder\ buffer {D:/GitHub Repos/JoSDC-SILICORE/SSOOO/reorder buffer/rob.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SILICORE/SSOOO/functional\ unit {D:/GitHub Repos/JoSDC-SILICORE/SSOOO/functional unit/alu_oper.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SILICORE/SSOOO/functional\ unit {D:/GitHub Repos/JoSDC-SILICORE/SSOOO/functional unit/alu.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SILICORE/SSOOO/reservation\ station {D:/GitHub Repos/JoSDC-SILICORE/SSOOO/reservation station/rs.v}
vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SILICORE/SSOOO/addressunit&ld_st\ buffer {D:/GitHub Repos/JoSDC-SILICORE/SSOOO/addressunit&ld_st buffer/ldstbuffer.v}

vlog -vlog01compat -work work +incdir+D:/GitHub\ Repos/JoSDC-SILICORE/SSOOO {D:/GitHub Repos/JoSDC-SILICORE/SSOOO/SSOOO_Sim.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L fiftyfivenm_ver -L rtl_work -L work -voptargs="+acc"  SSOOO_Sim

add wave *
view structure
view signals
run -all
