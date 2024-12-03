/*

Instruction memory implemented as an M10K memory block.

Synchronous reads with next sequential 
instruction PC or predicted target address from
branch target buffer or jump target address from
decoding a jump instruction during instruction decode stage
or corrected address on branch misprediction.

Note: For selecting next fetch address
we give preference for change of instruction
PC on branch mispredict. Next preference is given to
jump target address. Next preference is given
to predicted target address from branch target buffer.
Sequential PC has the lowest priority.

We must provide functionality to fetch from correct PC if
we incorrectly misinterpreted an instruction as a branch instruction
only to find out during decode stage that it isn't.
Thus we must pipeline the next sequential PC to next stage. 


M10K memory blocks are limited to 10240 bits
which limits our address space for 40-bit data
on an M10K memory block to
256 entries(representable using 8-bits on instruction
PC).

For now, we use 32-bit data for instruction data and 
access the instruction memory using the 
lower 8-bits of instruction PC.

Thus given that we don't use full 32 bits of instruction
PC we save space on g-share and BTB by using only the lower
4-bits of instruction PC. We do this also as a test of
accuracy of our branch prediction scheme at small sizes
of branch predictor.

We populate instruction memories' contents using a python
script writing hexadecimal values to a file. Small I-mem
size eases our work and allows us to perform a quantitative
analysis of our branch predictors accuracy.

*/




module imem #(parameter WIDTH = 31,ENTRIES = 255)
				 (input logic[WIDTH:0] rAddress,
				  input logic clk,
				  output logic[WIDTH:0] instr);
				  
				  
				  
				 
				  logic[WIDTH:0] iMem[0:ENTRIES]; // little-endian memory system.
				  initial begin
						$readmemh("/home/voidknight/Downloads/CPU_Q/imeminit.txt",iMem);
				  end
				  //Synchronous read at positive clock edge
				  always_ff @(posedge clk) begin
					 instr <= iMem[rAddress[$clog2(ENTRIES+1) - 1:0]];
				  end 
endmodule