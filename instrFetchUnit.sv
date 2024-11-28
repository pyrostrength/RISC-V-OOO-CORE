module instrFetchUnit #(parameter WIDTH = 31, INDEX = 7, B_WIDTH = 7)
							  (input logic[WIDTH:0] validAddress,target,oldPC,//valid address,target,seqPC come from other stages.
							   input logic mispredict,misdirect,isJAL,clk,freeze, //other stages
								input logic writeBTB,isControl,takenBranch,branch,
								input logic[INDEX:0] updateIndex,
								input logic[1:0] newState,
							   output logic redirect,
								output logic[WIDTH:0] predictedPCF,instr,instrPC,//read from I-mem
								output logic[INDEX:0] GHRIndex, //from predictor
								output logic[1:0] PHTState); //from predictor
								
								
								//Account for all signals
								logic[WIDTH:0] nextPC,intermediatePC;
								logic direct; //Did we steer instruction fetch according to prediction made by branch predictor.
								PCSelectLogic pcSelect(.*,.redirect(direct),.targetAddress(target));
								
								//BTB relevant signals
							   logic validHit;
								logic[WIDTH:0] predictedPC; //PredictedPC from the Branch Target Buffer forwarded to PC select
								BTB branchTargetBuffer(.*,.resolvedTarget(target),.PC(nextPC),.validRead(validHit),
															  .targetAddress(predictedPC),.oldPC(oldPC[B_WIDTH:0]));
															  
								//Branch predictor(gshare and branchIndex)
								logic[INDEX:0] index;
								logic[1:0] state;
								gshare predictor(.*,.predictorWrite(branch),.previousIndex(updateIndex));
								
								//For a while we have instability on intermediatePC
								
								branchIndex indexGen(.*,.PC(intermediatePC),.wasTaken(takenBranch));
								
								//Valid prediction on BTB
								logic predictorHit;
								assign predictorHit = state[1] & validHit;//Be careful on the variables you're using.
								
								//Instruction memory
								logic[WIDTH:0] instruction;
								imem IMem(.*,.instr(instruction),.rAddress(nextPC));
								
								
								always_ff @(posedge clk) begin
									predictedPCF <= predictedPC;
									GHRIndex <= index;
									PHTState <= state;
									instr <= instruction;
									redirect <= direct;
									instrPC <= nextPC;
								end
									
								
															  
endmodule
