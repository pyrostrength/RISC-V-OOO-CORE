/*reorder buffer and reorder rename buffer combined test module*/

module reorderBufferTest #(parameter WIDTH = 31, CONTROL = 6, INDEX = 7, ROB = 2);
								   commonDataBus.reorder_buffer dataBus;
							      logic[ROB:0] rob1,rob2,robAllocation,commitRob;
							      logic[WIDTH:0] earlyResult;
							      writeCommit.writeROB inputBus;
								   writeCommit.commitROB outputBus;
								   logic[WIDTH:0] ROBValue1,ROBValue2;
								   logic valid1,valid2;
							      logic clk,isJAL;
									logic robWrite,freeze,full;
									
									
									reorderBuffer rob(.*);
									
									timeunit 1ns; timeprecision 100ps;
								
									initial begin
										clk = '0; //Begin clock pulse at low level.
										forever #2.5 clk = ~clk; //Clock period of 5 nanoseconds. Corresponds to a duty period of 5 nanoseconds. 100 Mhz signal
									end
									
									initial begin
										
									end
									
									
endmodule