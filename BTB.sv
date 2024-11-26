/*

  Branch Target Buffer predicts instruction fetch PC
  for next cycle provided current instruction PC matches
  a previous instruction found to be a taken branch.
  
  Implemented as 2 direct mapped cache indexed using
  the lower 4 bits of the instruction PC. We use the next
  4 bits as a tag for the identification of a specific
  instruction PC. We need to start making predictions quickly.
  
  We introduce a valid buffer to indicate validity of each
  BTB entry - whether it's an instruction PC belonging
  to branch previously taken. If entry is not taken we
  eliminate from BTB by zeroing out it's index on BTB.
  
  During instruction fetch we check BTB for predicted
  fetch PC associated with current instruction PC. If a hit
  occurs we opt to change next instruction PC to value obtained 
  from BTB.
  
  We also add unconditional branches to BTB with their associated
  jump target address. This doesn't avoid comparatively lower
  prediction accuracy in case of function returns but it will do
  for now. 
  
  takenBranch is a signal from branchALU that informs us whether 
  an instruction was a taken branch or jump instruction.
  
  Form instruction fetch unit completely in a separate module.
  
  do it in main submodule.
  
*/


module BTB #(parameter WIDTH = 31,
                       B_WIDTH = 7,
							  INDEX = 3)
			  (input logic[WIDTH:0] resolvedTarget,
			   input logic[B_WIDTH:0] PC,oldPC,
			   input logic writeBTB,clk,takenBranch,
				output logic validRead,
			   output logic[WIDTH:0] targetAddress);
				
				logic[WIDTH + INDEX + 1:0] targetBuffer[0:15]; //since we access using 4 lower bits we only have 16 entries.
				logic validBuffer[0:15]; 
				
				logic valid; //Did we get a BTB hit for our instruction PC?
				logic[WIDTH + INDEX + 1:0] address; // 
				
				always_ff @(posedge clk) begin
					/*Sequential write to BTB if and only if 
					old instruction was a taken branch 
					or to correct in case previously taken
					branch no longer a taken branch*/
					if(writeBTB) begin
						targetBuffer[oldPC[INDEX:0]] <= {oldPC[B_WIDTH:INDEX+1],resolvedTarget};
						validBuffer[oldPC[INDEX:0]] <= takenBranch;
					end
					
					/*Read off BTB cache to check for next fetch
					instruction PC associated with a taken branch
					(conditional and unconditional branches) */
					address <= targetBuffer[PC[INDEX:0]]; //validRead determines what we do with accessed value from BTB cache.
					valid <= validBuffer[PC[INDEX:0]]; //Was instruction a taken branch?
				end
				
				logic btbHit;
				
				assign targetAddress = address[WIDTH:0];
				
				/*Combinational logic to check for cache hit*/
				always_comb begin
					btbHit = (address[WIDTH + INDEX + 1 : WIDTH + 1] == PC[B_WIDTH : INDEX + 1]) & valid; //do we have a hit on BTB cache
					if(btbHit) begin
						validRead = 1'b1;
					end
					else begin
						validRead = 1'b0;
					end
				end
						  
endmodule