/*Arbiter for writing to specific reservation station
entry. Produces writeRequest according to entry availability
which is indicated by the busy field. Only one writeRequest bit
can be high at any given point in time.

Instruction in decode stage needs an assured spot
on reservation station.*/


module RSArbiter #(parameter WIDTH = 31, RS = 1, BRANCH = 1, ALU = 3)
						(input logic[RS:0] RSstation,
						 input logic stationRequest,
						 input logic[BRANCH:0] branchBusyVector,
						 input logic[ALU:0] ALUBusyVector,
						 output logic[BRANCH:0] branchRequests,
						 output logic[ALU:0] ALURequests,
						 output logic ALUFull,branchFull);
						 
						 
						 logic ALUDone;
						 logic branchDone;
						 logic ALUMatch,branchMatch;
						
						 always_comb begin
								{branchRequests,ALURequests} = '0;
						      {ALUDone,branchDone} = 1'b0;
								branchMatch = (RSstation == 2'b01) & stationRequest;
								ALUMatch = (RSstation == 2'b00) & stationRequest;
								if(branchMatch) begin
									for(int i=0;i<=BRANCH;i++)begin
										if(!branchDone & branchMatch) begin
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
						
						
						/*Parallel search through of busy vectors to determine
						reservation station fullness. Non-scalable solution*/
						logic[1:0] aluBusy1,aluBusy2;
						logic open1,open2;
						assign aluBusy1 = ALUBusyVector[1:0];
						assign aluBusy2 = ALUBusyVector[3:2];
						
						/*Search through busy vector to determine if
						we at least have 2 slots available. Then based on
						instruction in rename stage requesting availability 
						in reservation station we determine whether the
						reservation station is full*/
						always_comb begin
							{open1,open2} = 1'b1;
							unique case(aluBusy1)
								2'b00 : ALUFull = 1'b0;
								2'b10,2'b01 : open1 = 1'b1;
								2'b11 : open1 = 1'b0;
							endcase
							
							unique case(aluBusy2)
								2'b00 : ALUFull = 1'b0;
								2'b10,2'b01 : open2 = 1'b1;
								2'b11 : open2 = 1'b0;
							endcase
							
							unique case(branchBusyVector)
								2'b00: branchFull = 1'b0;
								2'b01,2'b10: branchFull = (branchMatch) ?  1'b1 : 1'b0;
								2'b11 : branchFull = 1'b1;
							endcase
						   
							ALUFull = (ALUMatch) ? (open1 & open2) : (open1 | open2);
						
						end
									
								
							
						
						/*logic[BRANCH:0] branchOccupancy;
						logic[ALU:0] aluOccupancy;
						
						assign branchOccupancy = branchRequests + branchBusyVector;
						assign aluOccupancy = ALURequests + ALUBusyVector;
						
						always_comb begin
							{ALUFull,branchFull} = '0;
							
							if(branchOccupancy == 2'b11) begin
								branchFull = 1'b1;
							end
							if(aluOccupancy == 4'b1111) begin
								ALUFull = 1'b1;
							end
						end */
endmodule
									
								
									
						 