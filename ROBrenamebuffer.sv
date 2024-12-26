/*

During instruction rename stage CPU performs
a check through the rename buffer for values associated
with either source register. The buffer is indexed by the
source operand's ROB allocation. In effect, a check is performed
on whether instruction has passed the write result stage.

ROBrenamebuffer monitors the CDB for data values associated
with particular ROB entries. During instruction commit,these
ROB entries are cleared. An instruction currently
searching through ROB will still obtain the necessary values
from the ROBrenamebuffer as allows synchronous RAM
implementation with old data behavior allows capturing
of this data value.Nevertheless we must indicate 
correct instruction dependence in reservation
station so we take into account currently committing instruction. 


rob1 and rob2 are the rob entries associated with a source 
operand.

ROBvalue1 and ROBValue2 are 33 bit signals 
of form {valid,result} indicating result availability.


ROBcommit is ROB entry of committing instruction. 
We must invalidate an entry's result 
after instruction commits and current instruction,if it needs to,
has already retrieved the necessary value.  


*/






module ROBrenamebuffer #(parameter ROB = 2, WIDTH = 31)
							  (commonDataBus.reorder_buffer dataBus,
								input logic[ROB:0] rob1,rob2,ROBcommit,
							   input logic clk,wcommit,
								output logic[WIDTH:0] ROBValue1,ROBValue2,
								output logic valid1,valid2);
								
								logic readybuffer[7:0]; //Indexed by ROB entry,data value indicates result availability.
								
								logic[WIDTH:0] valuebuffer1[7:0]; // Indexed by ROB entry,data value indicates result availability
								logic[WIDTH:0] valuebuffer2[7:0];
								
								initial begin
									$readmemb("valueInit.txt",valuebuffer1);
									$readmemb("valueInit.txt",valuebuffer2);
									$readmemb("readyInit.txt",readybuffer);
								end
								
								
								logic[WIDTH:0] value1,value2;
								logic ready1,ready2;
								
								always_ff @(negedge clk) begin
									if(dataBus.validBroadcast) begin
										readybuffer[dataBus.robEntry] <= dataBus.validBroadcast;
										valuebuffer1[dataBus.robEntry] <= dataBus.result;
										valuebuffer2[dataBus.robEntry] <= dataBus.result;
									end
									
									if(wcommit) begin
										readybuffer[ROBcommit] <= 1'b0;
									end
									
								/*Values will be setup by negative edge of clock*/
									value1 <= valuebuffer1[rob1];
									value2 <= valuebuffer2[rob2];
									ready1 <= readybuffer[rob1];
									ready2 <= readybuffer[rob2];
								end
								
								
								
								always_comb begin
								//Bypassing to account for old value behaviour
									valid1 = ready1;
									valid2 = ready2;
									ROBValue1 = value1;
									ROBValue2 = value2;
									if((rob1 == dataBus.robEntry) & dataBus.validBroadcast) begin
										valid1 = 1'b1;
										ROBValue1 = dataBus.result;
									end
									if((rob2 == dataBus.robEntry) & dataBus.validBroadcast) begin
										valid2 = 1'b1;
										ROBValue2 = dataBus.result;
									end
								end
								
endmodule
								
								
									