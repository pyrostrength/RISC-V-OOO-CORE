/*
Instruction fetch unit. 
Has a 16 entry 8-bit g-share predictor with
256 entry BTB. 

Instruction fetch address could come from
correction in case of branch misprediction(target address),
JAL instructions(from rename stage),prediction from
branch predictor or next sequential PC. Priority is given
in order listed.

*/




module instrFetchUnit #(parameter WIDTH = 31, INDEX = 7, B_WIDTH = 7)
							  (writeCommit outputBus,
							   input logic[WIDTH:0] validAddress,decodePC,
							   input logic isJAL,clk,freeze,globalReset,earlyMisdirect,
							   output logic redirect,
								output logic[WIDTH:0] nextPC,
								output logic[WIDTH:0] predictedPCF,instr,instrPC,
								output logic[INDEX:0] GHRIndex,
								output logic[1:0] PHTState);
								
								logic validCommit;
								assign validCommit = outputBus.validCommit;
								
								//Account for all signals
								logic[WIDTH:0] intermediatePC;
								logic direct; //Did we steer instruction fetch according to prediction made by branch predictor.
								PCSelectLogic pcSelect(.*,.redirect(direct),.targetAddress(outputBus.targetAddress),
																.reset(outputBus.controlFlow[0]));
								
								//BTB relevant signals
							   logic validHit;
								logic[WIDTH:0] predictedPC; //PredictedPC from the Branch Target Buffer forwarded to PC select
								BTB branchTargetBuffer(.*,.resolvedTarget(outputBus.targetAddress),.PC(nextPC),.validRead(validHit),
															  .targetAddress(predictedPC),.oldPC(outputBus.oldPC[B_WIDTH:0]),
															  .writeBTB(outputBus.controlFlow[2]),.takenBranch(outputBus.controlFlow[1]));
															  
								//Branch predictor(gshare and branchIndex)
								logic[INDEX:0] index;
								logic[1:0] state;
								gshare predictor(.*,.predictorWrite(outputBus.commitInfo[1]),.previousIndex(outputBus.previousIndex)
								                 ,.newState(outputBus.controlFlow[4:3]));
								
								
								branchIndex indexGen(.*,.PC(nextPC),.wasTaken(outputBus.controlFlow[1]),.branch(outputBus.commitInfo[1])
								                      ,.reset(globalReset));
								
								//Valid prediction on BTB
								logic predictorHit;
								assign predictorHit = state[1] & validHit;//Be careful on the variables you're using.
								
								//Instruction memory
								logic[WIDTH:0] instruction;
								imem IMem(.*,.instr(instruction),.rAddress(nextPC));
								
								
								
								always_ff @(posedge clk) begin
									/*If globalReset or clear we pass a pipeline bubble i.e info
									that wouldn't introduce permanent state changes that would
									make program execute incorrectly*/
									if(globalReset | (outputBus.controlFlow[0] & validCommit)) begin
										instr <= '0;
										instrPC <=  '0;
										predictedPCF <= '0;
										GHRIndex <= '0;
										PHTState <= '0;
										redirect <= '0;
									end
									else if(!freeze) begin
										predictedPCF <= predictedPC;
										GHRIndex <= index;
										PHTState <= state;
										instr <= instruction;
										redirect <= direct;
										instrPC <= nextPC;
									end
								end
										
								
															  
endmodule
