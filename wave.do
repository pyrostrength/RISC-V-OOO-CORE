onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /cpuSim/aluSrc2
add wave -noupdate /cpuSim/aluSrc1
add wave -noupdate -label clk /cpuSim/clk
add wave -noupdate -label globalReset /cpuSim/globalReset
add wave -noupdate -label validBroadcast /cpuSim/validBroadcast
add wave -noupdate -label validCommit /cpuSim/validCommit
add wave -noupdate -label branchRequest /cpuSim/branchRequest
add wave -noupdate -label ALURequest /cpuSim/ALURequest
add wave -noupdate -label nextPC /cpuSim/nextPC
add wave -noupdate -label cntrlFlow /cpuSim/cntrlFlow
add wave -noupdate -label valueBroadcast /cpuSim/valueBroadcast
add wave -noupdate -label robbroadcast /cpuSim/robBroadcast
add wave -noupdate -label robAllocation /cpuSim/robAllocation
add wave -noupdate -label branchReq /cpuSim/branchRequest
add wave -noupdate -label branchRSReqs /cpuSim/branchRequests
add wave -noupdate -label ALURequests /cpuSim/ALURequests
add wave -noupdate -label ALUReq /cpuSim/ALURequest
add wave -noupdate -label instrPC /cpuSim/instrPC
add wave -noupdate -label instr /cpuSim/instr
add wave -noupdate /cpuSim/immExt
add wave -noupdate /cpuSim/operand1
add wave -noupdate /cpuSim/operand2
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {7500 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {100 ns}
