/* 
	VERIFIED
	Register file with 32 entries holding 32-bit values.
	Register x0 must always holds the value 0.

   Register file implemented as synchronous ALM-based
	memory with read and write on positive clock edge.
	Synchronous RAM has new data behavior
	meaning read and write to the same address results
	in new data on read output. This accounts for case
	in which instruction commits during another's instruction
	decode thus allowing for capturing of instruction value.
	
	What to do with the captured value is decided upon in the next
	stage. If we determined that respective register was busy,
	then we discard the value and observe the value on write result
	stage or on instruction commit. Or we pick the extended
	immediate field if value read from
	register file was never needed to begin with.

	As per RISC_V specification, register x0 should be hardwired to
	register x0. For that we ensure that prior to instruction
	commit any instruction writing to destination register x0 
	writes the value zero,any value read from register x0 is automatically 
	zero and no instruction can mark register x0 as occupied.
	
	Register file has two dedicated read ports and one
	dedicated write port.
	 

*/


module register_file #(parameter D_WIDTH = 31, A_WIDTH = 4)
							(input logic clk,regWrite,
							 input logic[A_WIDTH:0] address1,address2,wraddress,
							 input logic[D_WIDTH:0] wdata,
							 output logic[D_WIDTH:0] regValue1,regValue2);
							 
							 logic[D_WIDTH:0] regFile[D_WIDTH:0];
							 
							 initial begin
								  $readmemb("regFileInit.txt",regFile);
							 end
							 
							 /*Values from ROB are passed out on positive edge so
							 we write on negative edge of the clock*/
							 always @(negedge clk) begin
								if(regWrite) begin
									regFile[wraddress] <= wdata;
								end
							 end
							 
							 always_comb begin
								regValue1 = regFile[address1];
								regValue2 = regFile[address2];
							 end
endmodule
							 
							 