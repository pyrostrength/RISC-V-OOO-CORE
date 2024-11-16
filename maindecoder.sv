/* The main decoder produces memory and register write control signals,
	ALU source operand control signals, jump/branch control signal and ALUOp 
	control signal which control writing to memory/register, the source
	operands to be used by the ALU, whether to branch or jump to a
	different target address, and a control signal to aid the ALU decoder
	in determining the appropriate ALU control signals respectively.
*/




module maindecoder (input logic[3:0] opcode,//Only the first 4-bits of opcode are needed for base implementation
						  output logic[2:0] immSrc,
						  output logic[1:0] resultSrc,aluOp,
						  output logic memWrite,branch,jump,regWrite,rgSrcB);
						  
						  always_comb begin
								{branch,jump,regWrite,memWrite,rgSrcB} = 1'b0;
								aluOp = 2'b11;
								immSrc = 3'b000;
								resultSrc = 2'b00;
								case(opcode)
										4'b0000 : begin //R-type
											aluOp = 2'b00;
											regWrite = 1'b1;
											immSrc = 3'b111;
										end
										4'b0001 : begin //I-type
											aluOp = 2'b00;
											regWrite = 1'b1;
											rgSrcB = 1'b1;
										end
										4'b0010 : begin //S-type
											aluOp = 2'b01;
											rgSrcB = 1'b1;
											memWrite = 1'b1;
											immSrc = 3'b001;
										end	
										4'b0011 : begin //B-type
											aluOp = 2'b01;
											immSrc = 3'b010;
										end
										//B-type
										4'b0100,4'b0110 : begin	//U-type
											immSrc = 3'b011;
											resultSrc = 2'b11;
											branch = 1'b1;
										end
										4'b0101 : begin //JAL-type
											immSrc = 3'b100;
											resultSrc = 2'b10;
											jump = 1'b1;
										end
										4'b0111 : begin //JALR-type
											rgSrcB = 1'b1;
											resultSrc = 2'b11;
											jump = 1'b1;
										end
										4'b1000 : begin //Load-type
											rgSrcB = 1'b1;
											aluOp = 2'b01;
											resultSrc = 2'b01;
										end
										default : 
											resultSrc = 2'b00;
								endcase
							end
endmodule