/* 
Global History register that records the outcome of the last
10 branches. Bit corresponding to most recent branch outcome
is shifted onto the least signifcant bit of the global history
shift register.

wasTaken is a 1-bit signal indicating whether the most recent branch
was taken. 0 indicates that the branch wasn't taken.

globalHistory is a 10-bit signal capturing the conditional outcomes of the 10
most recent branches. This signal will be XORED with lower 10 bits of PC to form 
pattern history table's indexes.

*/

module ghr #(parameter G_WIDTH = 9)
				(input logic wasTaken,clk,
				 output logic[G_WIDTH:0] globalHistory);
										 
				 always_ff @(posedge clk) begin
						globalHistory[0] <= wasTaken; 
							 for(int i=1 ; i<10 ; i++) begin
									globalHistory[i] <= globalHistory[i-1];
							 end
				 end
endmodule												