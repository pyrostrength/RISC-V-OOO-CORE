/*
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
									 input logic signed[WIDTH:0] value1,value2,
									 input logic [C_WIDTH:0] ALUControl,
									 input logic[ROB:0] rob1,rob2,robInstr,
									 output logic[ROB:0] instrRob,
									 output logic[C_WIDTH:0] instrInfo,
									 output logic busy,selectReq,
									 output logic signed[WIDTH:0] src1,src2); //Leave them as outputs to our RS entry
									 
									 logic value1Ready,value2Ready; //Had we already received the necessary value
									 
									 logic match1,match2; //Match on write result stage then assert 
									 //ready select signals.
									 
									 /*We must indicate the validity of a ROB dependence of an instruction.
									 Done using value ready signal and RS entry busy signal*/
									 
									 logic[ROB:0] src1Rob,src2Rob;
									 
									 
									 /*Combinational logic for comparing instruction write result
									   ROB entry with source operands ROB entries.
									   We add logic for producing a request to the select logic.
									   Refinement occurs here*/
									 always_comb begin
										match1 =  (dataBus.robEntry == src1Rob) & !value1Ready & busy & dataBus.validBroadcast; //Match only possible if value wasn't ready
										match2 = (dataBus.robEntry == src2Rob) & !value2Ready & busy & dataBus.validBroadcast; 
										selectReq = (value1Ready|ready1) & (value2Ready|ready2); 
										/*When both operands ready, we can request the selection logic.
										Oring the ready inputs and value1Ready signals allows for 
										an instruction to be both written to RS and selected in the same 
										stage
										*/
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
											src1 <= value1;
											src2 <= value2;
											src1Rob <= rob1;
											src2Rob <= rob2;
											busy <= 1'b1;
										end
										
										/*If match for tag associated with operand we
										store value and indicate operand readiness*/ 
										if(match1) begin
											src1 <= dataBus.result;
											value1Ready <= 1'b1;
										end
										
										if(match2) begin
											src2 <= dataBus.result;
											value2Ready <= 1'b1;
										end
									end
									 
									
endmodule
									
										
									 
									 
									 
									 
									 