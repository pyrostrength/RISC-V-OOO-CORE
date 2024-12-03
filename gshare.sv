/* 
   VERIFIED. TOO SIMPLE A MODULE.
	gshare predictor works by xoring the global history branch outcomes vector with
	the lower 8 bits of current PC to form an index that accesses
	a pattern history table whose entries are 2 bit saturating counters. 
	
	Here our pattern history table is implemented as an array of 2-bit
	logic vectors. Next state logic updates pattern history
	table with new state depending on branch conditional outcome.
	State are represented as 2-bit vectors 00,01,10,11
	corresponding to strongly not taken,weakly not taken,weakly taken
	and strongly taken respectively.
	
	For now the state is updated during instruction commit stage meaning
	in the intervening cycles global history register works off of inaccurate
	information.
	
	The output of module, the state, yields the branch prediction
	by wasy of it's MSB.
	
	Given that our PHT as 256 entries each of 2-bit we can implement
	this module as MLAB which allows for new read during write behavior.
	This accounts for simultaneous reads on PHT with update of global
	history register thus providing more accurate predictions.
	
	Entries are read on negative clock edge,hopefully after update occurs.
	Using synchronous read over asynchronous read allows for significanlty less
	logic utilization(22% ALMs vs <1% ALMs).
	
	Will need to make an integrated fetch unit later.

*/



module gshare #(parameter I_WIDTH = 7) //Width of the indexing field.
					  (input logic[I_WIDTH:0] index,previousIndex,
					   input logic[1:0] newState,
					   input logic clk,predictorWrite,
					   output logic[1:0] state);
						
						
						
						//Pattern history table
						logic[1:0] patternTable[0:255];
						
						/*Pattern history table is read asynchronously
						  using index obtained from branchIndex module.
						  Small size allows for MLAB implementation.
						 */
						/*always_comb begin
							state = patternTable[index];
						end */
						
						/*Update state associated with a particular index.
						  on positive clock edge provided predictorWrite
						  is asserted */
						always_ff @(posedge clk) begin
							if(predictorWrite) begin
								patternTable[previousIndex] <= newState;
							end
							state <= patternTable[index];
						end
						
endmodule
								
						
					  
				  