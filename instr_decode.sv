/*Instruction decode stage.
If we have a misprediction or misdirect,
we need to clear the register pass a bubble.
If we have no space on ROB indicated by full signal
we pass no value i.e freeze the pipeline*

Reset signal coming from ROB bus control flow signal*/

module instr_decode #(parameter WIDTH = 31, I_WIDTH = 24,REG = 4,ROB = 2, RS = 1, A_WIDTH = 3,INDEX = 7)
							(input logic clk,we,
							 writeCommit robBus, //Don't change the name here
							 input logic redirect,ALUFull,branchFull,
							 input logic[WIDTH:0] predictedPCF,//read from I-mem
							 input logic[INDEX:0] GHRIndex, //from predictor
							 input logic[1:0] PHTState,
							 input logic fullRob,
							 input logic[WIDTH:0] instruction,instrPC,
							 input logic[REG:0] destRegR,
							 input logic[ROB:0] destROB,commitROB,robAllocation, // ROB entry that writes to a destination register.
							 output logic[ROB:0] rob1,rob2,
							 output logic[WIDTH:0] operand1,operand2,
							 output logic[A_WIDTH:0] ALUControl,
							 output logic[WIDTH:0] immExt,pc,
							 output logic[RS:0] RSstation,
							 output logic branch,isJAL,useImm,regWrite, //Must pass out regWrite to bring it back in as write enable for register status.
							 output logic isJALR,isLUI,isAUIPC,stationRequest,
							 output logic[REG:0] destRegW,
							 output logic busy1,busy2,
							 output logic freeze,  //Is respective reservation station full? We must freeze the pipeline.
							 
							 //Associated with branch prediction
							 output logic[1:0] state,
							 output logic[WIDTH:0] predictPC,
							 output logic[2:0] branchFunct3,
							 output logic rdirect,robReq,
							 
							 writeCommit inputBus,
							 
							 //Associated with writing to rob
							 output logic[ROB:0] robInstr);
							 
							//We, destRegD all come from this stage.
							 logic[WIDTH:0] extImm;
							 logic jalr,lui,auipc,stationReq,regWr,jal,brnch,memWr,occupied1,occupied2,immUse,robWrite;
							 logic[1:0] station;
							 logic[3:0] aluC;
							 decodeextend decodeExtender (.*,.immExt(extImm),.ALUControl(aluC),.RSstation(station),
																	.memWrite(memWr),.branch(brnch),.isJAL(jal),.useImm(immUse),.regWrite(regWr),
																	.isJALR(jalr),.isLUI(lui),.isAUIPC(auipc),.stationRequest(stationReq));
							 
							 logic[WIDTH:0] regValue1,regValue2;
							 register_file regfile(.*,.wraddress(robBus.destCommit[4:0]),.wdata(robBus.result),
															.address1(instruction[19:15]),.address2(instruction[24:20]),
															.regWrite(robBus.commitInfo[3]));
															
							logic[ROB:0] src1ROB,src2ROB;
							logic[WIDTH:0] regStatus;
							register_status regTable(.*,.rs1(instruction[19:15]),.rs2(instruction[24:20]),.destReg(instruction[11:7]),
															 .statusRestore(robBus.statusSnap),.regCommit(robBus.destCommit[4:0]),
															 .reset(robBus.controlFlow[0]),.busy1(occupied1),.busy2(occupied2),
															 .regStatusSnap(regStatus),.rob1(src1ROB),.rob2(src2ROB),.validCommit(robBus.validCommit),
															 .regWrite(regWr));
										
							//Value determination
							logic[WIDTH:0] op1,op2;
							always_comb begin
								op1 = regValue1;
								if(immUse) begin
									op2 = extImm;
								end
								else begin
									op2 = regValue2;
								end
							end
							
							logic noRS;
							always_comb begin
								noRS = 1'b0;
								case(station) 
									2'b00:
										noRS = (ALUFull) ? 1'b1 : 1'b0;
									2'b01:
										noRS = (branchFull) ? 1'b1 : 1'b0;
									default:
										noRS = 1'b0;
								endcase
								
								freeze = fullRob | noRS;
								
								robReq = robBus.controlFlow[0] & robWrite; 
							end
							
											
							
							//Just pass on instruction PC.
							//For register status and value determination
							always_ff @(posedge clk) begin
								if(robBus.controlFlow[0]) begin
									{pc,operand1,operand2,immExt} <= '0;
									{busy1,busy2} <= '0;
									{rob1,rob2,robInstr} <= '0;
								end
								else if(!freeze) begin
									pc <= instrPC;
									operand1 <= op1;
									operand2 <= op2;
									busy1 <= occupied1;
									busy2 <= occupied2;
									immExt <= extImm;
									rob1 <= src1ROB;
									rob2 <= src2ROB;
									robInstr <= robAllocation;
								end
							end
							
							logic[3:0] commitInfo;
							assign commitInfo = {regWr,memWr,brnch,jalr};
							//For decode extend unit
							always_ff @(posedge clk) begin
							/*If pipeline flush, we delete the instruction
							  by making no request for a reservation station
							  entry or requesting to write the ROB or writing
							  to register status in the next cycle or
							  making special requests for special instructions*/
								if(robBus.controlFlow[0]) begin
									stationRequest <= '0;
									regWrite <= '0;
									{isJALR,isJAL,isLUI,isAUIPC} <= '0; //No special instruction requests on CDB.
								end
								else if(!freeze) begin
								//To reorder buffer and reorder rename buffer.
									inputBus.commitInfo <= commitInfo;
									inputBus.destination <= {'0,instruction[11:7]};
									inputBus.PHTIndex <= GHRIndex;
									inputBus.regStatus <= regStatus;
									inputBus.instrPC <= instrPC;
									
									regWrite <= regWr;
									isJALR <= jalr;
									branch <= brnch;
									isJAL <= jal;
									useImm <= immUse;
									isLUI <= lui;
									isAUIPC <= auipc;
									stationRequest <= stationReq;
									ALUControl <= aluC;
									RSstation <= station;
									destRegW <= instruction[11:7]; 
									
									state <= PHTState;
									predictPC <= predictedPCF;
									rdirect <= redirect;
									branchFunct3 <= instruction[14:12];
								end
							end

endmodule
																	