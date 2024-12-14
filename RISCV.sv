/*
Out of order CPU implementing a subset of the RISC_V architecture
(control instruction,integer computational instructions and 
U-type instructions).

Features a gshare branch predictor, uses implicit renaming via
reorder Buffer, single cycle write to reservation station and
wakeup and select.

To be added in future :
Full support for load/store instructions with out of order load-store
execution,caching etc.
TAGE branch predictor.
Pipelined Dadda multiplier and non-restoring division unit.

Target clock speed of 150 MHz.

Changes: instantiate a single writeCommit interface.
Make connections.
Change instruction decode to assign to an interface.

*/




module RISCV #(parameter WIDTH = 31, REG = 4, ROB = 2 , RS = 1, A_WIDTH = 3, INDEX = 7,
					BRANCH = 1, ALU = 3, B_WIDTH = 7)
               (input logic globalReset,clk,
				    output logic[WIDTH:0] result,regDest,nextPC);
				 
				 
				 /*Declare instances of write commit interface which models
				 communication bus between instruction decode stage and fetch stage
				 with the reorder buffer*/
				 writeCommit inputBus();
				 writeCommit outputBus();
				 
				 /*Declare the common data bus*/
				 commonDataBus dataBus(); 
				
				 //instrFetchUnit input signals
				 logic[WIDTH:0] validAddress;//valid address is instruction PC change coming in from the rename stage.
				 logic isJAL,freeze; //isJAL is control signal indicating JAL instruction requesting instruction PC change from rename stage.
				 
				 //instrFetchUnit output signals
				 logic redirect; //Did we redirect program flow according to branch predictor?
				 logic[WIDTH:0] predictedPCF,instr,instrPC;//read from I-mem
				 logic[INDEX:0] GHRIndex; //from predictor
				 logic[1:0] PHTState; //State read off from g-share predictor.
				
				instrFetchUnit fetchStage(.*); 
				
				//Inputs to instruction decode stage
				logic[ROB:0] commitRob;
				logic we; //regWrite passed through flip-flop and looped back to act as write enable on register status table.
				logic[WIDTH:0] instruction;
				logic[REG:0] destRegR;
				logic[ROB:0] destROB,robAllocation;	
				
				//Outputs of instruction decode stage
				logic[ROB:0] rob1,rob2,robInstr;
				logic[WIDTH:0] operand1,operand2;
				logic[A_WIDTH:0] ALUControl;
				logic[WIDTH:0] immExt,pc;
				logic[RS:0] RSstation;
				logic[2:0] branchFunct3;
				logic brnch,jal,useImm,regWrite;
				logic isJALR,stationRequest;
				logic[REG:0] destRegW; //We write ROB dependence on second stage when we're sure that we occupy a register so loop back the output.
				logic busy1,busy2;
				
				logic ALUFull,branchFull;
				
				//Outputs of instruction decode stage
				logic[1:0] state;
				logic[WIDTH:0] predictPC;
				logic rdirect,robReq;
				
				
				
				
				instr_decode decodeStage(.*,.isJAL(jal),.branch(brnch),.robBus(outputBus),.inputBus(inputBus),.commitROB(commitRob),.fullRob(full)); 
				
				assign destRegR = destRegW; //Loop back to write during rename stage
				assign we = regWrite;
				assign destROB = robInstr;
				
				assign instruction = instr;
				
				//Inputs to instruction rename stage
				
				logic[WIDTH+1:0] robValue1,robValue2;
				logic[BRANCH:0] branchBusyVector;
				logic[ALU:0] ALUBusyVector;
				
				//Output from rename stage
				logic[WIDTH:0] targetPC,earlyResult,seqPC;
				logic ready1,ready2,earlyWrite,jump;
				logic signed[WIDTH:0] value1,value2;
				logic[A_WIDTH:0] aluCntrl;
				logic[B_WIDTH:0] brnchCntrl;
				logic[BRANCH:0] branchRequests;
				logic[ALU:0] ALURequests;
				
				renameStage instrRenameStage (.*,.isJAL(jal),.redirect(rdirect));
				
				//Pass values from instruction rename stage on positive clock edge to instruction fetch stage.
				always_ff @(posedge clk) begin
					if(!freeze) begin
						isJAL <= jump;
						validAddress <= targetPC;
					end
					if(globalReset) begin
						isJAL <= '0;
						validAddress <= '0;
					end
				end
				
				//Outputs from ALURS
				logic[ROB:0] ALURob;
				logic[A_WIDTH:0] ALUInfo;
				logic signed[WIDTH:0] aluSrc1,aluSrc2;
				logic aluAvailable,branchAvailable;
				
				//Outputs from branchRS.
				logic signed[WIDTH:0] bsrc1,bsrc2;
				logic[ROB:0] branchRob;
				logic[B_WIDTH:0] branchInfo;
				logic[WIDTH:0] predictedAddress,targetAddress,branchResult;
				
				ALURS aluReservationStation(.*,.ALUControl(aluCntrl),.writeRequests(ALURequests),.instrRob(ALURob)
				                            ,.instrInfo(ALUInfo),.busy(ALUBusyVector),.execute(aluAvailable),.clear(outputBus.controlFlow[0]),
													 .src1(aluSrc1),.src2(aluSrc2));
				
				
				branchRS branchReservationStation(.*,.src1(bsrc1),.src2(bsrc2),.instrInfo(branchInfo),.instrRob(branchRob),.busy(branchBusyVector)
				                                  ,.writeRequests(branchRequests),.predictedPC(predictPC),.address(targetPC)
															 ,.branchControl(brnchCntrl),.execute(branchAvailable),.clear(outputBus.controlFlow[0]));
				
				
				
				functionalUnit executeStage(.*,.predictedPC(predictedAddress),.branchControl(branchInfo),.src1(aluSrc1),.src2(aluSrc2)
													 ,.ALUControl(ALUInfo),.bSrc1(bsrc1),.bSrc2(bsrc2));
				
				//Output from functional Unit is grant signal to pass instruction for execution
				
				//Values from robRenameBuffer.										 
								
				logic[WIDTH:0] ROBValue1,ROBValue2;
				logic valid1,valid2,full; 
				
				reorderBuffer rob(.*,.robWrite(robReq),.inputBus(inputBus),.outputBus(outputBus));
				
				
				/*Instruction decode stage signals from reorder buffer
				Solved by instantiating a single interface and then connecting
				to each module. We instantiate interface outputBus and connect
				to both rob and instruction_decode stage.*/
				
				
				assign fullRob = full; 
				assign robValue1 = {valid1,ROBValue1};
				assign robValue2 = {valid2,ROBValue2};
				
				//CPU output.
				assign result = outputBus.result;
				assign regDest = outputBus.destCommit;
				
				//And that completes the CPU connections.
				
endmodule
				
				