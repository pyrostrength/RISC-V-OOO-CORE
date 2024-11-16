/*Basic flip-flop with an enable and reset signal */


module flopenr #(parameter WIDTH = 31)
					 (input logic[WIDTH:0] d,
					  input logic clk,reset,enable,
					  output logic[WIDTH:0] q);
		 
		 always_ff @(posedge clk)
			if(reset) q <= 0;
			else if(enable) q <= d;		
endmodule


/*module flopr #(parameter WIDTH = 31)
				  (input logic[WIDTH:0] d,
				   input logic clk,reset,
					output logic[WIDTH:0] q);
		always_ff @(posedge clk)
			if(reset) q <= 0;
			else q <= d;
endmodule */
			
								