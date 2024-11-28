/*

2 ALM-based memory module.
During instruction rename stage CPU performs
a check through the rename buffer for values associated
with either source register. The buffer is indexed by the
source operand's ROB allocation (an instruction in ROB
writes the destination register, to prevent RAW register is 
tagged by the instruction's ROB). In effect, a check is performed
on whether instruction has passed the write result stage.

With old data behaviour on read during write operations,
if an instruction writes its result in current stage then
we need only bypass that value to rename stage. 

If an instruction had written it's result in previous stage 
but is currently committing then old data behaviour captures the
actual commit value since buffer was written during write
result stage. Thus we need not bypass commit value
to instruction value stage. Nevertheless we must indicate 
correct source operand ROB entry dependence in reservation
station so we bypass the commiting instruction's ROB entry.

We must indicate validity of a data value. Done during write
result stage where we have a valid,robEntry,result combo.
Must indicate invalidity of a result on instruction commit
or on pipeline flush due to branch misprediction.

rob1 and rob2 are the rob entries associated with a source 
operand.

ROBvalue1 and ROBValue2 are 33 bit signals of form {valid,result}
with valid bit indicating relevancy & availability of result read from buffer.

ROBresult is the rob entry of the instruction whose result has just
become available during write result stage.

ROBcommit is ROB entry of committing instruction. 
We must invalidate an entry's result after an instruction
commits as an ensuing unexecuted instruction will use
the same ROB entry. We don't want to read off the wrong
value from the value buffer.

Busy1 and Busy2 act as our read enables on readybuffer


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
								end
									
								always_ff @(posedge clk) begin
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
								
								
									