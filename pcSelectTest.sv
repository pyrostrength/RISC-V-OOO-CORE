/* 

VERIFICATION DONE
Test cases for PCSelect Logic
If freeze is active high, pipeline is frozen. No new instruction
is fetched thus fetch remains at the same locations.

If misdirect/mispredict are high 
then preferential choice for next instruction
PC is targetAddress from commit stage.

If misdirect/mispredict aren't high but isJAL
then choice for next instruction PC is validAddress.

Otherwise if there's a hit on BTB choose predicted PC.
Otherwise pick next sequential address ; nextPC plus1;

*/








module pcSelectTest #(parameter WIDTH = 31);
							
							logic[WIDTH:0] validAddress,targetAddress,predictedPC,decodePC;
							logic isJAL,predictorHit,clk,freeze,globalReset,reset,validCommit,earlyMisdirect;
							logic redirect; //if we redirected instruction PC according to predictedPC. JAL has no wrong redirect.
							logic[WIDTH:0] nextPC,intermediatePC;
							
							
							PCSelectLogic selector(.*);
							
							timeunit 1ns; timeprecision 100ps;
							
							initial begin
								clk = '0; //Begin clock pulse at low level.
								forever #2.5 clk = ~clk; //Clock period of 5 nanoseconds. Corresponds to a duty period of 5 nanoseconds. 100 Mhz signal
							end
							
							
							//Test bench logic
							initial begin
								//Say we have address change request by JAL instruction in conjuction with a valid prediction by branch predictor
								isJAL = 1'b1; validAddress = 32'd20 ; predictedPC = 32'd4 ; predictorHit = 1'b1; freeze = 1'b0; #3
								assert (nextPC == validAddress);
								assert (intermediatePC == validAddress);#2
								//Must assert that we have next sequential PC as next fetch location
								isJAL = 1'b0; predictorHit = 1'b0; #3
								assert (nextPC == 32'd21);
								assert (redirect == 1'b0);
								assert (intermediatePC == 32'd22); #2 //Combinational logic assumed to take zero time.
								//Say we have a hit on BTB but isJAL = 0
								predictorHit = 1'b1; predictedPC = 32'd30; #3
								assert (nextPC == predictedPC);
								assert (redirect == 1'b1);
								assert (intermediatePC == predictedPC); #2 //Intermediate PC will equal predicted PC since predictorHit is still high
								//Branch prediction led us down the wrong path but we have an address change request by JAL instruction
								reset = 1'b1 ; targetAddress = 32'd50; #3
								assert(nextPC == targetAddress);
								assert(redirect == 1'b0);
								assert(intermediatePC == (targetAddress)); #2 //Since misdirect is still high
								//Do we have sequential PC following target Address ?
								reset = 1'b0 ; predictorHit = 1'b0; #3
								assert(nextPC == (targetAddress + 32'd1));
								assert(intermediatePC == (targetAddress + 32'd2)); #2
								//What if we run out of space on RS or ROB? Freeze the pipeline
								freeze = 1'b1 ; predictorHit = 1'b1 ; predictedPC = 32'd70; #3
								assert(nextPC == (targetAddress + 32'd1)); //Instruction PC is frozen. Intermediate PC is not.
								assert(intermediatePC == predictedPC); //Freezing the pipeline doesn't impact our choice of intermediatePC
							end
endmodule