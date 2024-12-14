
//Consider the extend unit verified completely.

/* This module outputs a 32-bit immediate based off of the immediate field of
	the current instruction and a control signal,immSrc. The control signal
	dictates how the immediate fields bits are organized to produce the immediate
	as well as dictating the necessary padding to produce a 32-bit value.
*/


module extend #(parameter WIDTH = 24,
                             C_WIDTH = 2,
									  I_WIDTH = 31)
						(input logic[WIDTH:0] imm,
						 input logic[C_WIDTH:0] immSrc,
						 output logic[I_WIDTH:0] immExt);
				      always_comb begin
							case(immSrc)
								3'b000 : immExt = {{20{imm[24]}},imm[24:13]}; // I-immediate with fields [31:20]
								3'b010 : immExt = {{20{imm[24]}},imm[0],imm[23:18],imm[4:1],1'b0};/*
								B-immediate with fields 31,7,[30:25],[11:8],implicit 0 last bit */
							   3'b100 : immExt = {{12{imm[24]}},imm[12:5],imm[13],imm[23:14],1'b0};//J-immediate with fields 31,[19:12],20,[30:21]
								
								/*3'b001 : immExt = {{20{imm[24]}},imm[24:18],imm[4:0]}; // S-immediate with fields [31:25],[11:7]
								3'b011 : immExt = {imm[24:5],{12{1'b0}}}; /* U-immediate with fields [31:12] */
								default: immExt = 32'd0;
							endcase
						end
endmodule
								