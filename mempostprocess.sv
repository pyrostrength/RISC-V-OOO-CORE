/* This module filters the 32-bit memory data for required data for storing
	at register file. For byte/half-word loads the respective byte/half-word is sign-
	extended before storing. For the respective unsigned operation counterparts,
	the byte/half-word is zero-extended. */


//sub-fielded instruction.
//For byte we just pick that byte. then use our funct3 bit to determine sign/zero extension. Default is sign extension
//we give that a 1. Zero extension we give a 
//for(int i=0, i<4,i++) begin
// memdata
//assumption was half-word/byte fills the lowest position so just using the byte enable isn't possible.
//single case

module mempostprocess #(parameter WIDTH = 31)
							  (input logic[WIDTH:0] memdata,
							   input logic[3:0] bytEnable,
								input logic[2:0] funct3,
								output logic[WIDTH:0] rfdata);
								
								
								always_comb begin
									rfdata = memdata;
									//for (int i=0,i<=4,i++)begin
									//rfdata[i] = (bytenable
									case(bytEnable)
										4'b0001:
											case(funct3)
												3'b000: rfdata = memdata[7:0];
												3'b001: rfdata = { {24{memdata[7]}}, memdata[7:0] };
											endcase
										4'b0010:
											case(funct3)
												3'b000: rfdata = memdata[15:8];
												3'b001: rfdata = { {24{memdata[15]}}, memdata[15:8] };
											endcase
										4'b0100:
											case(funct3)
												3'b000: rfdata = memdata[23:16];
												3'b001: rfdata = { {24{memdata[23]}}, memdata[23:16] };
											endcase
										4'b1000:
											case(funct3)
												3'b000: rfdata = memdata[31:24]; // unsigned lb
												3'b001: rfdata = { {24{memdata[31]}}, memdata[31:24] };
											endcase
										4'b0011:
											case(funct3)
												3'b010: rfdata = { {16{memdata[15]}}, memdata[15:0] };
												3'b011: rfdata = memdata[15:0]; //unsigned lw
											endcase
										4'b1100:
											case(funct3)
												3'b010: rfdata = { {16{memdata[31]}}, memdata[31:16] };
												3'b011: rfdata = memdata[15:0];
											endcase
									endcase
								end
endmodule
											