/*

This block of combinational logic determines the data values for source operands 
during the rename stage  of the pipeline. 

An added functionality is to determine the target address for 
AUIPC,LUI,JAL and Branch instructions. This address calculation
is performed in parallel to the rest of the value determination
before writing to reservation stations and ROB.
AUIPC,LUI,JAL have their own reservation stations.

RegValue1,RegValue2 are values specified by registers read during previous decode stage.

ROBValue is the current value being committed 
to a specific destination register(freedReg).
Reads on register status file implemented using synchronous
RAM on cyclone V only provide old data. New data, such as 
instruction's committing value isn't available quickly in register
file til the next cycle. 


In decode stage, CPU perform a search through of ROB contents 
to find values associated with destination register matching source registers.
An instruction may have passed write result stage but remain uncommitted,
thus value is unavailable to unreserved instructions unless
a search through the ROB is conducted. This search through occurs in
decode stage of the pipeline, in a bottom-up fashion since
most recent instructions writing to a destination register
determine value to be used. ROBValue1 and ROBValue2 are respective
values for the source operand 1 and source operand 2 and valid1
and valid2 are control signals indicating the validity of the source
values.

isJAL is a control signal used to determine if first source operand should zero.
This is done to implement the JAL instruction properly. All control flow
instructions are placed under 1 reservation station.

Source operands are assumed to be available.

*/







module instructionValues #(parameter WIDTH = 31, V_WIDTH = 63, I_WIDTH = 14, ROB = 2)
								  (input logic[WIDTH:0] regValue1,regValue2,immExt,ROBCommit,
								   input logic[WIDTH + 1:0] ROBValue1,ROBValue2, //MSBit indicates whether value is valid.
								   input logic [ROB:0] freedRob,rob1,rob2,  //Is commiting instruction the same instruction indicated as "owning" a register?
									input logic branch,useImm,isJAL, //Is current instruction just a branch instruction? Should use immediate?
								   input logic busy1,busy2, //Are registers destination registers of busy instructions?
									output logic ready1,ready2, //Are data values ready?
									output logic[WIDTH:0] instrValue1,instrValue2); //Both source operands to be used
							 
								 //Determining data values and ready signals for source operand 1
								   always_comb begin
										instrValue1 = 32'd0;
										ready1 = 1'b1;
										if(isJAL != 1) begin
										//If instruction isn't JAL whose source operand assumed to be 0
											unique case(busy1)
												1'b0: 
													instrValue1 = regValue1;
												1'b1: begin
													unique case(ROBValue1[WIDTH+1]) //ROB values are what are read off from the ROB contents during rename stage.
														1'b1: 
															instrValue1 = ROBValue1[31:0];	
														1'b0: begin
															if(freedRob == rob1) begin
																instrValue1 = ROBCommit;
															end
															else begin
																ready1 = '0;
																instrValue1 = '0;
															end
														end
													endcase
												end
											endcase
										end
									end
									  
								//For source operand 1, no immediate fields possible
									
								//Determining data values and ready signals for source operand 2	
								 always_comb begin
										instrValue2 = 32'd0;
										ready2 = 1'b1;
										// For source operand 2,occupied by immediate in instructions using immediates.
										if(!branch & useImm) begin //!branch because branch has an immediate but still has 2 source operands.
											instrValue2 = immExt;
										end
										else begin
											unique case(busy1)
												1'b0: begin
													instrValue2 = regValue2;
												end
												1'b1: begin
													unique case(ROBValue2[WIDTH+1])
														1'b1: begin
															instrValue2 = ROBValue2[31:0];
														end
														1'b0: begin
															if(freedRob == rob2) begin
																instrValue2 = ROBCommit;
															end
															else begin
																ready2 = '0;
																instrValue2 = '0;
															end
														end
													endcase
												end
											endcase
										end
								 end
															
endmodule	