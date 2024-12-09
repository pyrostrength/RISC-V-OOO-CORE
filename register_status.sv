/* 
  Lower clock rate to 150 MHz.
  VERIFIED.
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
	
	destReg comes in from instruction in rename stage that was previously
	in the decode stage. It thus fully writes it's occupancy of in 2 stages.
	What about regStatusSnap?
	
	Forgot about dealing with register status reset.
	
*/

//regWrite comes from instruction decode stage.

module register_status #(parameter REG = 4, DEPTH = 31, ROB = 2, WIDTH = 31)
								(input logic clk,we,reset,validCommit,regWrite,
								 input logic[REG:0] rs1,rs2,destReg,destRegR,regCommit, //Must be sure that an instruction is actually commiting
								 input logic[WIDTH:0] statusRestore,
								 input logic[ROB:0] destROB,commitROB, // ROB entry that writes to a destination register.
								 output logic[ROB:0] rob1,rob2,
								 output logic[WIDTH:0] regStatusSnap,
								 output logic busy1,busy2); //rob1 and rob2 are {valid,ROB entry}
							 
							 
							   /*Two dual port MLAB memory modules
								storing ROB entry associated with
								specific register. Provide initial states
							   for register-ROB dependencies on power-up
								*/
								
								logic[ROB:0] src1ROB[0:DEPTH];
								
								logic[ROB:0] src2ROB[0:DEPTH];
								
								initial begin
									$readmemb("robSrc.txt",src1ROB);
									$readmemb("robSrc.txt",src2ROB);
									$readmemb("dpendencyBuffer.txt", dependencyBuffer);
								end
								
								logic[WIDTH:0] busyVectorI,busyVectorF;
								
								logic[ROB:0] interRob1,interRob2;
								
								
								logic[ROB + 1:0] dependencyBuffer[0:DEPTH];
								
								//{valid,ROB entry} data format.
								logic[ROB + 1:0] latestDpndency,interDep;
								
								logic dependent;
								
								/* Determine register's current dependency based on committing instruction
								and instruction writing to register status table.*/
								always_comb begin
								//Need to provide bypassing as altsyncram configuration was changed such that
								//asynchronous read provides old data.
									latestDpndency = (destRegR == regCommit) ? {we,destROB} : interDep;
									dependent = (latestDpndency[ROB:0] == commitROB) & latestDpndency[ROB+1] & validCommit;
								end
								
								/*
								For instruction in decode stage,we 
								occupy it's destination register in the rename
								stage where we have ROB entry the instruction
								occupies*/
								
								/*We determine busyness of registers by
								comparing destination registers written to 
								by instruction and registers
								freed by instruction in commit stage. Updated
								busy information available on next clock edge
								allowing us to take a snapshot of register status
								table before updating it. Instruction writes
								its busyness and ROB entry in rename stage.*/
								
								always_comb begin
									busyVectorI = busyVectorF;
									if(destReg != regCommit) begin
										if(regWrite) begin
											busyVectorI[destReg] = 1'b1;
										end
										if(dependent) begin
											busyVectorI[regCommit] = 1'b0;
										end
									end
									else if(destReg == regCommit) begin
										if(regWrite) begin
											busyVectorI[destReg] = 1'b1;
										end
										else if(dependent) begin //
											busyVectorI[destReg] = 1'b0;
										end
									end
								end
								
								/*Register is busy if current commiting instruction
								doesn't free it (register mismatch or later instruction
							   indicated register's dependence on it.*/
								
								always_comb begin
									busy1 = busyVectorF[rs1];
									busy2 = busyVectorF[rs2];
									
									if((regCommit == rs1) & dependent) begin
											busy1 = 1'b0;
									end
										
									if((regCommit == rs2) & dependent) begin
											busy2 = 1'b0;
									end
									/*Snapshot of the busyVector prior to instruction
									indicating destination register's dependence on it.*/
									regStatusSnap = busyVectorF;
								end
									
								/*Destination register ROB entry dependency determination 
								accounting for instruction in rename stage writing
								to register status table. destROB is ROB entry of 
								instruction in rename stage.*/
								always_comb begin
									rob1 = ((rs1 == destRegR) & we) ? destROB : interRob1;
									rob2 = ((rs2 == destRegR) & we) ? destROB : interRob2;
								end
									
								/* Sequential write on negative clock edge*/
								always @(negedge clk) begin
									if(we) begin
											src1ROB[destRegR] <= destROB;
											src2ROB[destRegR] <= destROB;
											dependencyBuffer[destRegR] <= {we,destROB};
									end
									interDep <= dependencyBuffer[regCommit];
									interRob1 <= src1ROB[rs1];
									interRob2 <= src2ROB[rs2];
								end
					
							always_ff @(posedge clk) begin
								if(reset) begin
									busyVectorF <= statusRestore;
								end
								
								else begin
									busyVectorF <= busyVectorI;
								end
							end
																
endmodule