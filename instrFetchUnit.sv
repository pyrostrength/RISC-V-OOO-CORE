module instrFetchUnit #(parameter WIDTH = 31, INDEX = 7, B_WIDTH = 7)
							  (writeCommit outputBus,
							   input logic[WIDTH:0] validAddress,//valid address,target,seqPC come from other stages.
							   input logic isJAL,clk,freeze,globalReset,//other stages
							   output logic redirect,
								output logic[WIDTH:0] predictedPCF,instr,instrPC,//read from I-mem
								output logic[INDEX:0] GHRIndex, //from predictor
								output logic[1:0] PHTState); //from predictor
								
								
								//Account for all signals
								logic[WIDTH:0] nextPC,intermediatePC;
								logic direct; //Did we steer instruction fetch according to prediction made by branch predictor.
								PCSelectLogic pcSelect(.*,.redirect(direct),.targetAddress(outputBus.targetAddress),
								                        .mispredict(outputBus.controlFlow[6]),.misdirect(outputBus.controlFlow[5]),
																.reset(outputBus.controlFlow[0]),.oldPC(outputBus.oldPC));
								
								//BTB relevant signals
							   logic validHit;
								logic[WIDTH:0] predictedPC; //PredictedPC from the Branch Target Buffer forwarded to PC select
								BTB branchTargetBuffer(.*,.resolvedTarget(outputBus.targetAddress),.PC(nextPC),.validRead(validHit),
															  .targetAddress(predictedPC),.oldPC(outputBus.oldPC[B_WIDTH:0]),
															  .writeBTB(outputBus.controlFlow[2]),.takenBranch(outputBus.controlFlow[1]));
															  
								//Branch predictor(gshare and branchIndex)
								logic[INDEX:0] index;
								logic[1:0] state;
								gshare predictor(.*,.predictorWrite(outputBus.controlFlow[7]),.previousIndex(outputBus.previousIndex)
								                 ,.newState(outputBus.controlFlow[4:3]));
								
								//For a while we have instability on intermediatePC
								
								branchIndex indexGen(.*,.PC(nextPC),.wasTaken(outputBus.controlFlow[1]),.branch(outputBus.controlFlow[7])
								                      ,.reset(outputBus.controlFlow[0]));
								
								//Valid prediction on BTB
								logic predictorHit;
								assign predictorHit = state[1] & validHit;//Be careful on the variables you're using.
								
								//Instruction memory
								logic[WIDTH:0] instruction;
								imem IMem(.*,.instr(instruction),.rAddress(nextPC));
								
								
								//Has a register to pass to the next stage
								
								always_ff @(posedge clk) begin
									if(globalReset) begin
										instr <= '0;
										instrPC <=  '0;
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
