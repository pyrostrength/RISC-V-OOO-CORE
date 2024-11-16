module mux2 #(parameter WIDTH = 31)
				 (input logic[WIDTH:0] a,b,
				  input logic select,
				  output logic[WIDTH:0] q);
		assign q = select ? b : a;
endmodule