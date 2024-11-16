/*
Selection arbiter for specific reservation station
entry for execution in respective functional unit
in subsequent cycle. 

Parameter constants allows for reconfigurability of the module.
For control info,adjust the width parameter to match that of 
control signal.

Used for loops and parameter constants to make
module highly configurable for implementing
final stage of instruction selection logic.

Create a subfielded vector for source operands.
Number of subfields correspond to number of reservation
station entries. Add it as input to the module*

Provide safeguard for grant high on multiple
bits by "stopping" loop operation using done
control signal.

*/


module srcMux #(parameter WIDTH = 31, RS = 3)
					(input logic [RS:0][WIDTH:0] sourceOperands,
					 input logic[RS:0] grants,
					 output logic[WIDTH:0] operand1);
					 
					 logic done; 
					 
					 always_comb begin
						operand1 = sourceOperands[0];
						done = 1'b0;
						for(int i = 0; i<=RS ; i++) begin
							if(!done) begin
								if (grants[i]) begin
									operand1 = sourceOperands[i];
									done = 1'b1;
								end
							end
						end
					 end
								
endmodule