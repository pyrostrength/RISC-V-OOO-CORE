/*

VERIFIED.
Priority encoded selection logic for next instruction PC.
Highest priority given to fetch address change
by branch or JALR instruction from ROB,
then address change associated with JAL instructions
from rename stage,then address change as a result of
predictions made by branch predictor unit,then
ordinary sequential PC.

Freeze signal depends upon the fullness of our ROB
or inavailability of reservation station entry for
certain instruction. We stall the entire backend of 
instruction rename stage when freeze is active high.


Reset signal handles mispredictions and
misdirections.

*/


module PCSelectLogic #(parameter WIDTH = 31)
							 (input logic[WIDTH:0] validAddress,targetAddress,predictedPC,decodePC,
							  input logic isJAL,predictorHit,validCommit,clk,freeze,globalReset,reset,earlyMisdirect,
							  output logic redirect, //if we redirected instruction PC according to predictedPC. JAL has no wrong redirect.
							  output logic[WIDTH:0] nextPC);
							  
							  logic[WIDTH:0] intermediatePC;
							  always_comb begin
									intermediatePC = nextPC + 32'd1;
									redirect = '0;
									//Priority-encoded logic
									if(reset & validCommit) begin
										intermediatePC = targetAddress;
									end
								   //Early misdirect - if we predicted an instruction to be a branch yet it isn't
									else if(earlyMisdirect) begin
										intermediatePC = decodePC + 32'd1;
									end
									else if(isJAL) begin
										intermediatePC = validAddress;
									end
									else if(predictorHit) begin
										intermediatePC = predictedPC;
										redirect = 1'b1;
									end
							 end
							 
							 always_ff @(posedge clk) begin
									if(!freeze) begin
										nextPC <= intermediatePC;
									end
									if(globalReset) begin
										nextPC <= '0;
									end
							 end
endmodule
										
											