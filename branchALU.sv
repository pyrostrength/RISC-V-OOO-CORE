/* 
   Branch ALU is the execution unit for branch,JAL,JALR instructions. 
	
	{isJAL,isJALR,Branchfunct3,state,redirect} are branchcontrol signals.
	
	redirect signal indicates if instruction fetch 
	was redirected according to branch prediction.
	
	state is the readout from the pattern history table. It's MSBit
	represents prediction direction. Input to next state logic
	for g-share predictor.
	
	The Branchfunct3 are BEQ,BNE,BLT,BLT(U) and BGE(U)
	corresponding to bit representations 000,001,010,011,100,101,110.
	
	Misdirect is a 1-bit signal indicating that we 
	redirected instruction PC according 
	to hit in BTB yet that isn't correct address. or branch
	isn't taken yet we redirected.
	
	Mispredict is a 1 bit signal indicating if our branch prediction 
	was wrong. We must reset instruction fetch and flush pipeline
	as we fetched from wrong PC.
	
	writeBTB acts as a write enable for Branch Target Buffer. 
	For branches taken we update BTB with instruction
	fetch address associated with the taken branch.
	We also update the BTB for unconditional JALR instructions.
	If branch originally predicted as taken and we redirected
	according to hit on BTB we must indicate invalidity of 
	BTB entry - make the valid bit of BTB valid buffer 0.
	
*/

module branchALU #(parameter WIDTH = 31, C_WIDTH = 7)
						(input logic signed[WIDTH:0] src1,src2,
						 input logic[WIDTH:0] predictedPC,targetAddress,nxtPC,
						 input logic [C_WIDTH:0] branchControl,
						 output logic [WIDTH:0] correctAddress,branchResult,
						 output logic[1:0] nextState,
						 output logic reset,takenBranch, 
						 output logic writeBTB,request); 
						 
						 logic signed [WIDTH : 0] tempAddress;
						 //BranchControl is {isJAL,isJALR,funct3 for branch,state,redirect}
						 
						 //Is branch actually taken ? If yes update PHT. Did we mispredict?
						 
						 logic mispredict,misdirect;
						 
						 always_comb begin
							{writeBTB,takenBranch,request,reset,mispredict,misdirect} = 1'b0;
							nextState = branchControl[2:1]; //Next state equals current state
							tempAddress = src1 + src2;
							branchResult = nxtPC;
							unique case(branchControl[7:6]) //{isJAL,isJALR}
								2'b00: begin //Branch instructions
									request = 1'b1;
									takenBranch = 1'b0; 
									unique case(branchControl[5:3])
										3'b000: begin //BEQ
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
										
										default: takenBranch = 1'b0;
									
									endcase
								
									/*If branch not taken then the correct address is the next sequential PC*/
									correctAddress = (takenBranch) ? nxtPC : targetAddress;
									
									/*If we fetched according to branch prediction yet branch isn't taken
									then we must reset PC for our misprediction. If we branch is taken but
									we redirected instruction fetch to wrong memory location then we must 
									correct this misdirection using actual target address*/
									
									misdirect = (correctAddress != predictedPC) & branchControl[0];
									
									/*Predictions don't align with outcomes - xor*/
									mispredict = branchControl[2] ^ takenBranch;
									
									/*Flush pipeline*/
									reset = mispredict | misdirect;
										
									/*We only write to the BTB if we have a taken branch or
									we redirected instruction fetch but branch isn't even taken.*/
									writeBTB = takenBranch | (!takenBranch & branchControl[0]); 
									
								end
								
								/*JALR and JAL instructions don't update the BTB */
								2'b01: begin //JALR instructions
									{writeBTB,takenBranch}= 1'b0;
									correctAddress = {tempAddress[WIDTH:1],1'b0}; //Actual target address.
									reset = 1'b1; //Since we change next sequential fetch.
									request = 1'b1;
								end
								
								/*JAL instruction changes instruction PC 2 cycles after rename stage.
								We,for now,prevent it from writing to BTB or updating the g-share predictor.*/
								2'b10: begin //JAL instruction
									{writeBTB,takenBranch,reset} = 1'b0;
									correctAddress = targetAddress;
									request = 1'b1;
								end
								
								default: begin  
									correctAddress = tempAddress;
									request = 1'b0;
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


								