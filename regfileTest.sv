/* Register file test module.
New data behaviour is expected during 
read during write thus simultaneous writes
and read to the same address should give
the new data. Important aspect to 
test for.

Passed on all assertions.
Completely verified.
 */



module regfileTest #(parameter WIDTH = 31, A_WIDTH = 4);
       
		 logic[A_WIDTH:0] address1,address2,wraddress;
		 logic[WIDTH:0] regValue1,regValue2,wdata;
		 logic clk,regWrite,validCommit;
		 
		 
		 timeunit 1ns;
		 //Clock generator
		 initial begin
				clk = '0; //Begin clock pulse at low level.
				forever #2.5 clk = ~clk; //Clock period of 5 nanoseconds. Corresponds to a duty period of 5 nanoseconds. 100 Mhz signal
		 end
		 
		 register_file regFile(.*);
		 //Register file is asynchronously read so we determine data value at any time point.
		 initial begin
				//Write in data values on clock edge to register
				wdata = 32'd5; address1 = 5'd2; wraddress = 5'd2 ; regWrite = 1'b1;  #5 //Wait until falling edge of clock to account for time to write and time to read.
				assert (regValue1 == 32'd5); //Testing for new data behaviour on same address read and write.
				wdata = 32'd6; wraddress = 5'd3 ; address2 = 5'd2 ; #3 //Testing read and write at different addresses.
			   assert (regValue2 == 32'd5);
			   wdata = 32'd30; wraddress = 5'd3 ; address1 = 5'd3 ; #3 //Write should not have written value as it wrote not at positive clock edge.
		      assert (regValue1 == 32'd6);		
		end
		 
endmodule	
		