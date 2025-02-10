RISC_V Out-of-order Core

RTL description of a RISC_V Out-of-Order core 
implementing branching and integer computational instructions.
CPU features an 8-bit g-share predictor and a 256 entry BTB
for branch prediction.

CPU uses implicit renaming strategy with an 8 entry reorder buffer,
4 entry ALU reservation station and 2 entry branch reservation station
(reservation station dedicated to branching instructions) to achieve
out-of-order execution.

Written in System Verilog and design is targeted towards Cyclone V boards.
Actual CPU design module found under RISCV module.
