/*
ALU,branchALU and common databus arbiter combined.
ALU and branchALU must provide a request for writing
to CDB(request provided if relevant control info had been passed
to execute stage).

Writing to CDB controlled by CDBArbiter.*/


module functionalUnit #(parameter WIDTH = 31, B_WIDTH = 7, A_WIDTH = 3, ROB = 2, CONTROL = 4)
								(input logic signed[WIDTH:0] bSrc1,bSrc2,
								 input logic[WIDTH:0] targetAddress,predictedPC,nxtPC,
						       input logic [B_WIDTH:0] branchControl,
								 input logic signed[WIDTH:0] src1,src2,
								 input logic [A_WIDTH:0] ALUControl,
								 input logic[ROB:0] ALURob,branchRob,
								 input logic clk,globalReset,clear,validCommit,
								 output logic aluAvailable,branchAvailable,branchDataBusReq,aluDataBusReq,
								 commonDataBus.arbiter dataBus);
								 
								 logic signed[WIDTH:0] result;
								 //logic ALURequest;
								 logic[WIDTH:0] correctAddress,branchResult;
								 logic[1:0] nextState;
								 logic reset,writeBTB,takenBranch; 
								 logic[CONTROL:0] controlPC;
								 assign controlPC = {nextState,writeBTB,takenBranch,reset};
								 
								 branchALU branchUnit(.*);
								 ALU computeUnit(.*);
								 
								 CDBArbiter dataBusArbiter(.*,.fetchAddress(correctAddress),.ALUResult(result));
								 
								 
endmodule