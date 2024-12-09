/*

Determination of source operands 
and source operand dependency for instructions
prior to write to respective reservation station
and reorder buffer. 

RegValue1,RegValue2 are values read 
from the register during previous decode stage.
We provide bypassing on instruction decode stage
to mark register as non-busy and pass on associated value.

ROBValue1 and ROBValue2 are ROB entry dependencies
of source operands

We need not bypass current value and ROB entry of
committing instruction as check on ROB rename buffer
ensures we obtain its value. That way we
eliminate the ROB dependence of source operand
(since what we really needed was the value which
never changes after write result stage.)

However we must check CDB for instructions that
finished executing as their values will be unavailable in 
the ROB rename buffer.

Break down module into two,one for each source
operand.

*/


module instructionValues #(parameter WIDTH = 31, V_WIDTH = 63, I_WIDTH = 14, ROB = 2)
								  (commonDataBus.rename_stage dataBus,
								   input logic[WIDTH:0] operand, //From decode stage
								   input logic[WIDTH + 1:0] ROBValue, //MSBit indicates whether value is valid. Might declare an interface for this
								   input logic [ROB:0] rob,
								   input logic busy, //Is source operands destination registers of busy instructions?
									output logic ready, //Is data values ready?
									output logic signed[WIDTH:0] instrValue); //Source operand to be used
									
									
									always_comb begin
										if(busy) begin
											if(ROBValue[WIDTH+1]) begin
												instrValue = signed '(ROBValue[WIDTH:0]);
												ready = 1'b1;
											end
											else if(dataBus.validBroadcast & (dataBus.robEntry == rob)) begin //Currently writing instruction had value
												instrValue = signed '(dataBus.result);
												ready = 1'b1;
											end
											else begin
												ready = 1'b0;
												instrValue = signed '(32'd0);
											end
										end else begin
											instrValue = signed '(operand);
											ready = 1'b1;
										end
									end
															
endmodule	