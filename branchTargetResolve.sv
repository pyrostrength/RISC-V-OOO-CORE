/*
 Early branch target resolution functionality installed 
 in instruction rename stage. 
 
 Sum of PC and extended immediate field gives target address
 of branch instructions. If there is a mismatch between 
 actual address and predicted PC then we provide a reset
 signal and mux signal in the form of branchMisdirect
 to choose the next instruction PC. 
 
 For PC select logic we use a priority arbiter that automatically
 gives preference to control signals from instruction rename stage/
 commit stage. 
 
 Thus if a branch misprediction reaches ROB,two possible conflicting
 address changes from instruction rename stage and commit stage
 are resolved appropriately.
 
 We provide mechanisms for allowing instructions not under mispredicted
 branch to continue execution. Perhaps a tracker to indicate when a new
 branch enters execution and thus the instructions not belonging to conditional
 branches. JAL and JALR are usually right unless redirected by conditional branch.
 
 Focus on conditional branch and intervening spots on conditional branches.
 
 Say an instruction is decoded as a branch, we have it's rob entry. We mark it.
 If branch is found to be a dunce, we need to eliminate all instructions following it.
 
 We will(eventually) merge this unit with the uUnit which handles U-type instructions. 
 The result of the uUnit are to be stored in a register. But U-type
 instructions depend on no source of operands thus they need not wait 
 in a reservation station. We need only deal with WAW hazards when it comes
 to U-type instructions which is handled by having a reorder buffer.

 Thus U-type instructions are executed during instruction rename stage and proceed
 immediately to write CDB stage. We therefore add the ability to create a request to 
 CDB arbiter.
 
 If we misdirected jump instruction then we must redirect fetch to correct
 address.
  

*/




module branchTargetResolve #(parameter WIDTH = 31)
									 (input logic signed[WIDTH:0] PC,immExt,predictedPC,
									  input logic branch,isJAL,redirect,
									  output logic misdirect,jump,
									  output logic signed[WIDTH:0] targetAddress);				
					always_comb begin
						jump = isJAL;
						misdirect = 1'b0;
						if(branch) begin
							targetAddress = PC + immExt;
							misdirect = (targetAddress != predictedPC) & redirect;
						end
						else if(isJAL) begin
							targetAddress = PC + immExt;
							misdirect = (targetAddress != predictedPC) & redirect;
						end
						
						//We shall deal with U-type instructions later.
						/*else if(isLUI) begin //LUI instructions just use the immediate field
							validAddress = immExt;
						else if(isAUIPC) begin
							validAddress = PC + immExt;
						end */
					end

endmodule
								
									  