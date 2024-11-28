/* ALU performing computational operations defined by the RISC-V base ISA.
   Values are assumed to be signed by the base ISA thus necessitating signed
	casting of logic signals. 
	 
	
	Request signal added to availability of result to round robin bus
	arbiter. This necessasitates
	drawing out the combinational logic for any possible functional unit.
	Yet all functional units share a common round robin arbiter.
	
	Regardless, path through ALU and CDB controller 
	might be shorter than path through memory. Since clock cycle limited
	by slowest stage, we need not pipeline our functional unit.
	
*/


module ALU #(parameter WIDTH = 31,C_WIDTH = 3)
				(input logic signed[WIDTH:0] src1,src2,
				 input logic [C_WIDTH:0] ALUControl,
				 output logic signed[WIDTH:0] result,
				 output logic  ALURequest);
				 
				 /*For shifts with immediate the shift amount
				 is encoded in first 5 bits of immediate or rs2 value.
				 */
				 always_comb begin
					result = 32'd0;
					ALURequest = 1'b1;
					case(ALUControl)
						4'b0000: 
							result = src1 + src2;	//add
						4'b0001:
							result = src1 & src2; //bit-wise and
						4'b0010: 
							result = src1 | src2; //bit-wise or	
						4'b0011:
							result = src1 ^ src2; //bit-wise xor
						4'b0100:
							result = src1 < src2; // set-less than 
						4'b0101:
							result = unsigned' (src1) < unsigned' (src2); // set-less than unsigned
						4'b0110: 
							result = src1 << src2[4:0]; // shift left logical
						4'b0111: 
							result = src1 >> src2[4:0]; // shift right logical
						4'b1000: 
							result = src1 - src2; // subtraction
						4'b1001: 
							result = src1 >>> src2[4:0]; // shift right arithmetic. 
						default: begin
							result = 32'd0;
							ALURequest = 1'b0;
						end
					endcase
				end	
endmodule 

