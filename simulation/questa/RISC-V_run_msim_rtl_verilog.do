transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+/home/voidknight/Downloads/CPU_Q {/home/voidknight/Downloads/CPU_Q/CDBArbiter.sv}
vlog -sv -work work +incdir+/home/voidknight/Downloads/CPU_Q {/home/voidknight/Downloads/CPU_Q/ALURStationEntry.sv}

vlog -sv -work work +incdir+/home/voidknight/Downloads/CPU_Q {/home/voidknight/Downloads/CPU_Q/regfileTest.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  regfileTest

add wave *
view structure
view signals
run -all
