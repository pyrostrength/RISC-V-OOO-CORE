/*
 Early unconditional jump for JAL instructions
 in instruction rename stage. 
 
 Functionality for handling LUI,AUIPC instructions will
 be extended later.
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
								
									  