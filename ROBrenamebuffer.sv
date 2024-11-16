/*ALM-based memory module with 2 read ports and 
2 write ports. During instruction rename stage CPU performs
a check through the rename buffer for values associated
with either source register. The buffer is indexed by the
source operand's ROB allocation (an instruction in ROB
writes the destination register, to prevent RAW register is 
tagged by the instruction's ROB). In effect, a check is performed
on whether instruction has passed the write result stage.

ALM-based memory unit provides for new data behavior in
read-during-write operations. This is important as sometimes
an instruction is writing a result whilst another instruction
is searching for that instruction's result in rename stage.
This also complicates search through for data values during decode stage.
Since an instruction that commits will change value
to 0. 

Thus we must indicate that instruction
has committed lest we shall wait in reservation station
for an instruction that's no longer in pipeline.
We pass on this responsibility by implementing our register
status files and register file to be ALM-based.
Performing combinational logic in this stage will necessitate
a longer clock cycle thus negatively impacting performance.

rob1 and rob2 are the rob entries associated with a source 
operand.

ROBvalue1 and ROBValue2 are 33 bit signals of form {valid,result}
with valid bit indicating relevancy & availability of result read from buffer.

ROBresult is the rob entry of the instruction whose result has just
become available during write result stage.

ROBcommit is ROB entry of committing instruction. We must indicate
that whatever is read from the value table is of zero relevancy
as instruction that wrote to that entry has already committed. For that
the data value is fixed to 0 on the valid/ready buffer.

We implement the buffer as two separate buffers. 
One buffer deals with results of
instructions whilst 
the other indicates availability of results from said instructions.

Remember to update register status table to indicate 
that result either is or isn't dependent on a certain instruction.
This is done through updating the busy buffers.

However this isn't enough. Since we never clear the register status
ROB buffers we retain false dependence information if another instruction
doesn't write to a destination register. 

Yet we must only pass value ROB values if and
only if the busy buffer indicated that there exists an instruction writing 
to the destination register(iff there exists a dependence). A dependence
only exists if busy1 or busy2 are zero. 

Thus busy1 and busy2 form part of the valid bits. Busy1 and Busy2
are read off from the register status table during instruction decode stage.
If an instruction commits during instruction decode stage,
then our timing and implementation allows us to capture the 
removal of the dependence before we pass on the busy1 and busy2
signals to ROBrename buffer in the next clock cycle.

ROB rename buffer buffers the instruction results and and indicates
instruction readiness to commit. We reuse this code for a separate ROB
implementation.

ROB rename buffer is specifically for search through during instruction 
rename. Yet it still monitors CDB for data values like the main ROB implementation.

*/






module ROBrenamebuffer #(parameter ROB = 2, WIDTH = 31)
							  (input logic[ROB:0] rob1,rob2,ROBresult,ROBcommit,
								input logic[WIDTH:0] result,
							   input logic clk,wresult,wcommit,busy1,busy2,
								output logic[WIDTH + 1:0] ROBValue1,ROBValue2);
								
								logic readybuffer[7:0]; //Indexed by ROB entry,data value indicates result availability.
								
								logic[WIDTH:0] valuebuffer[7:0]; // Indexed by ROB entry,data value indicates result availability
								
								logic valid1,valid2;
								
								always_comb begin
									valid1 = readybuffer[rob1] & (!busy1);
									valid2 = readybuffer[rob2] & (!busy2);
									ROBValue1 = {valid1,valuebuffer[rob1]};
									ROBValue2 = {valid2,valuebuffer[rob2]};
								end
								
								always @(negedge clk) begin
									if(wresult) begin
										readybuffer[ROBresult] <= 1'b1;
										valuebuffer[ROBresult] <= result;
									end
									
									if(wcommit) begin
										readybuffer[ROBcommit] <= 1'b0;
									end
								end
								
endmodule
								
								
									