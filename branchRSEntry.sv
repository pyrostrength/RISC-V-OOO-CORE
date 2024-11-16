/*Reservation station entry for the branching unit.

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

commonDataBus.reservation_station databus bundles up the result during instruction
write result,the ROB entry associated with the instruction and the valid
broadcast signal.

validAddress provides sequential address for JAL,JALR instructions
or target address for conditional jumps in B-type instructions.

predictedPC is useful for determining jump predictions.


 
*/
module branchRSEntry #(parameter WIDTH = 31, ROB = 2, C_WIDTH = 3)
									(commonDataBus.reservation_station dataBus,
									 input logic ready1,ready2,clear,writeReq,clk,
									 input logic signed[WIDTH:0] value1,value2,
									 input logic[WIDTH:0] validAddress,predictedPC,
									 input logic[C_WIDTH:0] branchControl,
									 input logic[ROB:0] rob1,rob2,robInstr,
									 output logic busy,selectReq,
									 output logic[ROB:0] instrRob,
									 output logic[C_WIDTH:0] instrInfo,
									 output logic signed[WIDTH:0] src1,src2,
									 output logic[WIDTH:0] predictedTarget,storedAddress);
									 
									 //Internal variables that are stored.
									 //Must be cleared when clear signal is sent.
									 logic value1Latched,value2Latched,disable1,disable2; //Had we already received the necessary value
									 
									 logic match1,match2,readySelect1,readySelect2; //Match on write result stage then assert 
									 //ready select signals.
									 
									 logic[ROB:0] src1Rob,src2Rob; //ROB values associated with the source operands.
									 
									 
									 initial begin
										{readySelect1,readySelect2,selectReq,busy,value1Latched,value2Latched} = 1'b0;
										{disable1,disable2} = 1'b0;
									 end
									 
									 //Modeling passing on enable value
									 always_ff @(posedge clk) begin
										disable1 <= value1Latched; //Flip flop to store disable value. We use flip flops output as enable.
										disable2 <= value2Latched;
									 end
									 
									 //Stored internal variables
									 
									 //Combinational logic for comparing instruction write result
									 //ROB entry with source operands ROB entries.
									 //We add logic for producing a request to the select logic.
									 always_comb begin
										match1 =  (dataBus.robEntry == src1Rob);
										match2 = (dataBus.robEntry == src2Rob);
										selectReq = readySelect1 & readySelect2;
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
											src1Rob <= rob1;
											src2Rob <= rob2;
											instrInfo <= branchControl;
											instrRob <= robInstr;
											predictedTarget <= predictedPC;
											storedAddress <= validAddress;
										end
										
										//If we have a broadcast on CDB and we have a valid match for a busy entry.
										else if(dataBus.validBroadcast) begin //Have a broadcast on CDB
											if(!disable1 & match1 & !clk) begin //Restrict to when clock is low,entry is actually busy //Problem
												src1 <= dataBus.result;
												value1Latched <= 1'b1;
												readySelect1 <= 1'b1;
											end
											if(!disable2 & match2) begin
												src2 <= dataBus.result;
												value2Latched <= 1'b1;
												readySelect2 <= 1'b1;
											end
										end	
									end
endmodule