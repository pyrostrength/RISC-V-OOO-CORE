onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -label controlPC /CDBArbiterTest/controlPC
add wave -noupdate -label ALURob /CDBArbiterTest/ALURob
add wave -noupdate -label branchRob /CDBArbiterTest/branchRob
add wave -noupdate -label ALUResult /CDBArbiterTest/ALUResult
add wave -noupdate -label branchResult /CDBArbiterTest/branchResult
add wave -noupdate -label fetchAddress /CDBArbiterTest/fetchAddress
add wave -noupdate -label ALURequest /CDBArbiterTest/ALURequest
add wave -noupdate -label branchRequest /CDBArbiterTest/branchRequest
add wave -noupdate -label clk /CDBArbiterTest/clk
add wave -noupdate -label clear /CDBArbiterTest/clear
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {100 ps} 0}
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
WaveRestoreZoom {300 ps} {900 ps}
