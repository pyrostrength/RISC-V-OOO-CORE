/*Reservation station entry for the ALU.

Each reservation station entry consists of pertinent instruction info
related to its execution, the ROB entry to which the instruction has
been assigned(ROB entry is required by end of instruction decode),the
instruction's destination(register or memory address),values for the
source operand if available during write to reservation station
entry or LATCHED in during instruction write result stage.

We latch in instruction value on match between write results
ROB entry and source entry stored in RS entry. This requires 2 comparators
for every single entry.

Input values per RSstation entry vary depending on assignment to functional unit.
branchALU's reservation station entries are different from
ALU's.

commonDataBus.arbiter databus bundles up the result during instruction
write result,the ROB entry associated with the instruction and the valid
broadcast signal.


 
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
									 
									 logic value1Latched,value2Latched; //Had we already received the necessary value
									 
									 logic match1,match2,readySelect1,readySelect2,disable1,disable2; //Match on write result stage then assert 
									 //ready select signals.
									 
									 /*We must indicate the validity of a ROB dependence of an instruction.
									 //The valid bit is the ready signal of instruction that's only 
									 //written when write request and clock are high. We add
									 */this control signal to src1Rob.
									 
									 logic[ROB + 1:0] src1Rob,src2Rob;
									 
									 
									 initial begin
										{readySelect1,readySelect2,selectReq,busy,disable1,disable2} = 1'b0;
										{value1Latched,value2Latched} = 1'b0;
									 end
									 
									 /*Combinational logic for comparing instruction write result
									   ROB entry with source operands ROB entries.
									   We add logic for producing a request to the select logic.
									   Refinement occurs here*/
									 always_comb begin
										match1 =  (dataBus.robEntry == src1Rob[2:0]) & !src1Rob[3] & busy; //Busy signal indicates validity of rob match
										match2 = (dataBus.robEntry == src2Rob[2:0]) & !src2Rob[3] & busy; //Busy signal indicates validity of rob match
										selectReq = readySelect1 & readySelect2;
									 end
									 
										
									 //Modeling passing on enable value
									 always_ff @(posedge clk) begin
										disable1 <= value1Latched;
										disable2 <= value2Latched;
									 end
									 
									 
										
									 always_latch begin
										//Clearing reservation station entry when clear is asserted and clock is high
										if(clear & clk) begin
											{src1Rob,src2Rob} <= '0;
											instrInfo <= '0;
											instrRob <= '0;
											{value1Latched,value2Latched,readySelect1,readySelect2,busy} <= 0;
										end
										
										//Writing to reservation station entry when clock is high and writeReq is asserted.
										else if(writeReq & clk) begin
											src1 <= value1;
											src2 <= value2;
											{value1Latched,readySelect1} <= ready1;
											{value2Latched,readySelect2} <= ready2;
											busy <= 1'b1; //Indicate that instruction field is busy
											src1Rob <= {ready1,rob1};
											src2Rob <= {ready2,rob2};
											instrInfo <= ALUControl;
											instrRob <= robInstr;
										end
										
										//If we have a broadcast on CDB and we have a valid match for a busy entry.
										else if(dataBus.validBroadcast) begin //Have a broadcast on CDB
											if(!disable1 & match1 & !clk) begin //Restrict to when clock is low,entry is actually busy //Problem
												src1 <= dataBus.result;
												value1Latched <= 1'b1;
												readySelect1 <= 1'b1;
											end
											if(!value2Latched & match2) begin
												src2 <= dataBus.result;
												value2Latched <= 1'b1;
												readySelect2 <= 1'b1;
											end
										end	
									end
									
endmodule
									
										
									 
									 
									 
									 
									 