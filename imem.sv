/*

Instruction memory implemented as
dual-port synchronous RAM.

Synchronous reads with next sequential 
instruction PC or predicted target address from
branch prediction or jump target address from
decoding a jump instruction during instruction decode stage
or corrected address on branch misprediction.

Priority for change of control flow given
to address change on mispredict/misdirect,JAL instructions,
predictions from BTB and g-share and next sequential PC in
that order. 


*/




module imem #(parameter WIDTH = 31,ENTRIES = 255)
				 (input logic[WIDTH:0] rAddress,
				  input logic clk,
				  output logic[WIDTH:0] instr);
				  
				  
				  
				 
				  logic[WIDTH:0] iMem[ENTRIES:0]; // little-endian memory system.
				  initial begin
						$readmemb("/home/voidknight/Downloads/CPU_Q/imeminit.txt",iMem);
				  end
				  /*Synchronous read at negative clock edge with PC from
				  PCselect logic*/
				  always_ff @(negedge clk) begin
					 instr <= iMem[rAddress[$clog2(ENTRIES+1) - 1:0]];
				  end 
endmodule