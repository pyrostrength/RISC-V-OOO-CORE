module dmem #(parameter WIDTH = 31) 
				 (input logic we, clk,
				  input logic[WIDTH:0] addr, // address width = 32
              input logic[3:0] bytEnable,     	// 4 bytes per word so a 4 bit bitmask signal to choose.
              input logic[WIDTH:0] data,  	// byte width = 8, 4 bytes per word
              output logic[WIDTH:0] q);  	// byte width = 8, 4 bytes per word

	// use a multi-dimensional packed array
	//to model individual bytes within the word
   logic [3:0][7:0] dm[0:63];	// 64 32-bit words with 4 subfields
	
	assign q = dm[addr[31:2]]; // Combinational read function

   always @(posedge clk) begin
		if(we) begin
           if(bytEnable[0]) dm[addr[31:2]][0] <= data[7:0];
           if(bytEnable[1]) dm[addr[31:2]][1] <= data[15:8];
           if(bytEnable[2]) dm[addr[31:2]][2] <= data[23:16];
			  if(bytEnable[3]) dm[addr[31:2]][3] <= data[31:24];
		end
   end
endmodule
				  