/* Register file with 32 entries holding 32-bit values.
	Register x0 must always holds the value 0.

   Register file implemented as synchronous RAM.
	Read and written to on negative clock edge.
	Displays old data behaviour during read during write behavior
	as new data behavior is accounted for by combinational logic
	in rename stage.

	Implemented as two separate memories each holding the same data.
	We only have dual port RAM memories with one read port and 
	another write port.

	Need not hardwire register x0 to zero. But to the
	programmer's POV I need only ensure that register x0
	appears hardwired to value 0. Register files are
	always written during instruction commit thus prior
	to selecting an instruction for commit, as an extra step,
	we must ensure that any data value passed to destination register
	x0 is zero.
	
	For performance reasons we must ensure that any instruction
	aiming to indicate that register x0 is busy in register
	status table be stymied - the write enable on register status
	tables should be disabled. Thus register x0 always holds the value 0.
	This eliminates the need for combinational logic in register_file 
	implementation.
	
	Register file has two dedicated read ports and one
	dedicated write port.
	
	Memory is written to on negative clock edge if write enable is
	asserted. 
*/


module register_file #(parameter D_WIDTH = 32, A_WIDTH = 4)
							(input logic clk,we,g,
							 input logic[A_WIDTH:0] address1,address2,wraddress,
							 input logic[D_WIDTH:0] wdata,
							 output logic[D_WIDTH:0] regValue1,regValue2);
							 
							 logic[D_WIDTH:0] regFile[0:D_WIDTH];
							 
							 always @(negedge clk) begin
								if(we & g) begin
									regFile[wraddress] <= wdata;
								end
							 end
							 
							 always_comb begin
								regValue1 = regFile[address1];
								regValue2 = regFile[address2];
							 end
endmodule
							 
							 