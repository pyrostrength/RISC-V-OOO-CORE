/*Queue for holding instructions awaiting execution as well as
wakeup and select logic for selection for execution and registered outputs
that pass selected instruction on positive clock edge*/

module ALURS #(parameter WIDTH = 31, ROB = 2, C_WIDTH = 3, RS = 3)
              (commonDataBus.reservation_station dataBus,
					input logic ready1,ready2,clear,validCommit,clk,execute,globalReset,
					input logic[RS:0] writeRequests, 
					input logic signed[WIDTH:0] value1,value2,
					input logic [C_WIDTH:0] ALUControl,
					input logic[ROB:0] rob1,rob2,robInstr,
					output logic[ROB:0] instrRob,
					output logic[C_WIDTH:0] instrInfo,
					output logic[RS:0] busy,
					output logic signed[WIDTH:0] src1,src2);
					
					logic busy1,busy2,busy3,busy4;
					assign busy = {busy4,busy3,busy2,busy1};
					
					logic selectReq1,selectReq2,selectReq3,selectReq4;
					logic[ROB:0] instrRob1,instrRob2,instrRob3,instrRob4;
					logic[C_WIDTH:0] instrInfo1,instrInfo2,instrInfo3,instrInfo4;
					logic signed[WIDTH:0] src1Instr1,src1Instr2,src1Instr3,src1Instr4;
					logic signed[WIDTH:0] src2Instr1,src2Instr2,src2Instr3,src2Instr4;
					logic[RS:0] grants;
					
					ALURStationEntry entry1(.*,.writeReq(writeRequests[0]),.busy(busy1),.selectReq(selectReq1),
													.instrRob(instrRob1),.instrInfo(instrInfo1),.src1(src1Instr1),.src2(src2Instr1),
													.selected(grants[0]));
					
					ALURStationEntry entry2(.*,.writeReq(writeRequests[1]),.busy(busy2),.selectReq(selectReq2),
													.instrRob(instrRob2),.instrInfo(instrInfo2),.src1(src1Instr2),.src2(src2Instr2),
													.selected(grants[1]));
					
					ALURStationEntry entry3(.*,.writeReq(writeRequests[2]),.busy(busy3),.selectReq(selectReq3),
													.instrRob(instrRob3),.instrInfo(instrInfo3),.src1(src1Instr3),.src2(src2Instr3),
													.selected(grants[2]));
					
					ALURStationEntry entry4(.*,.writeReq(writeRequests[3]),.busy(busy4),.selectReq(selectReq4),
													.instrRob(instrRob4),.instrInfo(instrInfo4),.src1(src1Instr4),.src2(src2Instr4),
													.selected(grants[3]));
					
					
					//ALUSelect logic
					logic[RS:0] selectionRequests;
					assign selectionRequests = {selectReq4,selectReq3,selectReq2,selectReq1};
					
					logic noSelect;
						/*If no instruction selected for execution,provide
						default behavior equal to CPUreset*/
					always_comb begin
						noSelect = 1'b0;
						if(selectionRequests == 4'b0000) begin
							noSelect = 1'b1;
						end
					end
					
					ALUSelect selectLogic(.*,.requests(selectionRequests));
					
					//SrcMux
					logic signed[RS:0][WIDTH:0] operands1,operands2;
					logic signed[WIDTH:0] sourceValue1,sourceValue2; 
					
					logic[RS:0][ROB:0] robs;
					logic[ROB:0] chosenROB;
					
					logic[RS:0][C_WIDTH:0] information;
					logic[C_WIDTH:0] toomanyNames;
					
					assign operands1 = {src1Instr4,src1Instr3,src1Instr2,src1Instr1};
					assign operands2 = {src2Instr4,src2Instr3,src2Instr2,src2Instr1};
					assign robs = {instrRob4,instrRob3,instrRob2,instrRob1};
					assign information = {instrInfo4,instrInfo3,instrInfo2,instrInfo1};
					
					srcMux #(.WIDTH(31)) op1(.*,.sourceOperands(operands1),.operand(sourceValue1));
					srcMux #(.WIDTH(31)) op2(.*,.sourceOperands(operands2),.operand(sourceValue2));
					srcMux #(.WIDTH(ROB)) rob(.*,.sourceOperands(robs),.operand(chosenROB));
					srcMux #(.WIDTH(C_WIDTH)) info(.*,.sourceOperands(information),.operand(toomanyNames));
					
					always_ff @(posedge clk) begin
					//Only pass values if functional unit is available.
						if((clear & validCommit) | globalReset | noSelect) begin
							{src1,src2} <= '0;
							instrInfo <= 4'b1111; //Default case to ensure ALU doesn't recognize pipeline bubble as actual instruction.
							instrRob <= '0;
						end
						else if(execute) begin
							src1 <= sourceValue1;
							src2 <= sourceValue2;
							instrInfo <= toomanyNames;
							instrRob <= chosenROB;
						end
					end
					
endmodule
					