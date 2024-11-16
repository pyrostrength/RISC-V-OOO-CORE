/* Branch ALU is the functional unit handling branching instructions,
	JAL,JALR instructions. 
	
	{isJAL,isJALR,Branchfunct3,state,redirect} are branchcontrol signals.
	
	redirect signal is the valid signal.
	
	state is the readout from the pattern history table. It's MSBit
	represents prediction direction.
	
	The Branchfunct3 are BEQ,BNE,BLT,BLT(U) and BGE(U)
	corresponding to bit representations 000,001,010,011,100,101,110.
	
	takenBranch is a 1-bit signal updating 2-bit saturating counters
	of the pattern history table.
	
	Misdirect is a 1-bit signal indicating that we redirected instruction PC according
   to hit in BTB yet that isn't correct address. Or we redirected
	yet the branch wasn't taken.
	
	Mispredict is a 1 bit signal indicating if our branch prediction 
	was wrong.
	
	writeBTB acts as a write enable for Branch Target Buffer. We update
	BTB for conditional branches predicted as taken with their instruction
	PC,update incorrect entries predicted as taken and actually
	taken but redirected instruction fetch in
	the wrong direction or eliminate entries for which we predicted as
	taken yet actually arent taken.
	
	Next state logic added to branchALU as branches are resolved by the branch
	functional unit. Pattern history table is updated during instruction
	commit.
	
	Merge this module with PHT Update module which calculates the next state for 
	pattern history table.
	
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
									
									//If we never found a hit in BTB then chances are we never redirect.
									//Some misdirections are resolved early on. PC + immExt
									misdirect = ((correctAddress != predictedPC) & branchControl[0]) | (branchControl[0] & !takenBranch);
									
									mispredict = branchControl[2] ^ takenBranch;
										
									writeBTB = takenBranch | (!takenBranch & branchControl[2]); 
									
								end
								
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


								