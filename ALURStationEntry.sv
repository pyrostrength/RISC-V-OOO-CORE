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

//We got a couple of issues bro!

//Removing the busy signal from ALURSstation entry
//If execute and selected then we can change busy to nil in next clock cycle.
//When do we free RSstation entry?
//On write result stage?

//We introduce a new signal called busyI. When busyI
//ordinary equals busyF

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
									 
									 logic match1,match2; //Match on write result stage then assert 
									 //ready select signals.
									 
									 /*We must indicate the validity of a ROB dependence of an instruction.
									 Done using value ready signal and RS entry busy signal*/
									 
									 logic cdbValid;
									 
									 logic[ROB:0] src1Rob,src2Rob,cdbEntry;
									 
									 logic[WIDTH:0] renameVal1,renameVal2,cdbValue;
									 
									 logic busyI; //Signal to change busyness of entry if selected and we can execute;
									 
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
										busyI = (selected & execute) ? 1'b0 : busy;
										/*Functionality to write instruction to reservation station entry
										and capture broadcast on CDB all in the same cycle*/
										src1 = (match1)  
										
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
											valRdy1 <= ready1;
											valRdy2 <= ready2;
											instrRob <= robInstr;
											instrInfo <= ALUControl;
											renameVal1 <= value1;
											renameVal2 <= value2;
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
											value1Ready <= 1'b1;
										end
										
										if(match2) begin
											value2Ready <= 1'b1;
										end
									end
									 
									
endmodule
									
										
									 
									 
									 
									 
									 