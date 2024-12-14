/*
 Calculation of branch target address for JAL and
 branch instructions.
 
 Allows for early instruction PC jump for JAL instructions
 two cycles after instruction rename stage. 
*/




module branchTargetResolve #(parameter WIDTH = 31)
									 (input logic [WIDTH:0] PC,immExt,
									  input logic isJAL,
									  output logic jump,
									  output logic [WIDTH:0] targetAddress,seqPC);				
					
					always_comb begin
						jump = isJAL;
						targetAddress = PC + immExt;
						seqPC = PC + 32'd1;
					end

endmodule
								
									  