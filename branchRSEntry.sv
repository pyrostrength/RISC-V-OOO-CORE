/*
Reservation station entry for the branching unit.

consists of instruction info
related to executionthe ROB entry to which 
instruction has been assigned,the
instruction's destination(register or memory address),
values for the source operand .

branchALU's reservation station entries are different from
ALU's.

commonDataBus.reservation_station databus bundles up the result during instruction
write result,the ROB entry associated with the instruction and the valid
broadcast signal.

validAddress provides sequential address for JAL,JALR instructions
or target address for conditional jumps in B-type instructions. 

predictedPC is useful for determining jump predictions.

*/

module branchRSEntry #(parameter WIDTH = 31, ROB = 2, C_WIDTH = 7)
									(commonDataBus.reservation_station dataBus, //shouldn't have the arbiter view
									 input logic ready1,ready2,clear,validCommit,writeReq,clk,selected,execute,globalReset,
									 input logic signed[WIDTH:0] value1,value2,
									 input logic[WIDTH:0] predictedPC,address,seqPC,//Need predictedPC if any to determine if we misdirected.
									 input logic [C_WIDTH:0] branchControl,
									 input logic[ROB:0] rob1,rob2,robInstr,
									 output logic[ROB:0] instrRob,
									 output logic[C_WIDTH:0] instrInfo,
									 output logic[WIDTH:0] predictedAddress,targetAddress,branchResult,
									 output logic busy,selectReq,
									 output logic signed[WIDTH:0] src1,src2); //Leave them as outputs to our RS entry
									 
									 logic value1Ready,value2Ready; //Had we already received the necessary value
									 
									 logic match1,match2; //Match on write result stage then assert 
									 //ready select signals.
									 
									 /*We must indicate the validity of a ROB dependence of an instruction.
									 Done using value ready signal and RS entry busy signal*/
									 
									 logic signed[WIDTH:0] val1,val2;
									 
									 logic[ROB:0] src1Rob,src2Rob;
									 
									 logic busyI;
									 
									 
									 /*Combinational logic for comparing instruction write result
									   ROB entry with source operands ROB entries.
									   We add logic for producing a request to the select logic.
									   Refinement occurs here*/
									 always_comb begin
										match1 =  (dataBus.robEntry == src1Rob) & !value1Ready & busy & dataBus.validBroadcast; //Match only possible if value wasn't ready
										match2 = (dataBus.robEntry == src2Rob) & !value2Ready & busy & dataBus.validBroadcast; 
										selectReq = (value1Ready|ready1|match1) & (value2Ready|ready2|match2); 
										/*When both operands ready, we can request the selection logic.
										Oring the ready inputs and value1Ready signals allows for 
										an instruction to be both written to RS and selected in the same 
										stage
										*/
										busyI = (selected & execute) ? 1'b0 : busy;
										
										src1 = (match1) ? dataBus.result : val1;
										src2 = (match2) ? dataBus.result : val2;
									 end
									 
										
									 /*Writing instruction information to RS entry
									 or capturing value on CDB*/
									 always_ff @(posedge clk) begin
									 /*If a request to clear the RS has been made*/
										if((clear & validCommit) | globalReset) begin
											{value1Ready,value2Ready,busy} <= '0;
											{instrInfo} <= '1;
											{instrRob,src1Rob,src2Rob} <= '0;
											{branchResult,val1,val2,predictedAddress,targetAddress} <= '0;
										end
									 /*If a request to write to the RS has been made*/
										else if(writeReq) begin
											value1Ready <= ready1;
											value2Ready <= ready2;
											instrRob <= robInstr;
											instrInfo <= branchControl;
											val1 <= value1;
											val2 <= value2;
											src1Rob <= rob1;
											src2Rob <= rob2;
											busy <= 1'b1;
											predictedAddress <= predictedPC;
											targetAddress <= address;
											branchResult <= seqPC;
										end
										
										else begin
											busy <= busyI;
										end
										
										/*If match for tag associated with operand we
										store value and indicate operand readiness*/ 
										if(match1 & (!clear & !globalReset)) begin
											val1 <= dataBus.result;
											value1Ready <= 1'b1;
										end
										
										if(match2 & (!clear & !globalReset)) begin
											val2 <= dataBus.result;
											value2Ready <= 1'b1;
										end
										
										
									end
									 
									
endmodule