/* This module converts the 32-bitsource data into a 32-bit format suitable for byte,half-word
   full word stores. Since memory is byte-addressable, the first two bits of address gives us 
	the respective offset(0-3). No offset causes misalignment on a byte load.
	Support for misaligned access on half-word load (an offset of 1 or 3) is overwrite of 
	lower half-word.
	Support for misaligned access on full-word load (an offset of 1,3,2) is overwrite of entire word.
*/



module mempreprocess #(parameter WIDTH = 31)
							 (input logic[WIDTH:0] source,address,
							  input logic[1:0] funct3, //only last two bits of funct3 field are relevant
							  output logic[3:0] bytEnable,
							  output logic[WIDTH:0] data);
							  
							  always_comb begin
									/* Default values are provided for data and byteEnable
									to avoid latch inference and account for full word stores,
									even on misaligned memory access.
								   */	
									data = source;
									bytEnable = 4'b1111;
									//Only last two bits of funct3 field are relevant for the byteneable signal.
									//Unsigned and signed byte/half-word have the same byte-enables.
									case(funct3)
										2'b00: //No mis-aligned access on byte stores.
											case(address[1:0]) // Determines the data address offset
												2'b00 : bytEnable = 4'b0001; // Access only the first byte. No need to shift source value
												2'b01: begin //Shift data source value that way it can be accessed using appropriate bytEnable signal
													bytEnable = 4'b0010;
													data = source << 8;
												end
												2'b10: begin
													bytEnable = 4'b0100;
													data = source << 16;
												end
												2'b11: begin
													bytEnable = 4'b1000;
													data = source << 24;
												end
											endcase
										2'b10: //Half-word stores
											case(address[1:0])
												2'b00: bytEnable = 4'b0011;
												2'b10: begin
													bytEnable = 4'b1100;
													data = source << 16;
												end
												default: bytEnable = 4'b0011; // Behavior on misaligned memory access.
											endcase
									endcase
							end
endmodule

								