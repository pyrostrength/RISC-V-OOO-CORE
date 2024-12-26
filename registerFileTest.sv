module registerFileTest #(parameter D_WIDTH = 31, A_WIDTH = 4);
								logic clk,regWrite,validCommit;
							   logic[A_WIDTH:0] address1,address2,wraddress;
							   logic[D_WIDTH:0] wdata;
							   logic[D_WIDTH:0] regValue1,regValue2;
							 
							 
							   timeunit 1ns; timeprecision 100ps;
														
							   initial begin
									 clk = 1'b0; //Begin clock pulse at low level.
									 forever #2.5 clk = ~clk; //Clock period of 5 nanoseconds. Corresponds to a duty period of 5 nanoseconds. 100 Mhz signal
							   end
										
								register_file regFile(.*);
								
								initial begin
								   regWrite = 1'b1;
									wdata = 32'd60 ; wraddress = 32'd4 ; #5
									wdata = 32'd80 ; wraddress = 32'd9; #5
									wdata = 32'd60 ; wraddress = 32'd3; #5
									
									//New data behaviour worked ?
									wdata = 32'd9 ; wraddress = 32'd3 ; address1 = 32'd3 ; address2 = 32'd4; #3
									assert (regValue1 == wdata);
									assert (regValue2 == 32'd60); 
								end
endmodule