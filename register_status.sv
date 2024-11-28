/* 
	Register status file indicating the ROB entry of 
	the instruction writing to a destination register.
	
	Indexed by respective destination register and each entry
	contains associated ROB entry.
	
	We implement register status as 2 dual port MLAB memory module 
	and 2 dual-port ALM-based memory mode
	
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
	
	destRegD is destReg in decode stage,destRegF is destReg in
	write RS stage.
	
	Forgot about dealing with register status reset.
	
*/


module register_status #(parameter REG = 4, DEPTH = 31, ROB = 2, WIDTH = 31)
								(input logic clk,we,reset,
								 input logic[REG:0] rs1,rs2,destReg,regCommit,
								 input logic[WIDTH:0] statusRestore,
								 input logic[ROB:0] destROB, // ROB entry that writes to a destination register.
								 output logic[ROB:0] rob1,rob2,
								 output logic[WIDTH:0] regStatusSnap,
								 output logic busy1,busy2); //rob1 and rob2 are {valid,ROB entry}
							 
							 
							   /*Two dual port MLAB memory modules
								storing ROB entry associated with
								specific register */
								
								logic[ROB:0] src1ROB[0:DEPTH];
								
								logic[ROB:0] src2ROB[0:DEPTH];
								
								logic[WIDTH:0] busyVectorI,busyVectorF;
								
								logic[ROB:0] interRob1,interRob2;
								
								/*
								For instruction in decode stage,we 
								occupy it's destination register in the rename
								stage where we have ROB entry the instruction
								occupies*/
								
								/*Write control logic that sorts out
								destination register of current instruction
								and register of committing instruction.
								Indicate busyness of register in decode
								stage but mark ROB entry associated with
								instruction in rename stage*/
								always_comb begin
									busyVectorI = busyVectorF;
									if(destReg != regCommit) begin
										busyVectorI[destReg] = 1'b1;
										busyVectorI[regCommit] = 1'b0;
									end
									if(destReg == regCommit) begin
										busyVectorI[destReg] = 1'b1;
									end
								end
								
								/*Sorts out producing the relevant busy signals for
								instruction source operands and register status
								snapshot*/
								always_comb begin
									busy1 = (regCommit == rs1)  ? 1'b0 : busyVectorF[rs1];
									busy2 = (regCommit == rs2) ? 1'b0 : busyVectorF[rs2];
									regStatusSnap = busyVectorF;
								end
									
								/*Provide for asynchrnous read with new data
								behaviour on read during write to account for
								case in which an instruction in rename stage indicates
								its dependency. Significantly slowed down clock speed.
								Instead we use synchronous RAM with bypassing*/
								always_comb begin
									rob1 = (interRob1 == destROB) ? destROB : interRob1;
									rob2 = (interRob2 == destROB) ? destROB : interRob2;
								end
									
								/* Sequential write on positive clock edge*/
								//As soon as I switched to operating regfile on positive clock edge timing issues were fixed.
								always @(posedge clk) begin
									if(we) begin
											src1ROB[destReg] <= destROB;
											src2ROB[destReg] <= destROB;
									end
									if(reset) begin
										busyVectorF <= statusRestore;
									end
									else begin
										busyVectorF <= busyVectorI;
									end
									interRob1 <= src1ROB[rs1];
									interRob2 <= src2ROB[rs2];
								end			
																
endmodule