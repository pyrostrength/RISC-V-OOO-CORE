/*
Priority encoded selection logic for instruction PC.
Highest priority given to branch mispredict and misdirect related
PC changes then address change associated with JAL instructions
from rename stage,then address change as a result of
predictions made by branch predictor unit,then
ordinary sequential PC
*/
 //seq pc not important for PC select logic. We instead use the target 
 //address to store instruction PC changer



module PCSelectLogic #(parameter WIDTH = 31)
							 (input logic[WIDTH:0] validAddress,targetAddress,predictedPC,
							  input logic mispredict,misdirect,isJAL,predictorHit,clk,freeze,
							  output logic redirect, //if we redirected instruction PC according to predictedPC. JAL has no wrong redirect.
							  output logic[WIDTH:0] nextPC,intermediatePC);
							  
							  //Redirect output signal is passed directly to next stage,instruction decode.
							  
							  logic[WIDTH:0] pcPlus1; //Instruction memory is word addressable. No need for byte addressable.
							  
							  //Ordinary sequential PC is always PC plus 1
							  assign pcPlus1 = nextPC + 32'd1; 
							  
							  //Mispredict and misdirect will act as instruction pipeline clear signals.
							  always_comb begin
									intermediatePC = '0;
									redirect = '0;
									//Priority-encoded logic
									if(mispredict | misdirect) begin
										intermediatePC = targetAddress;
									end
									//Branching mandated by JAL instruction in rename stage.
									else if(isJAL) begin
										intermediatePC = validAddress;
									end
									
									//Severely limits the clock speed in my cycle. Should try and make it synchronous.
									/*else if(predictorHit) begin
										intermediatePC = predictedPC;
										redirect = 1'b1;
									end */
									else begin
										intermediatePC = pcPlus1;
									end
							 end
							 
							 always_ff @(posedge clk) begin
									if(!freeze) begin
										nextPC <= intermediatePC;
									end
							 end
endmodule
										
											