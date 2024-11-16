
/*RS selection logic for instruction execution in 
  branchALU.
  
  Has two entries only thus request and grant signal are
  2-bit signals
*/


module branchSelect #(parameter WIDTH = 31, RS = 1)
						  (input logic[RS:0] requests,
						   input logic clear,clk,
							output logic[RS:0] grants);
							
								//Bus arbitration functionality
								
								logic nxtPointer,pointer; //Instead of in-line initialization assign a variables value through another
								
								logic[1:0] grants;
								
								//Pointer points to respective functional unit.
								//1 for ALU,0 for branch.
								always_comb begin
									grants = 2'b00;
									case(pointer)
										1'b0: begin//ALU request
											if(requests[0]) grants = 2'b01;
											else if(requests[1]) grants = 2'b10;
											else grants = 2'b00;
										end
										1'b1: begin//Branch request
											if(requests[1]) grant = 2'b10;
											else if(requests[0]) grant = 2'b01;
											else grants = 2'b00;
										end
									endcase
								end
								
								
								//Critical path is shifting out value of pointer then
								//based on its value calculating the grant,the values and rob
								//and then finding nxtPointer. nxtPointer always starts from
								//zero though so this simplifies things.
								//Priority shifting logic
								always_comb begin
									nxtPointer = 1'b0;
									case(grant)
										2'b10: nxtPointer = 1'b0; //Grant priority to branchALU
										2'b01: nxtPointer = 1'b1; //Grant priority to ALU.
										default:nxtPointer = 1'b0;
									endcase
								end
										
								//We only pass a result out if and only if we received sth from functional units.
								always_ff @(posedge clk) begin
									if(clear) begin
										pointer <= '0;
									end else begin
										pointer <= nxtPointer;
									end
								end
endmodule