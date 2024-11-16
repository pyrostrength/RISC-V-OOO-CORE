module mux4 #(parameter WIDTH = 31)
			   (input logic[WIDTH:0] a,b,c,d,
				 input logic[1:0] select,
				 output logic[WIDTH:0] q);
		
		assign q = select[1] ? (select[0] ? d : c) : (select[0] ? b : a);
endmodule	 
