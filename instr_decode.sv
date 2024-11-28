/*Instruction decode stage.
If we have a misprediction or misdirect,
we need to clear the register pass a bubble.
If we have no space on ROB indicated by full signal
we pass no value i.e freeze the pipeline*/

module instr_decode #(parameter WIDTH = 31, I_WIDTH = 24,REG = 4,ROB = 2, RS = 1, A_WIDTH = 3)
							(input logic clk,we,
							 writeCommit.instr_decode robBus,
							 input logic fullRob,
							 input logic[WIDTH:0] instruction,instrPC,
							 input logic[REG:0] destRegD,
							 input logic[ROB:0] destROB, // ROB entry that writes to a destination register.
							 output logic[ROB:0] rob1,rob2,
							 output logic[WIDTH:0] regStatusSnap,operand1,operand2,
							 output logic[A_WIDTH:0] ALUControl,
							 output logic[WIDTH:0] immExt,pc,
							 output logic[RS:0] RSstation,
							 output logic memWrite,branch,isJAL,useImm,regWrite,
							 output logic isJALR,isLUI,isAUIPC,stationRequest,
							 output logic[REG:0] destRegW,
							 output logic busy1,busy2);
							 
							//We, destRegD all come from this stage.
							 logic[WIDTH:0] extImm;
							 logic jalr,lui,auipc,stationReq,regWr,jal,brnch,memWr,occupied1,occupied2,immUse;
							 logic[2:0] station;
							 logic[3:0] aluC;
							 decodeextend decodeExtender (.*,.immExt(extImm),.ALUControl(aluC),.RSstation(station),
																	.memWrite(memWr),.branch(brnch),.isJAL(jal),.useImm(immUse),.regWrite(regWr),
																	.isJALR(jalr),.isLUI(lui),.isAUIPC(auipc),.stationRequest(stationReq));
							 
							 logic[WIDTH:0] regValue1,regValue2;
							 register_file regfile(.*,.wraddress(robBus.commitInfo[4:0]),.wdata(robBus.result),
															.address1(instruction[19:15]),.address2(instruction[24:20]),
															.regWrite(robBus.commitInfo[WIDTH+4]));
															
							logic[ROB:0] src1ROB,src2ROB;
							logic[WIDTH:0] statusSnap;
							register_status regTable(.*,.rs1(instruction[19:15]),.rs2(instruction[24:20]),.destReg(destRegD),
															 .statusRestore(robBus.regStatusC),.regCommit(robBus.commitInfo[4:0]),
															 .reset(robBus.controlFlow[0]),.busy1(occupied1),.busy2(occupied2),
															 .regStatusSnap(statusSnap),.rob1(src1ROB),.rob2(src2ROB));
										
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
							
							//Just pass on instruction PC.
							//For register status and value determination
							always_ff @(posedge clk) begin
								if(robBus.controlFlow[0]) begin
									{pc,operand1,operand2,immExt,regStatusSnap} <= '0;
									{busy1,busy2} <= '0;
									{rob1,rob2} <= '0;
								end
								else if(!fullRob) begin
									pc <= instrPC;
									operand1 <= op1;
									operand2 <= op2;
									busy1 <= occupied1;
									busy2 <= occupied2;
									regStatusSnap <= statusSnap;
									immExt <= extImm;
									rob1 <= src1ROB;
									rob2 <= src2ROB;
								end
							end
							
							//For decode extend unit
							always_ff @(posedge clk) begin
								if(robBus.controlFlow[0]) begin
									{isJALR,branch,memWrite,isJAL,useImm,regWrite} <= '0;
									{isLUI,isAUIPC,stationRequest} <= '0;
									ALUControl <= '0;
									RSstation <= '0;
								end
								else if(!fullRob) begin
									isJALR <= jalr;
									memWrite <= memWr;
									branch <= brnch;
									isJAL <= jal;
									useImm <= immUse;
									regWrite <= regWr;
									isLUI <= lui;
									isAUIPC <= auipc;
									stationRequest <= stationReq;
									ALUControl <= aluC;
									RSstation <= station;
									destRegW <= instruction[11:7]; 
								end
							end

endmodule
																	