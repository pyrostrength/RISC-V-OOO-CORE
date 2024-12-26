/*
General multiplexer for passing on selected
instructions info/source operands/robEntry for instruction
execution.

Parameter constants allows for generalizability of the module
for any reservation station.
Simply adjust value of parameter WIDTH and RS
For control info,adjust the width parameter to match that of 
control signal.

Input grants acts as our selection signal whilst number
of subfields in input sourceOperands depends on number
of reservation station entries(4 for ALU,2 for branch).

*/


module srcMux #(parameter WIDTH = 31, RS = 3)
					(input logic [RS:0][WIDTH:0] sourceOperands,
					 input logic[RS:0] grants, 
					 output logic[WIDTH:0] operand);
					 
					 logic done; 
					 
					 always_comb begin
						operand = sourceOperands[0];
						done = 1'b0;
						for(int i = 0; i<=RS ; i++) begin
							if(!done) begin
								if (grants[i]) begin
									operand = sourceOperands[i];
									done = 1'b1;
								end
							end
						end
					 end
								
endmodule