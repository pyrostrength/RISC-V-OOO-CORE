/* Branch ALU is the functional unit handling branching instructions,
	JAL,JALR instructions. 
	
	{isJAL,isJALR,Branchfunct3,state,redirect} are branchcontrol signals.
	
	redirect signal is the valid bit from BTB access that indicates
	if instruction fetch was redirected to predicted target address.
	
	state is the readout from the pattern history table. It's MSBit
	represents prediction direction.
	
	The Branchfunct3 are BEQ,BNE,BLT,BLT(U) and BGE(U)
	corresponding to bit representations 000,001,010,011,100,101,110.
	
	
	Misdirect is a 1-bit signal indicating that we 
	redirected instruction PC according 
	to hit in BTB yet that isn't correct address. or branch
	isn't taken yet we redirected.
	
	Mispredict is a 1 bit signal indicating if our branch prediction 
	was wrong. We must reset instruction fetch and flush pipeline
	as we fetched from wrong PC.
	
	writeBTB acts as a write enable for Branch Target Buffer. We update
	BTB for all conditional branches predicted as taken 
	regardless of whether predicted PC matched correct address
	and we eliminate entries for which we predicted taken yet
	aren't taken.
	
	Next state logic updates saturating counters
	comprising of the predictor table.
	For now pattern history table is updated during instruction
	commit.
	
	we use bit-vector representing
	strongly taken(11),weakly taken(10),weakly not taken(01) and strongly
	not taken(00). If branch is taken we shift upwards. If branch isn't taken
	we shift downwards.
	
	Request signal is used to request round robin arbiter for opportunity to 
	write result on common data bus.
	
*/

module branchALU #(parameter WIDTH = 31, C_WIDTH = 7)
						(input logic signed[WIDTH:0] src1,src2,PC,immExt,predictedPC, 
						 input logic [C_WIDTH:0] branchControl,
						 output logic signed[WIDTH:0] correctAddress,result,
						 output logic[1:0] nextState,
						 output logic mispredict,misdirect, 
						 output logic writeBTB,request); 
						 
						 logic signed [WIDTH : 0] tempAddress;
						 //BranchControl is {isJAL,isJALR,funct3 for branch,state,redirect}
						 
						 logic takenBranch; //Is branch actually taken ? If yes update PHT. Did we mispredict?
						 
						 always_comb begin
							{writeBTB,takenBranch,misdirect,mispredict,request} = 1'b0;
							nextState = branchControl[2:1]; //Next state equals current state
							tempAddress = src1 + src2;
							result = PC + 32'd4;
							unique case(branchControl[7:6]) //{isJAL,isJALR}
								2'b00: begin //Branch instructions
									correctAddress = PC + immExt;
									request = 1'b1;
									unique case(branchControl[5:3])
										3'b000: begin//BEQ
											takenBranch = (src1 == src2);
										end
										3'b001: begin //BNE
											takenBranch = (src1 != src2);
										end
										3'b010: begin //BLT
											takenBranch = (src1 < src2);
										end
										3'b011: begin//BLT(U)
											takenBranch = unsigned' (src1) < unsigned' (src2);
										end
										3'b100: begin //BGE
											takenBranch = (src1 >= src2);
										end
										3'b101:begin //BGE(U)
											takenBranch = unsigned' (src1) >= unsigned' (src2);
										end
										default: begin 
											takenBranch = 1'b1;
										end
									
									endcase	
									
									/*If we redirected yet correct address doesn't equal that predicted.
									Or if correct address equals that predicted yet we redirected but branch
									wasn't taken*/
									misdirect = ((correctAddress != predictedPC) & branchControl[0]) | (branchControl[0] & !takenBranch);
									
									/*Predictions don't align with outcomes*/
									mispredict = branchControl[2] ^ takenBranch;
										
									/*We only write to the BTB if we have a taken branch or
									we redirected instruction fetch but branch isn't even taken.*/
									writeBTB = takenBranch | (!takenBranch & branchControl[0]); 
									
								end
								
								/*We change instruction PC quite early on for JAL & JALR instructions*/
								2'b01: begin //JALR instructions
									correctAddress = {tempAddress[WIDTH:1],1'b0};
									request = 1'b1;
								end
								
								2'b10: begin //JAL instruction
									correctAddress = tempAddress;
									request = 1'b1;
								end
								
								default: begin  
									correctAddress = tempAddress;
								end
							
							endcase
							
							//Next state logic can occur in parallel. 
							unique case(branchControl[2:1])
										2'b11: nextState = (takenBranch == '1)? 2'b11 : 2'b10; //STAKEN
										2'b10: nextState = (takenBranch == '1) ? 2'b11 : 2'b01; //WTAKEN
										2'b01: nextState = (takenBranch == '1) ?  2'b10: 2'b00; //WNTAKEN
										2'b00: nextState = (takenBranch == '1) ? 2'b01 : 2'b00; //SNTAKEN
							endcase
						end

endmodule


								