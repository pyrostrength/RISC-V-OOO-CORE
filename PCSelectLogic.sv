/*

VERIFIED.
Priority encoded selection logic for instruction PC.
Highest priority given to branch mispredict and misdirect related
PC changes then address change associated with JAL instructions
from rename stage,then address change as a result of
predictions made by branch predictor unit,then
ordinary sequential PC

Freeze signal depends upon the fullness of our ROB.
We can opt to stall the entire backend of the pipeline
if an instruction doesn't have space in RS and ROB.

Reset signal indicates that we need to restore
fetch to next sequential address after branch
instruction.

*/


//Global reset signal initializes PC to 0.

module PCSelectLogic #(parameter WIDTH = 31)
							 (input logic[WIDTH:0] validAddress,targetAddress,predictedPC,oldPC,
							  input logic mispredict,misdirect,isJAL,predictorHit,clk,freeze,globalReset,reset,
							  output logic redirect, //if we redirected instruction PC according to predictedPC. JAL has no wrong redirect.
							  output logic[WIDTH:0] nextPC,intermediatePC);
							  
							  //Redirect output signal is passed directly to next stage,instruction decode.
							  
							  logic[WIDTH:0] pcPlus1; //Instruction memory is word addressable. No need for byte addressable.
							  
							  //Ordinary sequential PC is always PC plus 1
							  assign pcPlus1 = nextPC + 32'd1;
							   
							  
							  //Mispredict and misdirect will act as instruction pipeline clear signals.
							  always_comb begin
									intermediatePC = nextPC + 32'd1;
									redirect = '0;
									//Priority-encoded logic
									if(reset) begin
										intermediatePC = oldPC + 32'd1;
									end
									else if(mispredict | misdirect) begin
										intermediatePC = targetAddress;
									end
									//Branching mandated by JAL instruction in rename stage.
									else if(isJAL) begin
										intermediatePC = validAddress;
									end
									
									else if(predictorHit) begin
										intermediatePC = predictedPC;
										redirect = 1'b1;
									end
									
									else begin
										intermediatePC = pcPlus1;
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
										
											