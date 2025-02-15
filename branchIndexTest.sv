/* 
VERIFIFED
Test cases
Shifting in wasTaken high 10 times at clock edge.
Like this 11011.
shift in PC and eveluate index.
Easy work.

Took much much longer than I needed. Simulator is
very annoying.

*/





module branchIndexTest #(parameter G_WIDTH = 7);
								
								logic wasTaken,clk,branch,reset;
								logic[G_WIDTH:0] PC;
								logic[G_WIDTH:0] index;
								
								
							timeunit 1ns; timeprecision 100ps;
							
							initial begin
								clk = 1'b1; //Begin clock pulse at low level.
								forever #2.5 clk = ~clk; //Clock period of 5 nanoseconds. Corresponds to a duty period of 5 nanoseconds. 100 Mhz signal
							end
							
							branchIndex indexGen(.*);
							
							//Test bench logic
							initial begin
								//Say we have address change request by JAL instruction in conjuction with a valid prediction by branch predictor
								reset = 1'b1; #5
								
								branch = 1'b1 ; wasTaken= 1'b1; PC = 8'b00000000; reset = 1'b0; #3
								assert (index == 8'b00000001); #2
								//Must assert that we have next sequential PC as next fetch location
								
								branch = 1'b1 ; wasTaken= 1'b1; PC = 8'b00000001; #3
								assert (index == 8'b00000010) ; #2
								
								branch = 1'b1 ; wasTaken= 1'b0; PC = 8'b00001000; #3
								assert (index == 8'b00001110) ; #2
								
								branch = 1'b1 ; wasTaken= 1'b1; PC = 8'b00001001;#3
								assert (index == 8'b00000100); #2
								
								branch = 1'b1 ; wasTaken= 1'b1; PC = 8'b00000010; #3
								assert (index == 8'b00011001);
						  end
endmodule