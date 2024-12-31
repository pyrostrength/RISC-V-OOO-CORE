onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -label aluSrc2 -radix decimal -radixshowbase 0 /cpuSim/aluSrc2
add wave -noupdate -label aluSrc1 -radix decimal -radixshowbase 0 /cpuSim/aluSrc1
add wave -noupdate -label clk /cpuSim/clk
add wave -noupdate -label globalReset /cpuSim/globalReset
add wave -noupdate -label validBroadcast /cpuSim/validBroadcast
add wave -noupdate -label validCommit /cpuSim/validCommit
add wave -noupdate -label nextPC /cpuSim/nextPC
add wave -noupdate -label cntrlFlow /cpuSim/cntrlFlow
add wave -noupdate -label valueBroadcast -radix decimal -radixshowbase 0 /cpuSim/valueBroadcast
add wave -noupdate -label robbroadcast /cpuSim/robBroadcast
add wave -noupdate -label robAllocation /cpuSim/robAllocation
add wave -noupdate -label branchRSReqs /cpuSim/branchRequests
add wave -noupdate -label ALURequests /cpuSim/ALURequests
add wave -noupdate -label instrPC /cpuSim/instrPC
add wave -noupdate -label instr -radix binary -radixshowbase 0 /cpuSim/instr
add wave -noupdate -label immExt -radix decimal -radixshowbase 0 /cpuSim/immExt
add wave -noupdate -label operand1 -radix decimal -radixshowbase 0 /cpuSim/operand1
add wave -noupdate -label operand2 -radix decimal -radixshowbase 0 /cpuSim/operand2
add wave -noupdate -label regDest -radix decimal -radixshowbase 0 /cpuSim/regDest
add wave -noupdate -label result -radix decimal -radixshowbase 0 /cpuSim/result
add wave -noupdate -label regWrite -radix decimal -radixshowbase 0 /cpuSim/rgWr
add wave -noupdate -label robReq /cpuSim/robReq
add wave -noupdate -label branchAvailable /cpuSim/branchAvailable
add wave -noupdate -label ALUInfo /cpuSim/ALUInfo
add wave -noupdate -label aluAvailable /cpuSim/aluAvailable
add wave -noupdate -label redirect /cpuSim/redirect
add wave -noupdate -label predictedPCF /cpuSim/predictedPCF
add wave -noupdate -label GHRIndex /cpuSim/GHRIndex
add wave -noupdate -label branchDataBusReq /cpuSim/branchDataBusReq
add wave -noupdate -label aluDataBusReq /cpuSim/aluDataBusReq
add wave -noupdate -label busy2 /cpuSim/busy2
add wave -noupdate -label busy1 /cpuSim/busy1
add wave -noupdate -label ready2 /cpuSim/ready2
add wave -noupdate -label ready1 /cpuSim/ready1
add wave -noupdate -label rob2 /cpuSim/rob2
add wave -noupdate -label rob1 /cpuSim/rob1
add wave -noupdate -label ALURob /cpuSim/ALURob
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {42400 ps} 0}
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
