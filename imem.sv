module imem #(parameter WIDTH = 31)
				 (input logic[WIDTH:0] address,
				  output logic[WIDTH:0] instr);
				  
				  logic[WIDTH:0] im[0:63]; // little-endian memory system.
				  //Instructions are 32-bit long, the RAM is word-addressable.
				  
				  initial
				   $readmemh ("riscvtest.txt",im);
				  always_comb
					 instr = im[address];
					
endmodule