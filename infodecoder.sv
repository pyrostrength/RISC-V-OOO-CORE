/* The info-decoder produces control signals for the respective
	functional units to which an instruction is sent to and control
	signals to determine source operands to be used for an instruction.
	
	Some instructions require the use of the immediates instead of register values
	for their operands e.g I-type,JAl-type,JALR-type,S-type,L-type.
	Thus we must extend immediate field on instructions as determined by their instruction type.
	This is done in a separate module.
	
	We must produce control signals dictating the operation of the ALU.
	
	ALU source operand control signals, jump/branch control signal and ALUOp 
	control signal which control writing to memory/register,whether to branch or jump to a
	different target address, and a control signal to aid the ALU decoder
	in determining the appropriate ALU control signals respectively.
	
	useImm instructs us to use the immediate value for source operand.
	
	branch informs us whether instruction is actually a branch instruction.
	This will aid early branch recovery where we rollback instruction fetch to PC+4.
	
	jump informs us whether instruction was actually a jump instruction.
	This will aid early unconditional branch recovery where we rollback instruction fetch
	to PC+4.
	
	writeRegStatus informs us whethe the instruction actually writes to a destination register.
	
	memWrite indicates if instruction writes to memory.
	
	regWrite indicates if instruction writes to register file. We implement
	this functionality to eliminate combinational logic for determining
	write enable signals for register file during instruction 
	commit.
	
	isLUI,isAUIPC,isJAL are added to handle special cases for PC relative address calculation.
	
	There are 4 reservation stations. 
	Reservation station (00) corresponds to ALU, (01) to load/store,
	(10) to branch and (11) to JAL,AUIPC,LUI.
	
	During 3rd stage we determine if there's an opening. Timing requirements. We must eliminate entry from ROB.
	Determine fullness. And transfer result to 
*/




module infodecoder (input logic[3:0] opcode,//Only the first 4-bits of opcode are needed for base implementation
						  output logic[2:0] immSrc,
						  output logic[1:0] aluOp,RSstation,
						  output logic memWrite,branch,isJAL,useImm,writeRegStatus,regWrite,
						  output logic isLUI,isAUIPC,isJALR); //useImm instructs us to use the immediate value for source operand.
						  //isJALR is useful only for effective address calculation during branching stage.
						  
						  always_comb begin
								{branch,memWrite,isLUI,isJAL,isAUIPC,isJALR} = 1'b0;
								aluOp = 2'b11;
								immSrc = 3'b000; //For JALR and I-type instructions.
								RSstation = 2'b00; //Corresponds to ALU.
								{writeRegStatus,regWrite} = 1'b1;
								useImm = 1'b1; // By default useImm is high since most instructions use immediate field.
								//Branching instructions shouldn't use the immediate field.
								case(opcode)
										4'b0000 : begin //R-type
											aluOp = 2'b00;
											immSrc = 3'b111;
											useImm = 1'b0;
										end
										4'b0001 : begin //I-type
											aluOp = 2'b00;
										end
										4'b0010 : begin //S-type
											{aluOp,RSstation} = 2'b01;
											{writeRegStatus,regWrite} = 1'b0;
											memWrite = 1'b1;
											immSrc = 3'b001;
											RSstation = 2'b01;
										end	
										4'b0011 : begin //B-type
											aluOp = 2'b01;
											immSrc = 3'b010;
											RSstation = 2'b10;
											{writeRegStatus,regWrite} = 1'b0;
											//Branching instructions shouldn't use the immediate field for their source values
											useImm = 1'b0;
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
											RSstation = 2'b10; //to branching unit
										end
										4'b0111 : begin //JALR-type
											isJALR = 1'b1;
											RSstation = 2'b10; //To branching unit.
										end
										4'b1000 : //Load-type
											{aluOp,RSstation} = 2'b01;
								endcase
							end
endmodule