/* This module decodes instruction to determine relevant
	functional unit control signals to be passed onto
	respective reservation stations. During decode stage we
	determine the respective reservation station to which to send
	instruction operands and info and associated control signals 
	that determine how the respective functional unit should operate.
	These control signals will be passed onto reservation stations
	as instruction info.
	
	The main decoder stage determines the functional unit to which the instruction
	should be assigned and provides a control signal to the ALU decoder
	which determines what operation our ALU should perform.
	
	Of note is that the ALU only performs addition,subtraction,arithmetic and logical
	right and left shifts,xor,and,or operations. And since I separated the branch and load/store unit,
	ALU control signals are only relevant for instructions reserved to the ALU functional unit.
	For said functional unit store the ALU control signals instead of opcode.
	
	I provide memWrite,branch,jump,ReservationSelect as additional signals
	to simplify demux logic in second half of instruction decode stage.
	
	The immediate extender produces immediate values to be used for the instruction operands.
	This is relevant to the vast majority of base instruction set.
	
	writeRegStatus dictates whether we should write to the register status table.
	The only exceptions to writing to the register status table are store and branch
	instructions. Nonetheless, a register occupied for a non-existent instruction
	is a serious performance detriment thus justifying the control signal.

*/







module decodeextend #(parameter WIDTH = 31, I_WIDTH = 24,REG = 4,ROB=2)
							(input logic[WIDTH:0] instruction,
							 output logic[3:0] ALUControl,
							 output logic[WIDTH:0] immExt,
							 output logic[2:0] RSstation,
							 output logic memWrite,branch,isJAL,useImm,regWrite,
							 output logic isJALR,isLUI,isAUIPC,stationRequest);
							 
							 //if memWrite is 0 then instruction writes to register file. Does this case hold?
							 //Yes for I-type,R-type,JAL,JAlR
							
							logic[2:0] immSrc;
							logic[1:0] aluOp;
							
							
							//Produces control signals for respective functional units
							infodecoder maindecoder(.*,.RSstation(RSstation),.opcode(instruction[4:0]),.immSrc(immSrc),.aluOp(aluOp),
															.destReg(instruction[11:7]));
							
							//Produces the 32-bit immediate field for address calculations
							extend extender(.*,.immSrc(immSrc),.imm(instruction[31:8]));
							
							//Produces ALU control signals
							ALUDecoder ALUdecoder(.*,.ALUOp(aluOp),.funct7(instruction[30]),.funct3(instruction[14:12]));

endmodule
							
							
							 