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
				 output logic  aluDataBusReq);
				 
				 /*For shifts with immediate the shift amount
				 is encoded in first 5 bits of immediate or rs2 value.
				 */
				 always_comb begin
					result = 32'd0;
					aluDataBusReq = 1'b0;
					case(ALUControl)
						4'b0000: begin
							result = src1 + src2; //add
							aluDataBusReq = 1'b1;
						end
						4'b0001: begin
							result = src1 & src2; //bit-wise and
							aluDataBusReq = 1'b1;
						end
						4'b0010: begin
							result = src1 | src2; //bit-wise or
							aluDataBusReq = 1'b1;	
						end
						4'b0011: begin
							result = src1 ^ src2; //bit-wise xor
							aluDataBusReq = 1'b1;
						end
						4'b0100: begin
							result = src1 < src2; // set-less than
							aluDataBusReq = 1'b1;
						end
						4'b0101: begin
							result = unsigned' (src1) < unsigned' (src2); // set-less than unsigned
							aluDataBusReq = 1'b1;
						end
						4'b0110: begin
							result = src1 << src2[4:0]; // shift left logical
							aluDataBusReq = 1'b1;
						end
						4'b0111: begin
							result = src1 >> src2[4:0]; // shift right logical
							aluDataBusReq = 1'b1;
						end
						4'b1000: begin
							result = src1 - src2; // subtraction
							aluDataBusReq = 1'b1;
						end
						4'b1001: begin
							result = src1 >>> src2[4:0]; // shift right arithmetic.
							aluDataBusReq = 1'b1;
						end
						default: begin
							result = 32'd0;
							aluDataBusReq = 1'b0;
						end
					endcase
				end	
endmodule 

