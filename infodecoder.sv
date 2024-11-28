/* 

	The info-decoder produces control signals for the respective
	functional units to which an instruction is sent to and control
	signals to determine source operands to be used for an instruction.
	
	Some instructions require the use of the immediates instead of register values
	for their operands e.g I-type,JAl-type,JALR-type,S-type,L-type.
	Thus we must extend immediate field on instructions as determined by their instruction type.
	This is done in by the extend unit under the control of immSrc signal.
	
	Control signals to determine which computational operation to be
   performed by ALU(ALUOp), whether to branch/jump, whether to write
	to memory or register, whether to use immediate value as a source
	operand,whether our instruction writes to a destination register
	(to avoid U-type,B-type and S-type instructions from hogging
	 space in register status table).
	
	useImm instructs us to use the immediate value for source operand.
	
	branch informs us whether instruction is actually a branch instruction.
	This will aid early branch recovery where we rollback instruction fetch to PC+4
	if we had mispredicted an instruction as a taken branch.
	
	jump informs us whether instruction was actually a jump instruction.
	This allows to redirect instruction fetch to jump target
	address.
	
	memWrite indicates if instruction writes to memory.
	
	regWrite indicates if instruction writes to register file.
	as well as to register status table. This control signal
	functions as our write enable for the register status table
	and register file. If respective register is x0,then 
	regWrite is disabled as x0 register should always have value
	0.
	
	isLUI,isAUIPC,isJAL are added to handle special cases for PC relative address calculation.
	
	There are 4 intended reservation stations. 
	Reservation station (00) corresponds to ALU, (01) to branch,
	(10) to load/store. 11 to multiply.
	 
*/




module infodecoder (input logic[3:0] opcode,//Only the first 4-bits of opcode are needed for base implementation
						  input logic[4:0] destReg,
						  output logic[2:0] immSrc,
						  output logic[1:0] aluOp,RSstation,
						  output logic memWrite,branch,isJAL,useImm,regWrite,stationRequest,
						  output logic isLUI,isAUIPC,isJALR); //useImm instructs us to use the immediate value for source operand.
						  //isJALR is useful only for effective address calculation during branching stage.
						  
						  always_comb begin
								{branch,memWrite,isLUI,isJAL,isAUIPC,isJALR} = 1'b0;
								stationRequest = 1'b0; //Does instruction need a reservation station.
								aluOp = 2'b11;
								immSrc = 3'b000; //For JALR and I-type instructions.
								RSstation = 2'b00; //Corresponds to ALU.
								regWrite = (destReg != 5'd0); //If DestReg is equal to 0 then regWrite is 0 for all instructions.
								useImm = 1'b1; // By default useImm is high since most instructions use immediate field.
								//Branching instructions shouldn't use the immediate field.
								case(opcode)
										4'b0000 : begin //R-type
											aluOp = 2'b00;
											immSrc = 3'b111;
											useImm = 1'b0;
											stationRequest = 1'b1;
										end
										4'b0001 : begin //I-type
											aluOp = 2'b00;
											stationRequest = 1'b1;
										end
										4'b0010 : begin //S-type
											{aluOp,RSstation} = 2'b10;
											regWrite = 1'b0;
											memWrite = 1'b1;
											immSrc = 3'b001;
											RSstation = 2'b01;
										end	
										4'b0011 : begin //B-type
											aluOp = 2'b01;
											immSrc = 3'b010;
											RSstation = 2'b01;
											regWrite = 1'b0;
											//Branching instructions shouldn't use the immediate field for their source values
											useImm = 1'b0;
											stationRequest = 1'b1;
										end
										4'b0100: begin	//LUI
											immSrc = 3'b011;
											branch = 1'b1;
											RSstation = 2'b11; //to LUI,AUIPC unit
											isLUI = 1'b1;
										end
										4'b0110 : begin	//AUIPC
											immSrc = 3'b011;
											branch = 1'b1;
											RSstation = 2'b11; //to LUI,AUIPC unit
											isAUIPC = 1'b1;
										end
										4'b0101 : begin //JAL-type
											immSrc = 3'b100;
											isJAL = 1'b1;
											RSstation = 2'b01; //to branching unit
										end
										4'b0111 : begin //JALR-type
											isJALR = 1'b1;
											RSstation = 2'b10; //To branching unit.
											stationRequest = 1'b1;
										end
										4'b1000 : //Load-type
											{aluOp,RSstation} = 2'b01;
										
								endcase
							end
endmodule