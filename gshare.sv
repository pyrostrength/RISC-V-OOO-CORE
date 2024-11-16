/* gshare predictor works by xoring the global history branch outcomes vector with
	the lower 10 bits of current PC to form an index that accesses
	a pattern history table whose entries are 2 bit saturating counters. 
	
	Here our pattern history table is implemented as an array of 2-bit
	logic vectors. The FSM associated with every array entry is
	distributed - the next state logic is determined in the execute 
	stage of our pipeline. We update on global history register on
	subsequent cycle and use that value to calculate our PHT index.
	
	The state of the 2-bit saturating counter determines whether branch is
	predicted as taken or not taken.
	States are strongly taken,weakly taken,weakly not taken,strongly not taken with
	binary encodings 3 to 0 respectively. MSB of state binary encoding yields
	branch prediction direction whilst LSB of state binary encoding yields
	the hysteresis - prevents abrupt direction of prediction changes.
	
	The output of module, the state, yields the prediction by way of it's MSB.
	
	Entries are updated on positive clock edge in order to reflect actual conditional outcomes
	associated with a particular index, as determined during execution stage. 
	
	Entries are read on negative clock edge,hopefully after update occurs.
	Using synchronous read over asynchronous read allows for significanlty less
	logic utilization(22% ALMs vs <1% ALMs)

*/



module gshare #(parameter WIDTH = 31, 
                            I_WIDTH = 9) //Width of the indexing field.
					  (input logic[I_WIDTH:0] PC,previousIndex,
					   input logic[1:0] newState,
					   input logic clk,predictorWrite,wasTaken,
					   output logic[1:0] state);
						
						logic[I_WIDTH:0] globalHistory,index;
						//global history represents most recent conditional branch outcomes
						//index is used to access the pattern history table.
						branchIndex indexModule(.*);
						
						
						//Pattern history table
						logic[1:0] patternTable[0:1023];
						
						//Pattern history table is read sequentially
						//using index obtained from branchIndex module.
						//this index uses the previous record of branch
						//conditional outcome as timing doesn't allow
						//using the updated record.
						always_ff @(negedge clk) begin
							state <= patternTable[index];
						end
						
						//Update state associated with a particular index.
						//after determination of conditional outcomes in 
						//branch execute stage.
						//Update occurs on positive clock edge provided predictorWrite
						always_ff @(negedge clk) begin
							if(predictorWrite)
								patternTable[previousIndex] <= newState;
						end
						
endmodule
								
						
					  
				  