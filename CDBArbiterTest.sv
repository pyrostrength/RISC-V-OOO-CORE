/*Test module for the CDB arbiter*/


module CDBArbiterTest #(parameter WIDTH = 31,ROB = 2,CONTROL = 6);
							 
							  commonDataBus dataBus();
							  logic[CONTROL:0] controlPC;
							  logic[ROB:0] ALURob,branchRob;
							  logic[WIDTH:0] ALUResult,branchResult,fetchAddress;
							  logic ALURequest,branchRequest,clk,clear,aluAvailable,branchAvailable;
							  
							  CDBArbiter arbiter(.*);
								
								
								
								timeunit 1ns; timeprecision 100ps;
								
								initial begin
									clk = '0; //Begin clock pulse at low level.
									forever #2.5 clk = ~clk; //Clock period of 5 nanoseconds. Corresponds to a duty period of 5 nanoseconds. 100 Mhz signal
								end
								
								initial begin
									clear = 1'b1; #5 //Set pointer to 0.
									
									/*Only one request by ALU unit with value and request setup before rising clock edge*/
									ALUResult = 32'd60 ; ALURequest = 1'b0; ALURob = 3'd1; #3
									
									assert (dataBus.result == ALUResult);
									assert (dataBus.robEntry == ALURob); 
									
								end
endmodule
								
								
							  
							  