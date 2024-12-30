module cpuSim #(parameter WIDTH = 31,REG = 4, ROB = 2 , RS = 1, A_WIDTH = 3, INDEX = 7,
					BRANCH = 1, ALU = 3, B_WIDTH = 7);
		
		logic clk;
		logic globalReset,validBroadcast,validCommit,full,robReq,rgWr,branchDataBusReq,aluDataBusReq;
		logic aluAvailable,branchAvailable,redirect,busy1,busy2;
		logic[ALU:0] ALURequests,ALUInfo;
		logic[BRANCH:0] branchRequests;
		logic[WIDTH:0] nextPC,result,regDest,valueBroadcast,instr,instrPC,aluSrc1,aluSrc2,immExt;
		logic[WIDTH:0] operand1,operand2,predictedPCF;
		logic[ROB:0] robBroadcast,robAllocation;
		logic[INDEX:0] GHRIndex;
		writeCommit outputBus();
		logic[5:0] cntrlFlow;
		
		RISCV cpu(.*);
		
		timeunit 1ns; timeprecision 100ps;
		
		initial begin
			clk = '0; //Begin clock pulse at low level.
			forever #2.5 clk = ~clk;
		end
		
		initial begin
			globalReset = 1'b1; #3 //Don't check for the signal at the same time instant as you pulse it out.
			globalReset = 1'b0 ; assert (nextPC == '0) else $display(nextPC);
		end
endmodule