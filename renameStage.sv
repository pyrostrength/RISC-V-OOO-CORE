/* 
Instruction rename stage.

Write to register status table,performing an implicit
rename of registers, provided that the instruction
writes to a destination register.

Determine source operand values,instruction dependencies
to be buffered in reservation
station as instruction awaits selection for execution.

Determine target address for JAL instructions.

*/


module renameStage #(parameter WIDTH = 31,B_WIDTH = 7, A_WIDTH = 3, BRANCH = 1, ALU = 3, ROB = 2)
                     (commonDataBus.rename_stage dataBus,
							 input logic[WIDTH:0] operand1,operand2,
							 input logic[WIDTH+1:0] robValue1,robValue2,
							 input logic[A_WIDTH:0] ALUControl,
							 input logic[ROB:0] rob1,rob2,
							 input logic[2:0] branchFunct3,
							 input logic[WIDTH:0] immExt,pc,
							 input logic[1:0] RSstation,state,
							 input logic branch,isJAL,useImm,regWrite,redirect,
							 input logic isJALR,stationRequest,busy1,busy2,clk,
							 input logic[BRANCH:0] branchBusyVector,
							 input logic[ALU:0] ALUBusyVector,
							 output logic[WIDTH:0] targetPC,seqPC,
							 output logic ready1,ready2,jump,
							 output logic signed[WIDTH:0] value1,value2,
							 output logic[A_WIDTH:0] aluCntrl,
							 output logic[B_WIDTH:0] brnchCntrl,
							 output logic[BRANCH:0] branchRequests,
							 output logic ALUFull,branchFull,
							 output logic[ALU:0] ALURequests);
							 
							 
							 assign brnchCntrl = {isJAL,isJALR,branchFunct3,state,redirect};
							 assign aluCntrl = ALUControl;
							 
							 instructionValues valdet1(.*,.instrValue(value1),.operand(operand1),.ROBValue(robValue1),.busy(busy1),.ready(ready1),
																.rob(rob1));
							 instructionValues valdet2(.*,.instrValue(value2),.operand(operand2),.ROBValue(robValue2),.busy(busy2),.ready(ready2),
																.rob(rob2));
							 
							 RSArbiter arbiter(.*);
							 
							 branchTargetResolve targetResolver(.*,.PC(pc),.targetAddress(targetPC));
							 

endmodule