/* 
VERIFIED
branch = 1'b1 ; wasTaken= 1'b1; PC = 8'b00000000;#3
This module combines the global history register module with
the XOR functionality required to produce the PHT's index.

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



//Only update under conditions for which we have a branching instruction.


module branchIndex #(parameter G_WIDTH = 7)
				(input logic wasTaken,clk,branch,reset,
				 input logic [G_WIDTH:0] PC,
				 output logic[G_WIDTH:0] index);
				 
				 logic[G_WIDTH:0] globalHistory;
				 
		       /*We update value of global history shift register at
		       positive clock edge. Thus we commit and only in the
				 next cycle do we get to use updated branch instruction information.*/		 
				 always_ff @(posedge clk) begin
				 /*State initialization during power-up*/
						if(reset) begin
							globalHistory <= '0;
						end
						else if(branch) begin
							globalHistory[0] <= wasTaken; 
								 for(int i=1 ; i<8 ; i++) begin
										globalHistory[i] <= globalHistory[i-1];
								 end
						end
				 end
				 
				 //Regardless of branch value this xors with branchindex.
				 always_comb begin
					index = globalHistory ^ PC;
				end
					
endmodule												