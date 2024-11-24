/* ALU decoder produces the control signals
	that determine computational operation(add,subtract,etc)
	to be performed by the mainALU.
	
	The,control signal,is ALUControl will be passed under the instruction
	info field to the reservation station. This control info is,however,
	useless for the ROB.
	
	Production of ALU controls signals occurs in parallel 
	with the immediate extend unit but it is expected that the
	main-decoder-ALU-decoder combination lengthens the critical path.
	
	ALUOp distinguishes the type of instruction to be executed and is
	produced by the main decoder.
	
	funct7 and funct3 fields of the instruction  determine
	the integer computational operation to be performed.
*/	


module ALUDecoder (input logic funct7,//We only take a single bit of the funct7 field.
						 input logic[2:0] funct3,
						 input logic[1:0] ALUOp,
						 output logic[3:0] ALUControl);
						 
						 always_comb begin 
								//Default statement is that which produces no request.
								//Pick the largest 4bit number to accomodate for future new instructions.
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