module cpuSim #(parameter WIDTH = 31,REG = 4, ROB = 2 , RS = 1, A_WIDTH = 3, INDEX = 7,
					BRANCH = 1, ALU = 3, B_WIDTH = 7);
		
		logic clk;
		logic globalReset;
		logic[WIDTH:0] result,regDest,nextPC;
		
		RISCV cpu(.*);
		
		timeunit 1ns; timeprecision 100ps;
		
		initial begin
			clk = '0; //Begin clock pulse at low level.
			forever #6.25 clk = ~clk;
		end
		
		initial begin
			globalReset = 1'b1; #8 //Don't check for the signal at the same time instant as you pulse it out.
			globalReset = 1'b0 ; assert (nextPC == '0) else $display(nextPC);
		end
endmodule