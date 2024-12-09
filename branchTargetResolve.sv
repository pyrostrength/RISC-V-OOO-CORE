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
 
 earlyWrite indicates if we can write to BTB early.
 
 Sequential PC acts as the result for JAL,JALR instructions and as
 default result for branch instructions.
  

*/




module branchTargetResolve #(parameter WIDTH = 31)
									 (input logic [WIDTH:0] PC,immExt,
									  input logic branch,isJAL,redirect,isLUI,isAUIPC,
									  output logic earlyWrite,jump,
									  output logic [WIDTH:0] targetAddress,earlyResult,seqPC);				
					
					always_comb begin
						jump = isJAL;
						earlyWrite = 1'b0;
						targetAddress = PC + immExt;
						earlyResult = PC + immExt;
						seqPC = PC + 32'd1;
						if(branch) begin
							earlyWrite = 1'b0;
						end
						else if(isJAL) begin
							//misdirect = (targetAddress != predictedPC) & redirect;
							earlyWrite = 1'b1;
						end
						else if(isLUI) begin //LUI instructions just use the immediate field
							earlyResult = immExt;
							earlyWrite = 1'b1;
						end
						else if(isAUIPC) begin
							earlyWrite = 1'b1;
						end
					end

endmodule
								
									  