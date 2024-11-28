module renameStage #(parameter WIDTH = 31,B_WIDTH = 7, A_WIDTH = 3, BRANCH = 1, ALU = 2,REG = 4, ROB = 2)
                     (commonDataBus.rename_stage dataBus,
							 input logic[ROB:0] rob1,rob2,
							 input logic[REG:0] destReg,
							 input logic[WIDTH:0] regStatusSnap,operand1,operand2,
							 input logic[WIDTH+1:0] robValue1,robValue2,
							 input logic[A_WIDTH:0] ALUControl,
							 input logic[ROB:0] write_ptr,
							 input logic[2:0] branchFunct3,
							 input logic[WIDTH:0] immExt,pc,
							 input logic[1:0] RSstation,
							 input logic memWrite,branch,isJAL,useImm,regWrite,redirect,
							 input logic isJALR,isLUI,isAUIPC,stationRequest,busy1,busy2,
							 input logic [1:0] state,
							 input logic[WIDTH:0] predictedPC,
							 input logic[BRANCH:0] branchBusyVector,
							 input logic[ALU:0] ALUBusyVector,
							 output logic[WIDTH:0] targetPC,earlyResult,seqPC,
							 output logic ready1,ready2,earlyWrite,jump,misdirect,
							 output logic[WIDTH:0] value1,value2,destination,
							 output logic[A_WIDTH:0] aluCntrl,
							 output logic[B_WIDTH:0] brnchCntrl,
							 output logic[ROB:0] instrRob,srcRob1,srcRob2,
							 output logic[BRANCH:0] branchRequests,
							 output logic[ALU:0] ALURequests);
							 
							 
							 assign srcRob1 = (busy1) ? rob1 : '0;
							 assign srcRob2 = (busy2) ? rob2 : '0;
							 
							 assign brnchCntrl = {isJAL,isJALR,branchFunct3,state,redirect};
							 assign aluCntrl = ALUControl;
							 
							 assign destination = {'0,destReg};
							 
							 assign instrRob = write_ptr; //ROB entry to which instruction has been assigned
							 
							 instructionValues valdet1(.instrValue(value1),.operand(operand1),.ROBValue(robValue1),.busy(busy1),.ready(ready1),
																.rob(write_ptr));
							 instructionValues valdet2(.instrValue(value2),.operand(operand2),.ROBValue(robValue2),.busy(busy2),.ready(ready2),
																.rob(write_ptr));
							 
							 RSArbiter arbiter(.*);
							 
							 branchTargetResolve targetResolver(.*,.PC(pc),.targetAddress(targetPC));
							 

endmodule