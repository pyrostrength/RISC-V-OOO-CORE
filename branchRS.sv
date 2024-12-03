/*Branch reservation station*/





module branchRS #(parameter WIDTH = 31, ROB = 2, C_WIDTH = 7, RS = 1)
					  (commonDataBus.reservation_station dataBus,
						input logic ready1,ready2,clear,clk,execute,
						input logic[RS:0] writeRequests, 
						input logic signed[WIDTH:0] value1,value2,
						input logic[WIDTH:0] predictedPC,address,
						input logic [C_WIDTH:0] branchControl,
						input logic[ROB:0] rob1,rob2,robInstr,
						output logic[ROB:0] instrRob,
						output logic[C_WIDTH:0] instrInfo,
						output logic[RS:0] busy,
						output logic signed[WIDTH:0] src1,src2,
						output logic[WIDTH:0] predictedAddress,targetAddress);
					
						//We include BranchRsSelect in this module to select for instructions
						logic busy1,busy2;
						assign busy = {busy2,busy1};
						logic selectReq1,selectReq2;
						logic[ROB:0] instrRob1,instrRob2;
						logic[C_WIDTH:0] instrInfo1,instrInfo2;
						logic signed[WIDTH:0] src1Instr1,src1Instr2;
						logic signed[WIDTH:0] src2Instr1,src2Instr2;
						logic[WIDTH:0] prediction1,prediction2;
						logic[WIDTH:0] target1,target2;
						logic[RS:0] grants;
						branchRSEntry entry1(.*,.writeReq(writeRequests[0]),.busy(busy1),.selectReq(selectReq1),
														.instrRob(instrRob1),.instrInfo(instrInfo1),.src1(src1Instr1),.src2(src2Instr1),
														.predictedAddress(prediction1),.targetAddress(target1),
														.selected(grants[0]));
						branchRSEntry entry2(.*,.writeReq(writeRequests[1]),.busy(busy2),.selectReq(selectReq2),
														.instrRob(instrRob2),.instrInfo(instrInfo2),.src1(src1Instr2),.src2(src2Instr2),
														.predictedAddress(prediction2),.targetAddress(target2),
														.selected(grants[1]));
						
						//branchSelect logic
						logic[RS:0] selectionRequests;
						assign selectionRequests = {selectReq2,selectReq1};
						
						branchSelect selectLogic(.*,.requests(selectionRequests));
						
						//SrcMux
						logic signed[RS:0][WIDTH:0] operands1,operands2,redirection,fetchAddr;
						logic signed[WIDTH:0] sourceValue1,sourceValue2; //Intermediate value for pipelining.
						
						logic[RS:0][ROB:0] robs;
						logic[ROB:0] chosenROB;
						
						logic[RS:0][C_WIDTH:0] information;
						logic[C_WIDTH:0] toomanyNames;
						
						logic[WIDTH:0] btbPrediction,actualAddress;
						
						assign operands1 = {src1Instr2,src1Instr1};
						assign operands2 = {src2Instr2,src2Instr1};
						assign robs = {instrRob2,instrRob1};
						assign information = {instrInfo2,instrInfo1};
						assign redirection = {prediction2,prediction1};
						assign fetchAddr = {target1,target2};
						
						srcMux #(.WIDTH(31),.RS(RS)) op1(.*,.sourceOperands(operands1),.operand(sourceValue1));
						srcMux #(.WIDTH(31),.RS(RS)) op2(.*,.sourceOperands(operands2),.operand(sourceValue2));
						srcMux #(.WIDTH(ROB),.RS(RS)) rob(.*,.sourceOperands(robs),.operand(chosenROB));
						srcMux #(.WIDTH(C_WIDTH),.RS(RS)) info(.*,.sourceOperands(information),.operand(toomanyNames));
						srcMux #(.WIDTH(31),.RS(RS)) predictor(.*,.sourceOperands(redirection),.operand(btbPrediction));
						srcMux #(.WIDTH(31),.RS(RS)) addressor(.*,.sourceOperands(fetchAddr),.operand(actualAddress));
						
						always_ff @(posedge clk) begin
							if(execute) begin
								src1 <= sourceValue1;
								src2 <= sourceValue2;
								instrInfo <= toomanyNames;
								instrRob <= chosenROB;
								predictedAddress <= btbPrediction;
								targetAddress <= actualAddress;
							end
						end
					
endmodule