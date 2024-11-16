/*This module forms the next state logic for 
the 2-bit saturating counters of our branch predictor. 
However, we can only determine the next state logic
after branch condition evaluation in the execute stage.

The branch predictor is therefore distributed across the pipeline. 
We risk feeding the pipeline with wrong instructions 
since any instruction PC predicted as a taken branch will fetch 
from address indicated in branch target buffer.

As a safeguard, pattern history table is initialized with
all zeroes. Thus all branches are initially assumed 
strongly not taken.

Instead of using enumerated state type, we use bit-vector representing
strongly taken(11),weakly taken(10),weakly not taken(01) and strongly
not taken(00). If branch is taken we shift upwards. If branch isn't taken
we shift downwards.


*/

module PHTUpdate (input logic[9:0] previousIndex, //previousIndex not even used.
                  input logic[1:0] state, //what state had we predicted ? Current state and branch outcome produce the  next state
						input logic wasTaken, //was branch taken? This is the branch outcome producing the next state.
						output logic[1:0] nextState);

						always_comb begin
							unique case(state)
								2'b11: nextState = (wasTaken == '1)? 2'b11 : 2'b10; //STAKEN
								2'b10: nextState = (wasTaken == '1) ? 2'b11 : 2'b01; //WTAKEN
								2'b01: nextState = (wasTaken == '1) ?  2'b10: 2'b00; //WNTAKEN
								2'b00: nextState = (wasTaken == '1) ? 2'b01 : 2'b00; //SNTAKEN
							endcase
						end
endmodule