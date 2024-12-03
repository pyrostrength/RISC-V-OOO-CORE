module functionalUnit #(parameter WIDTH = 31, B_WIDTH = 7, A_WIDTH = 3, ROB = 2, CONTROL = 6)
								(input logic signed[WIDTH:0] bSrc1,bSrc2,
								 input logic[WIDTH:0] PC,immExt,predictedPC, 
						       input logic [B_WIDTH:0] branchControl,
								 input logic signed[WIDTH:0] src1,src2,
								 input logic [A_WIDTH:0] ALUControl,
								 input logic[ROB:0] ALURob,branchRob,
								 input logic clk,
								 commonDataBus.arbiter dataBus);
								 
								 logic signed[WIDTH:0] result;
								 logic ALURequest;
								 logic[WIDTH:0] correctAddress,branchResult;
								 logic[1:0] nextState;
								 logic mispredict,misdirect,reset,writeBTB,request,takenBranch; 
								 logic[CONTROL:0] controlPC;
								 assign controlPC = {mispredict,misdirect,nextState,writeBTB,takenBranch,reset};
								 
								 branchALU branchUnit(.*);
								 ALU computeUnit(.*);
								 
								 CDBArbiter dataBusArbiter(.*,.fetchAddress(correctAddress),.ALUResult(result),.branchRequest(request));
								 
								 
endmodule