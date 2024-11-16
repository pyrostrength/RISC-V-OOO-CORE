/*

Incomplete

Functional unit for JAL,AUIPC and LUI instructions.
This functional unit sum an immediate field and instruction
PC for their result. This operation can be conducted in parallel
during instruction rename stage. As only one instruction occupies
rename stage we calculate the result for JAL,LUI & AUIPC
and on next clock cycle write result.

For JAL instructions what's written to rd is (PC+4) ,the
next sequential address. For AUIPC instructions,what's 
written is PC + immExt, For LUI instructions,what's written is
immExt.

For the specific case of JAL instructions, on writeROB stage,we are 
fetching from the correct address. Thus we must reroute to instruction
fetch stage where we determine next sequential address. This imposes strict
setup times as our decision for next fetch must be made before a time 
Tclock - tsetup(FF).

Our operations should only have an effect if we register them as
JAL,LUI,AUIPC. Yet when we write result we must broadcast on CDB with
ROB entry.

Need to coordinate this unit with instruction change PC.
And with write result arbitration.

*/

module JUUnit #(parameter WIDTH = 31)
						 (input logic[WIDTH:0] signed PC,immExt
						  input logic isJAL,isLUI,isAUIPC,
						  output logic[WIDTH:0] signed targetaddress,result);
						  
						  logic[3:0] control;
						  assign control = {isJAL,isAUIPC,isLUI};
						  assign signed sequentialPC = PC + 4;
						  
						  always_comb begin
						  targetaddress = 32'd0; //Default assumption.
						  //We must render this default assumption useless by just not choosing it for JAL instruction or AUIPC or LUI.
								unique case(control)
									3'b100: begin //JAL instruction.
										targetaddress =  PC + immExt;
										result = sequentialPC;
									end
									3'b010: begin //AUIPC instruction
										result = immExt + PC;
									end
									3'b001: begin //LUI instruction
										result = immExt;
									end
									default: begin
										result = immExt; //default case where none of this true. Doens't matter however since we just wouldn't write.
									end
								endcase
						  end
endmodule
						  
						  
									
						  
						  