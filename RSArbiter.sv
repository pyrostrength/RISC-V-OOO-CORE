/*Arbiter for writing to specific reservation station
entry. Produces writeRequest according to entry availability
which is indicated by the busy field. Only one writeRequest bit
can be high at any given point in time.*/


module RSArbiter #(parameter WIDTH = 31, RS = 1, BRANCH = 1, ALU = 5)
						(input logic[RS:0] RSstation,
						 input logic stationRequest,
						 input logic[BRANCH:0] branchBusyVector,
						 input logic[ALU:0] ALUBusyVector,
						 output logic[BRANCH:0] branchRequests,
						 output logic[ALU:0] ALURequests);
						 
						 
						 logic ALUDone;
						 logic branchDone;
						 logic ALUMatch,branchMatch;
						
						 always_comb begin
								{branchRequests,ALURequests} = '0;
								{ALUDone,branchDone} = '0;
								branchMatch = (RSstation == 2'b01) & stationRequest;
								ALUMatch = (RSstation == 2'b00) & stationRequest;
								if(branchMatch) begin
									for(int i=0;i<=BRANCH;i++)begin
										if(!branchDone) begin
											if(!branchBusyVector[i]) begin
												branchDone = 1'b1;
												branchRequests[i] = 1'b1;
											end
										end
									end
								end
								
								else if(ALUMatch) begin
									for(int i=0;i<=ALU;i++)begin
										if(!ALUDone & ALUMatch) begin
											if(!ALUBusyVector[i]) begin
												ALUDone = 1'b1;
												ALURequests[i] = 1'b1;
											end
										end
									end
								end
						end
endmodule
									
								
									
						 