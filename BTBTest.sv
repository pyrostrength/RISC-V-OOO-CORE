/*

VERIFIED

Test module for the branch target buffer.

Check for power up state - no predictions
yet.

Fill BTB with predictions. For one change it's
prediction to not taken so as BTB hit changes.

Check for address conflict

*/




module BTBTest #(parameter WIDTH = 31, B_WIDTH = 7);
						logic[WIDTH:0] resolvedTarget;
			         logic[B_WIDTH:0] PC,oldPC;
			         logic writeBTB,clk,takenBranch;
				      logic validRead,validCommit;
			         logic[WIDTH:0] targetAddress;
					 
					 
					 
					 	timeunit 1ns; timeprecision 100ps;
							
						initial begin
							clk = 1'b0; //Begin clock pulse at low level.
							forever #2.5 clk = ~clk; //Clock period of 5 nanoseconds. Corresponds to a duty period of 5 nanoseconds. 100 Mhz signal
						end
						
						BTB buffer(.*);
						
						initial begin
							//No prediction available. What do we read on power up?
							PC = 8'd1 ; #3
							assert (validRead == 1'b0) ; #2
							
							//Fill with instruction PC's associated with taken branches
							writeBTB = 1'b1 ; resolvedTarget = 32'd30 ; takenBranch = 1'b1; oldPC = 8'd1; #3 //should have old data behaviour
							assert (validRead == 1'b0); #5
							assert (validRead == 1'b1); //We pulsed in prediction
							assert (targetAddress == resolvedTarget); #2
							
							//Address conflict. Fill with a different target
							resolvedTarget = 32'd50; oldPC = 8'd17 ; takenBranch = 1'b1 ; #8 
						   assert (validRead == 1'b0) ; //Address was replaced.
						   assert (targetAddress == 32'd50) ; #2
						
					      //We changed a prediction to nil. Found out branch isn't taken
						   oldPC = 8'd17 ; takenBranch = 1'b0 ; #8
					      assert (validRead == 1'b0);
					  end	
endmodule 