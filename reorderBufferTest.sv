/*reorder buffer and reorder rename buffer combined test module*/

module reorderBufferTest #(parameter WIDTH = 31, CONTROL = 6, INDEX = 7, ROB = 2);
								   commonDataBus dataBus();
							      logic[ROB:0] rob1,rob2,robAllocation,commitRob;
							      logic[WIDTH:0] earlyResult;
							      writeCommit inputBus();
								   writeCommit outputBus();
								   logic[WIDTH:0] ROBValue1,ROBValue2;
								   logic valid1,valid2;
							      logic clk,isJAL;
									logic robWrite,freeze,full,globalReset;
									
									
									reorderBuffer rob(.*);
									
									timeunit 1ns; timeprecision 100ps;
								
									initial begin
										clk = '0; //Begin clock pulse at low level.
										forever #2.5 clk = ~clk; //Clock period of 5 nanoseconds. Corresponds to a duty period of 5 nanoseconds. 100 Mhz signal
									end
									
									initial begin
										dataBus.result = '0; dataBus.robEntry = '0; dataBus.validBroadcast = '0; dataBus.isControl = '0; dataBus.pcControl = '0;
										dataBus.targetAddress = '0;
										
										inputBus.commitInfo = '0; inputBus.destination = '0; inputBus.PHTIndex = '0; inputBus.regStatus = '0;
										inputBus.instrPC = '0;
										
										robWrite = '0; freeze = '0; globalReset = 1'b1; #5
										
										globalReset = '0;
										
										robWrite = 1'b1; 
									
									end
									
									
endmodule