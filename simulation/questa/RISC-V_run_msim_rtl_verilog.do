transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+/home/voidknight/Downloads/CPU_Q {/home/voidknight/Downloads/CPU_Q/extend.sv}
vlog -sv -work work +incdir+/home/voidknight/Downloads/CPU_Q {/home/voidknight/Downloads/CPU_Q/ALU.sv}
vlog -sv -work work +incdir+/home/voidknight/Downloads/CPU_Q {/home/voidknight/Downloads/CPU_Q/ALUDecoder.sv}
vlog -sv -work work +incdir+/home/voidknight/Downloads/CPU_Q {/home/voidknight/Downloads/CPU_Q/branchIndex.sv}
vlog -sv -work work +incdir+/home/voidknight/Downloads/CPU_Q {/home/voidknight/Downloads/CPU_Q/infodecoder.sv}
vlog -sv -work work +incdir+/home/voidknight/Downloads/CPU_Q {/home/voidknight/Downloads/CPU_Q/branchALU.sv}
vlog -sv -work work +incdir+/home/voidknight/Downloads/CPU_Q {/home/voidknight/Downloads/CPU_Q/CDBArbiter.sv}
vlog -sv -work work +incdir+/home/voidknight/Downloads/CPU_Q {/home/voidknight/Downloads/CPU_Q/branchTargetResolve.sv}
vlog -sv -work work +incdir+/home/voidknight/Downloads/CPU_Q {/home/voidknight/Downloads/CPU_Q/ALUSelect.sv}
vlog -sv -work work +incdir+/home/voidknight/Downloads/CPU_Q {/home/voidknight/Downloads/CPU_Q/branchSelect.sv}
vlog -sv -work work +incdir+/home/voidknight/Downloads/CPU_Q {/home/voidknight/Downloads/CPU_Q/srcMux.sv}
vlog -sv -work work +incdir+/home/voidknight/Downloads/CPU_Q {/home/voidknight/Downloads/CPU_Q/PCSelectLogic.sv}
vlog -sv -work work +incdir+/home/voidknight/Downloads/CPU_Q {/home/voidknight/Downloads/CPU_Q/RSArbiter.sv}
vlog -sv -work work +incdir+/home/voidknight/Downloads/CPU_Q {/home/voidknight/Downloads/CPU_Q/register_file.sv}
vlog -sv -work work +incdir+/home/voidknight/Downloads/CPU_Q {/home/voidknight/Downloads/CPU_Q/imem.sv}
vlog -sv -work work +incdir+/home/voidknight/Downloads/CPU_Q {/home/voidknight/Downloads/CPU_Q/gshare.sv}
vlog -sv -work work +incdir+/home/voidknight/Downloads/CPU_Q {/home/voidknight/Downloads/CPU_Q/BTB.sv}
vlog -sv -work work +incdir+/home/voidknight/Downloads/CPU_Q {/home/voidknight/Downloads/CPU_Q/register_status.sv}
vlog -sv -work work +incdir+/home/voidknight/Downloads/CPU_Q {/home/voidknight/Downloads/CPU_Q/decodeextend.sv}
vlog -sv -work work +incdir+/home/voidknight/Downloads/CPU_Q {/home/voidknight/Downloads/CPU_Q/instructionValues.sv}
vlog -sv -work work +incdir+/home/voidknight/Downloads/CPU_Q {/home/voidknight/Downloads/CPU_Q/ROBrenamebuffer.sv}
vlog -sv -work work +incdir+/home/voidknight/Downloads/CPU_Q {/home/voidknight/Downloads/CPU_Q/ALURStationEntry.sv}
vlog -sv -work work +incdir+/home/voidknight/Downloads/CPU_Q {/home/voidknight/Downloads/CPU_Q/branchRSEntry.sv}
vlog -sv -work work +incdir+/home/voidknight/Downloads/CPU_Q {/home/voidknight/Downloads/CPU_Q/functionalUnit.sv}
vlog -sv -work work +incdir+/home/voidknight/Downloads/CPU_Q {/home/voidknight/Downloads/CPU_Q/reorderBuffer.sv}
vlog -sv -work work +incdir+/home/voidknight/Downloads/CPU_Q {/home/voidknight/Downloads/CPU_Q/ALURS.sv}
vlog -sv -work work +incdir+/home/voidknight/Downloads/CPU_Q {/home/voidknight/Downloads/CPU_Q/branchRS.sv}
vlog -sv -work work +incdir+/home/voidknight/Downloads/CPU_Q {/home/voidknight/Downloads/CPU_Q/renameStage.sv}
vlog -sv -work work +incdir+/home/voidknight/Downloads/CPU_Q {/home/voidknight/Downloads/CPU_Q/instrFetchUnit.sv}
vlog -sv -work work +incdir+/home/voidknight/Downloads/CPU_Q {/home/voidknight/Downloads/CPU_Q/instr_decode.sv}
vlog -sv -work work +incdir+/home/voidknight/Downloads/CPU_Q {/home/voidknight/Downloads/CPU_Q/RISCV.sv}

vlog -sv -work work +incdir+/home/voidknight/Downloads/CPU_Q {/home/voidknight/Downloads/CPU_Q/regfileTest.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  regfileTest

add wave *
view structure
view signals
run -all
