/*Branch Target Buffer predicts instruction fetch PC
  for next cycle provided current instruction PC is
  predicted to be a taken branch.
  
  If conditional branch is yet to be predicted as taken,we abstain from
  updating the BTB as BTB only contains predicted taken branches.
  
  We introduce a valid buffer to indicate validity of each
  BTB entry - whether it's an instruction PC belonging
  to a predicted taken branch. If entry is predicted
  not taken we must indicate it's invalidity.
  
  Array addressing is by the lower 8-bits of the instruction. Which
  provides for 256 unique entries on BTB. On BTB update, if a 
  hit occurs we replace the PC's predicted target adress with
  a new target address only if instruction PC belonged to a taken
  branch. Unconditional branches are also added to PC, though 
  prediction accuracy is dramatically lower for function returns,which
  can occur at multiple sites throughout a program.
  
  BTB is read and written sequentially on negative clock edge.
  Simultaneous read and write policy determined by Quartus rules on
  block RAM.
*/


module BTB #(parameter WIDTH = 31,
                       B_WIDTH = 7)
			  (input logic[WIDTH:0] resolvedTarget,
			   input logic[B_WIDTH:0] PC,oldPC,
			   input logic wasTakenBranch,clk,branch,
				output logic validRead,
			   output logic[WIDTH:0] targetAddress);
				
				logic[WIDTH:0] targetBuffer[0:255];
				logic validBuffer[0:255];
				
				always_ff @(posedge clk) begin
					//Sequential write to BTB if and only if 
					//old instruction was a predicted taken branch.
					//Double function : to update with correct
					//address and to add new prediction
					if(wasTakenBranch) begin
						targetBuffer[oldPC] <= resolvedTarget;
					end
					
					//Regardless of whether branch was taken or not we always write
					//to valid buffer. This only occurs for branches thus our write
					//enable is a branch signal.
					if(branch) begin
						validBuffer[oldPC] <= wasTakenBranch;
					end
				//Sequential read
					targetAddress <= targetBuffer[PC];
					validRead <= validBuffer[PC];
				end
						  
endmodule