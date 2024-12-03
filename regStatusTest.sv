module regStatusTest #(parameter REG = 4, DEPTH = 31, ROB = 2, WIDTH = 31);
		   logic clk,we,reset,validCommit,regWrite;
			logic[REG:0] rs1,rs2,destReg,destRegR,regCommit;
			logic[WIDTH:0] statusRestore;
			logic[ROB:0] destROB,commitROB; // ROB entry that writes to a destination register.
			logic[ROB:0] rob1,rob2;
			logic[WIDTH:0] regStatusSnap;
			logic busy1,busy2;
			
			
			timeunit 1ns; timeprecision 100ps;
							
			initial begin
					clk = 1'b0; //Begin clock pulse at low level.
					forever #2.5 clk = ~clk; //Clock period of 5 nanoseconds. Corresponds to a duty period of 5 nanoseconds. 100 Mhz signal
			end
			
			register_status statusTable(.*);
			//Data values change on clock pulse
			
			initial begin
					commitROB = 1'b0; regWrite = 1'b0 ; destReg = 5'd0 ; regCommit = 5'd0; statusRestore = 32'd0; reset = 1'b1; #3 //Place into an initial state
					//Write in our dependencies
					assert (regStatusSnap == 32'd0); #2//No dependencies indicated. Might have an error at this point.
					
					regWrite = 1'b1 ; reset = 1'b0 ; we = 1'b1; destROB = 3'd0; destReg = 5'd4; destRegR = 5'd0; #3
					assert(regStatusSnap == 32'd16); #2
					
					destROB = 3'd1 ; destReg = 5'd8; destRegR = 5'd4; #3
					assert (regStatusSnap == 32'd272); #2 //Only the
					
					destROB = 3'd2 ; destReg = 5'd31; destRegR = 5'd8; #3
					assert (regStatusSnap == 32'd2147483920); #2
					
					//Checking for values of interest,one dependent, other one not.
					regWrite = 1'b0 ; we = 1'b1; rs1 = 5'd8 ; rs2 = 5'd3 ; destRegR = 5'd31; destROB = 3'd3; #3
					assert (rob1 == 3'd2);
					assert (rob2 == 3'd0); #2 //srcROB entries initialized to 0 during power up
					
					//Both dependent
					rs1 = 5'd8 ; rs2 = 5'd8 ; #3
					assert (rob1 == 3'd2);
					assert (rob2 == 3'd2); #2
					
					//Say rob2 commits at the same time another instruction is searching for its dependence.
					//Busy1 and busy2 must be marked as zero
					commitROB = 3'd3 ;destRegR = 5'd0 ; regWrite = 1'b1 ; rs1 = 5'd31 ; rs2 = 5'd31 ; validCommit = 1'b1 ; regCommit = 5'd31; destReg = 5'd4 ;#3
					assert (busy1 == 1'b0);
					assert (rob1 == 3'd3);
					assert (rob2 == 3'd3);
					assert (busy2 == 1'b0); #2
					
					//Say at the same time as instruction commits another marks its dependence on same register
					commitROB = 3'd1 ;regWrite = 1'b0 ; we = 1'b1 ; regCommit = 5'd4 ; validCommit = 1'b1 ; destROB = 3'd4 ; destRegR = 5'd4; 
					rs1 = 5'd4 ; rs2 = 5'd31 ; #3
					//validCommit = 1'b0; we = 1'b0; #3
					assert (rob1 == destROB) else $display(rob1);
					assert (busy1 == 1'b1) else $display(busy1);
			end
endmodule
					
					