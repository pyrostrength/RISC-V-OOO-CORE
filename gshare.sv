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
					   input logic clk,predictorWrite,validCommit,
					   output logic[1:0] state);
						
						
						/*Default prediction of all conditional branching
						instructions as weakly taken*/
						initial begin
							$readmemb("/home/voidknight/Downloads/CPU_Q/gshareInit.txt",patternTable);
						end
						
						//Pattern history table
						logic[1:0] patternTable[0:255];
						
				
				
						/*Update state associated with a particular index.
						  on negative clock edge provided predictorWrite
						  is asserted;signal is transferred through ROB outputBus. */
						always_ff @(negedge clk) begin
							if(predictorWrite & validCommit) begin
								patternTable[previousIndex] <= newState;
							end
							/*Pattern history table is read synchronously
						  using index obtained from branchIndex module.
						  Index obtained by xoring current instruction PC
						  with global history of conditional and unconditional
						  control flow instructions*/
							state <= patternTable[index];
						end
						

						
endmodule
								
						
					  
				  