/*Interface bundling up signals related to results,ROB entry of 
associated instruction and control signal indicating validity of broadcast on
common Data Bus. Reservation stations,functional units and the reorder buffer share
this interface.
*/



interface commonDataBus #(parameter WIDTH = 31, ROB = 2);
								  
								  logic[WIDTH:0] result;
								  logic[ROB:0] robEntry;
								  logic validBroadcast; //Is what's written to CDB a valid signal?
								
								modport arbiter(output result,robEntry,validBroadcast); //arbiter selects instruction to write CDB.
								
								modport reservation_station(input result,robEntry,validBroadcast); //Reservation station needs result and robEntry
								
								modport reorder_buffer(input result,robEntry,validBroadcast); //Reorder buffer also needs result an ROB entry.
								
endinterface


/* Bus arbiter for the common data bus. Implemented as a round
robin arbiter.

Provide for the default broadcast whereby ALU broadcasts it's results if there are
no requests made by functional units ( functional units were empty ).
This default behavior does nothing of consequence as valid broadcast is
0.

*/							
								
module CDBArbiter  #(parameter WIDTH = 31, ROB = 2)
						  (commonDataBus.arbiter dataBus,
							input logic[ROB:0] ALURob,branchRob,
							input logic[WIDTH:0] ALUResult,branchResult,
							input logic ALURequest,branchRequest,clk);
							
								//Bus arbitration functionality
								
								logic nxtPointer,pointer; //Instead of in-line initialization assign a variables value through another
								
								logic[1:0] grant;
								
								logic[WIDTH:0] value;
								
								logic[ROB:0] rob;
								//Variable declaration assignment needs to have a constant expression
								logic we;
								
								assign we = ALURequest | branchRequest;
								
								//Pointer points to respective functional unit.
								//1 for ALU,0 for branch.
								always_comb begin
									grant = 2'b00;
									case(pointer)
										1'b0: begin//ALU request
											if(ALURequest) grant = 2'b10;
											else if(branchRequest) grant = 2'b01;
											else grant = 2'b00;
										end
										1'b1: begin//Branch request
											if(branchRequest) grant = 2'b10;
											else if(ALURequest) grant = 2'b01;
											else grant = 2'b00;
										end
									endcase
									//Assigning to a result
									value = grant[0] ? ALUResult : (grant[1] ? branchResult : 32'd0); 
									
									rob = grant[0] ? ALURob : (grant[1] ? branchRob : 2'd00);
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
										pointer <= nxtPointer;
										dataBus.result <= value;
										dataBus.robEntry <= rob; 
										dataBus.validBroadcast <= we;
								end
endmodule
								
									