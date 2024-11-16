/* Register status file indicating the ROB entry of 
	the instruction writing to a destination register.
	
	Indexed by respective destination register and each entry
	contains associated ROB entry.
	
	We implement register status as 2 dual port MLAB memory module 
	and 2 dual-port ALM-based memory module.
	
	For both memory modules we indicate ROB entry to which
	a destination register is assigned on next clock cycle.
	This meshes well with current system design as well as 
	accounts for corner case in which an instruction's
	source operands' register is the exact same as the 
	destination register.
	
	regCommit is destination register of currently committing instruction.
	regCommit is only relevant for busy buffers.
	destROB is ROB entry writing to a destination register.
	destReg is destination register.
	
	Write enable is active if instruction writes to a
	destination register. If destination register
	is x0 value to be passed is changed to zero.
	
*/


module register_status #(parameter REG = 4, DEPTH = 31, ROB = 2)
								(input logic clk,we,
								 input logic[REG:0] rs1,rs2,destReg,regCommit,
								 input logic[ROB:0] destROB, // ROB entry that writes to a destination register.
								 output logic[ROB:0] rob1,rob2,
								 output logic busy1,busy2); //rob1 and rob2 are {valid,ROB entry}
							 
							 
							   /*Two dual port MLAB memory modules
								storing ROB entry associated with
								specific register */
								
								logic[ROB:0] src1ROB[0:DEPTH];
								
								logic[ROB:0] src2ROB[0:DEPTH];
								
								/*1 ALM-based quad-port 
								memory block indicating if
								there exists an uncommitted instruction
								writing to a specific destination register.
								For current instruction in decode stage,we 
								occupy it's destination register in the rename
								stage where we have the ROB entry the instruction
								should occupy*/
								
								logic busybuffer1[0:DEPTH];
								
								logic busybuffer2[0:DEPTH];
								
								//Combinational read.
								always_comb begin
									busy1 = busybuffer1[rs1];
									busy2 = busybuffer2[rs2];
									rob1 = src1ROB[rs1];
									rob2 = src2ROB[rs2];
								end
									
								// Sequential write on negative clock edge
								always @(negedge clk) begin
									if(we) begin
											src1ROB[destReg] <= destROB;
											src2ROB[destReg] <= destROB;
											busybuffer1[regCommit] <= '0;
											busybuffer1[destReg] <= '1;
											busybuffer2[regCommit] <= '0;
											busybuffer2[destReg] <= '1;
									end
								end				
																
endmodule