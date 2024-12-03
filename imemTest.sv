/*
VERIFIED.
NO REGISTERED OUTPUTS.
Test module for synchronous instruction
memory. Reads occur synchronously - address
at tsetup before rising clock edge is read for
its corresponding data.

Instruction memory filled with relevant instructions.
Which ones ? I need to write them.

Learn how to prefill instruction memory with relevant data -
reading and writing to file using SystemVerilog etc.
*/ 




module imemTest #(parameter WIDTH = 31, ENTRIES = 255);
					  
					  timeunit 1ns;
					  
					  logic[31:0] instructionPC,address;
					  logic clk;
					  
					  
					  
					  //Clock generator
					  initial begin
						clk = '0; //Begin clock pulse at low level.
						forever #5 clk = ~clk; //Clock period of 5 nanoseconds. Corresponds to a duty period of 5 nanoseconds. 100 Mhz signal
					  end
					  
					  imem Memory(.*,.rAddress(address),.instr(instructionPC));
					  
					  initial begin
							address = 32'd0; #7
							assert (instructionPC === 32'hFFFFFFFF) else $error("Memory doesn't read out appropriate valeu");
							address = 32'd2; #9
							assert (instructionPC === 32'h00000000) else $error("Memory doesn't read out appropriate value on address change");
					  end
endmodule