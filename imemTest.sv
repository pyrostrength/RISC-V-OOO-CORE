/*
Test module for synchronous instruction
memory. Reads occur synchronously - address
at tsetup before rising clock edge is read for
its corresponding data.

Instruction memory filled with relevant instructions.
Which ones ? I need to write them.

Learn how to prefill instruction memory with relevant data -
reading and writing to file using SystemVerilog etc.
*/ 




module iMemTest #(parameter WIDTH = 31, ENTRIES = 255);
					  
					  timeunit 1ns;
					  
					  logic[31:0] instructionPC,address;
					  logic clk;
					  
					  
					  
					  //Clock generator
					  initial begin
						clk <= '0;
						forever #5 clk = ~clk;
					  end
					  
					  imem Memory(.*,.rAddress(address),.instr(instructionPC));
					  
					  initial begin
							address = 32'd0;
					  end
endmodule