/*

VERIFIED

Reservation station entry for the ALU.

consists of instruction info
related to its execution, ROB entry to which instruction has
been assigned,the
instruction's destination(register or memory address),values for the
source operand if available during write to reservation station
entry or written in during instruction write result stage.

We store instruction value on positive clock edge
after match between CDB ROB entry
ROB entry and source entry stored in RS entry. 
This requires 2 comparators
for every single entry.

Reservation station entries depend on functional unit.


*/

module ALURStationEntry #(parameter WIDTH = 31, ROB = 2, C_WIDTH = 3)
									(commonDataBus.reservation_station dataBus, //shouldn't have the arbiter view
									 input logic ready1,ready2,clear,writeReq,clk,
									 input logic selected,execute,
									 input logic signed[WIDTH:0] value1,value2,
									 input logic [C_WIDTH:0] ALUControl,
									 input logic[ROB:0] rob1,rob2,robInstr,
									 output logic[ROB:0] instrRob,
									 output logic[C_WIDTH:0] instrInfo,
									 output logic busy,selectReq,
									 output logic signed[WIDTH:0] src1,src2); //Leave them as outputs to our RS entry
									 
									 logic value1Ready,value2Ready,valRdy1,valRdy2; //Had we already received the necessary value
									 
									 logic signed[WIDTH:0] val1,val2;
									 
									 logic match1,match2; //Match on write result stage then assert 
									 //ready select signals.
									 
									 /*We must indicate the validity of a ROB dependence of an instruction.
									 Done using value ready signal and RS entry busy signal*/
									 
									 logic[ROB:0] src1Rob,src2Rob;
									 
									 logic busyI; //Signal to change busyness of entry if selected and we can execute;
									 
									 logic selectReq1,selectReq2;
									 
									 /*Combinational logic for comparing instruction write result
									   ROB entry with source operands ROB entries.
									   We add logic for producing a request to the select logic.
									   Refinement occurs here*/
									 always_comb begin
										match1 =  (dataBus.robEntry == src1Rob) & !value1Ready & busy & dataBus.validBroadcast; //Match only possible if value wasn't ready
										match2 = (dataBus.robEntry == src2Rob) & !value2Ready & busy & dataBus.validBroadcast; 
										selectReq1 = (value1Ready|ready1|match1);
										selectReq2 = (value2Ready|ready2|match2);
										selectReq = selectReq1 & selectReq2;
										/*When both operands ready, we can request the selection logic.
										Oring the ready inputs and value1Ready signals allows for 
										an instruction to be both written to RS and selected in the same 
										stage
										*/
										busyI = (selected & execute) ? 1'b0 : busy;
										
										//Source values either value broadcast on CDB or value stored in RS.
										src1 = (match1) ? dataBus.result : val1;
										
										src2 = (match2) ? dataBus.result : val2;
										
										
									 end
									 
										
									 /*Writing instruction information to RS entry
									 or capturing value on CDB*/
									 always_ff @(posedge clk) begin
									 /*If a request to clear the RS has been made*/
										if(clear) begin
											{value1Ready,value2Ready,busy} <= '0;
											{instrInfo} <= '0;
											{instrRob} <= '0;
										end
									 /*If a request to write to the RS has been made*/
										else if(writeReq) begin
											value1Ready <= ready1;
											value2Ready <= ready2;
											instrRob <= robInstr;
											instrInfo <= ALUControl;
											val1 <= value1;
											val2 <= value2;
											src1Rob <= rob1;
											src2Rob <= rob2;
											busy <= 1'b1;
										end
										
										else begin
											busy <= busyI;
										end
										
										/*If match for tag associated with operand we
										store value and indicate operand readiness*/ 
										if(match1) begin
											val1 <= dataBus.result; 
											value1Ready <= 1'b1;
										end
										
										/*If match for tag associated with operand we
										store value and indicate operand readiness*/ 
										if(match2) begin
											val2 <= dataBus.result;
											value2Ready <= 1'b1;
										end
									end
									
									 
									
endmodule
									
										
									 
									 
									 
									 
									 