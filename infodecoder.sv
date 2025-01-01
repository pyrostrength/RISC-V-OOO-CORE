/* 

	The info-decoder produces control signals 
	for function execution and for determination of
	source operands to be used for an instruction.
	(either immExt,instruction pc,or register values).
	
	branch refers to conditional control flow instruction
	whilst jump refers to unconditional control flow
	instructions.
	
	memWrite indicates if instruction writes to memory
	and regWrite whether it writes to register file.
	These signals act as our write enable on
	register file and memory.
	
	There are currently 2 reservation stations,
	four intended. Current include ALU RS and branch RS
	for handling integer computational instructions
	and conditional/unconditional control flow instructions.
	In future will add reservation stations for loads/stores
	and for multiplier unit.
	 
*/




module infodecoder (input logic[3:0] opcode,
						  input logic[4:0] destReg,
						  output logic[2:0] immSrc,
						  output logic[1:0] aluOp,RSstation,
						  output logic memWrite,branch,isJAL,useImm,regWrite,stationRequest,
						  output logic isJALR,robWrite); //useImm means immediate value for source operand.
						  
						  always_comb begin
								{branch,memWrite,isJAL,isJALR} = 1'b0;
								stationRequest = 1'b0; //Does instruction need a reservation station.
								aluOp = 2'b11;
								immSrc = 3'b000; //For JALR and I-type instructions.
								RSstation = 2'b00; //Corresponds to ALU.
								regWrite = (destReg != 5'd0); //If DestReg is equal to 0 then regWrite is 0 for all instructions.
								useImm = 1'b1;
								robWrite = 1'b1; // By default useImm is high since most instructions use immediate field.
								//Branching instructions shouldn't use the immediate field.
								case(opcode)
										4'b0001 : begin //R-type
											aluOp = 2'b00;
											immSrc = 3'b111;
											useImm = 1'b0;
											stationRequest = 1'b1;
										end
										4'b0010 : begin //I-type
											aluOp = 2'b00;
											stationRequest = 1'b1;
										end
	
										4'b0100 : begin //B-type
											aluOp = 2'b01;
											immSrc = 3'b010;
											RSstation = 2'b01;
											regWrite = 1'b0;
											//Branching instructions shouldn't use the immediate field for their source values
											useImm = 1'b0;
											stationRequest = 1'b1;
											branch = 1'b1;
										end
										4'b0110 : begin //JAL-type
											immSrc = 3'b100;
											isJAL = 1'b1;
											RSstation = 2'b01; //to branching unit
										end
										
										
										4'b1000 : begin //JALR-type
											isJALR = 1'b1;
											RSstation = 2'b01; //To branching unit.
											stationRequest = 1'b1;
										end
										
										default: begin
											stationRequest = 1'b0;
											RSstation = 2'b11;
											robWrite = 1'b0;
										end		
								endcase
							end
endmodule

/*For future expansion of the cpu*/
/*4'b0011 : begin //S-type
											{aluOp,RSstation} = 2'b10;
											regWrite = 1'b0;
											memWrite = 1'b1;
											immSrc = 3'b001;
											RSstation = 2'b11;
											robWrite = 1'b0;
										end
											
										4'b0101: begin	//LUI
											immSrc = 3'b011;
											branch = 1'b1;
											RSstation = 2'b11; //to LUI,AUIPC unit
											isLUI = 1'b1;
										end
										4'b0111 : begin	//AUIPC
											immSrc = 3'b011;
											branch = 1'b1;
											RSstation = 2'b11; //to LUI,AUIPC unit
											isAUIPC = 1'b1;
										end

										4'b1001 : begin//Load-type
											{aluOp,RSstation} = 2'b01;
											robWrite = 1'b0;
										end */