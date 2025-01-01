/* 
	Register status file indicating the ROB entry of 
	the instruction writing to a destination register.
	
	Indexed by respective destination register and each entry
	contains associated ROB entry.
	
	For both memory modules we indicate ROB entry to which
	a destination register is assigned on next clock cycle.
	This accounts for corner case in which an instruction's
	source operands' register is the exact same as the 
	destination register.
	
	regCommit is destination register of currently committing instruction.
	destROB is ROB entry that will write to a destination register.
	destReg is destination register.
	
	
	
*/

//regWrite comes from instruction decode stage.

module register_status #(parameter REG = 4, DEPTH = 31, ROB = 2, WIDTH = 31)
								(input logic clk,we,reset,validCommit,globalReset,
								 input logic[REG:0] rs1,rs2,destRegR,regCommit, //Must be sure that an instruction is actually commiting
								 input logic[ROB:0] destROB,commitROB, // ROB entry that writes to a destination register.
								 output logic[ROB:0] rob1,rob2,
								 output logic busy1,busy2); //rob1 and rob2 are {valid,ROB entry}
								
								logic[ROB:0] src1ROB[DEPTH:0];
								
								logic[ROB:0] src2ROB[DEPTH:0];
								
								initial begin
									$readmemb("robSrc.txt",src1ROB);
									$readmemb("robSrc.txt",src2ROB);
									$readmemb("dpendencyBuffer.txt", dependencyBuffer);
								end
								
								logic[WIDTH:0] busyVectorI,busyVectorF;
								
								logic[ROB:0] interRob1,interRob2;
								
								logic[ROB + 1:0] dependencyBuffer[DEPTH : 0];
								
								//{valid,ROB entry} data format.
								logic[ROB + 1:0] interDep;
								
								logic dependent;
								
								assign dependent = (interDep == {validCommit,commitROB});
								
								/* We write register dependency on an instruction
								during instruction rename stage. If there exists a
								commiting instruction we mark it's destination register
								free if it's not being marked by another instruction
								in rename stage. If it's marked by another instruction
								we indicate then we don't mark it free. Our snapshots
								take into account current instruction commits and 
								instructions in rename stage.*/
								
								always_comb begin
									busyVectorI = busyVectorF;
									if(we) begin
										busyVectorI[destRegR] = 1'b1;
									end
									
									if(dependent) begin
										busyVectorI[regCommit] = 1'b0;
									end
								end
								
								/*Determining busy signals accounting
								for instruction commits and writes during rename stage*/
								always_comb begin
									busy1 = busyVectorI[rs1];
									busy2 = busyVectorI[rs2];
									/*if((destRegR == rs1) & we) begin
										busy1 = 1'b1;
									end
									
									else begin
										busy1 = ((rs1 == regCommit) & dependent) ? 1'b0 : busyVectorF[rs1];
									end
									
									if((destRegR == rs2) & we) begin
										busy2 = 1'b1;
									end
									
									else begin
										busy2 = ((rs2 == regCommit) & dependent) ? 1'b0 : busyVectorF[rs2];
									end */
								end
									
							/*Register dependency determination accounting for
							  case in which a previous instruction 
							  marks a destination register that current instruction
							  needs for its operands*/
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
								/*If CPU initialization or committing instruction
								demands pipeline reset*/
								if(globalReset | (reset & validCommit)) begin
									busyVectorF <= '0;
								end
								
								else begin
									busyVectorF <= busyVectorI;
								end
							end
																
endmodule