module adder #(parameter WIDTH = 31)
             (input logic[WIDTH:0] a,b,
				  output logic[WIDTH:0] y);
				  
				  assign y = a + b;
endmodule
				  