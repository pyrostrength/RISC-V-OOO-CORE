/* ALU decoder produces the control signals for the mainALU and
	branchALU thus determining main operation to be performed by the ALU.
	
	The,control signal,is ALUControl will be passed along with the instruction
	info field to the reservation station. This control info is,however,
	useless for the ROB.
	
	Operation occurs in parallel with the immediate extend unit. Expectations
	is that this unit takes slightly longer than extend unit.
   it determines the respective operation to be performed by the ALU.
	ALUOp distinguishes the operations to be performed based on the instruction 
	format , i.e for branch instructions always subtract the two source operands 
	and produce the necessary flag variables.
	It uses the funct7 and funct3 fields of the instruction to determine
	the integer computational operation to be performed, whether the integers
	are register values or register value & immediate value.
*/	


module ALUDecoder (input logic funct7,
						 input logic[2:0] funct3,
						 input logic[1:0] ALUOp,
						 output logic[3:0] ALUControl);
						 
						 always_comb begin 
								//Default statement is that which produces no request.
								//Pick the largest 4bit number to allow expansion space.
								ALUControl = 4'b1111;
								case(ALUOp)
									2'b00: 
										case(funct7)
											1'b1:
												case(funct3)
													3'b000 : ALUControl = 4'b1000; //Subtraction
													3'b111 : ALUControl = 4'b1001; //Arithmetic right shift
													default : ALUControl = 4'b0001; //Logical and in case of incorrect funct3 field.
												endcase
											1'b0:
												case(funct3)
													3'b000: ALUControl = 4'b0000;  // Addition
													3'b001: ALUControl = 4'b0001;  // And
													3'b010: ALUControl = 4'b0010;  // Or
													3'b011: ALUControl = 4'b0011;  // Xor
													3'b100: ALUControl = 4'b0100;  // Slt
													3'b101: ALUControl = 4'b0101;  // Slt[unsigned]
													3'b110: ALUControl = 4'b0110;  // Sll
													3'b111: ALUControl = 4'b0111;  // Srl
												endcase
										endcase
									default: ALUControl = 4'b1111; 
								endcase
						end
endmodule