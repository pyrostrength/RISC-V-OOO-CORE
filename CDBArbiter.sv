/*Interface bundling up signals related to results,ROB entry of 
associated instruction and control signal indicating validity of broadcast on
common Data Bus. Reservation stations,functional units and the reorder buffer share
this interface.
*/



interface commonDataBus #(parameter WIDTH = 31, ROB = 2,CONTROL = 4);
								  
								  logic[WIDTH:0] result;
								  logic[ROB:0] robEntry;
								  logic validBroadcast; //Is what's written to CDB a valid signal?
								  logic[WIDTH:0] targetAddress; //specifically for branching instructions
								  logic isControl; //Is instruction a control flow instruction?
								  logic[CONTROL:0] pcControl;
								
								modport arbiter(output result,robEntry,validBroadcast,targetAddress,isControl,pcControl); //arbiter selects instruction to write CDB.
								
								modport reservation_station(input result,robEntry,validBroadcast); //Reservation station needs result and robEntry
								
								modport reorder_buffer(input result,robEntry,validBroadcast,targetAddress,isControl,pcControl); //Reorder buffer also needs result an ROB entry.
								
								modport rename_stage(input result,robEntry,validBroadcast);
								
endinterface


/* Bus arbiter for the common data bus. Implemented as a round
robin arbiter.

Provide for the default broadcast whereby ALU broadcasts it's results if there are
no requests made by functional units ( functional units were empty ).
This default behavior does nothing of consequence as valid broadcast is
0.

CDB arbiter also determines whether a functional unit is
available. If no request had been made to CDB arbiter within
the clock cycle then functional unit is available.If a request
had been made but functional unit wasn't granted permission
to write to CDB then functional unit is unavailable.

If request was made and permission granted to write CDB then
respective functional unit is available.

*/							
								
module CDBArbiter  #(parameter WIDTH = 31, ROB = 2,CONTROL = 4) //control changed to 6 to account for reset signal. we place reset in L.S.Bit.
						  (commonDataBus.arbiter dataBus,
						   input logic globalReset,clear,validCommit,
							input logic[CONTROL:0] controlPC,
							input logic[ROB:0] ALURob,branchRob,
							input logic[WIDTH:0] ALUResult,branchResult,fetchAddress,
							input logic ALURequest,branchRequest,clk,
							output logic aluAvailable,branchAvailable);
							
								//Bus arbitration functionality
								
								logic nxtPointer,pointer; //Instead of in-line initialization assign a variables value through another
								
								logic[WIDTH:0] value;
								
								logic[1:0] grant;
								
								logic[ROB:0] rob;
								//Variable declaration assignment needs to have a constant expression
								logic we;
								
								assign we = ALURequest | branchRequest;
								
								logic controlFlow; //Are we going to write a control flow instruction on CDB?
								
								
								//Pointer points to respective functional unit.
								//01 for ALU,10 for branch.
								always_comb begin
									grant = 2'b01;
									controlFlow = 1'b0;
									case(pointer)
										1'b0: begin//ALU request
											if(ALURequest) grant = 2'b01;
											else if(branchRequest) begin
												grant = 2'b10;
												controlFlow = 1'b1;
											end
										end
										1'b1: begin//Branch request
											if(branchRequest) begin
												grant = 2'b10;
												controlFlow = 1'b1;
											end
											else if(ALURequest) grant = 2'b01;
										end
									endcase
									//Assigning to a result
									value = grant[0] ? ALUResult : (grant[1] ? branchResult : 32'd0); 
									
									rob = grant[0] ? ALURob : (grant[1] ? branchRob : 3'b000);
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
								
								always_comb begin
									aluAvailable = (grant == 2'b01) ? 1'b1 : !ALURequest;
									branchAvailable = (grant == 2'b10) ? 1'b1 : !branchRequest;
								end
										
								//We only pass a result out if and only if we received sth from functional units.
								always_ff @(posedge clk) begin
								//Pass a result iff and only if we actually received sth from the functional units.
									if(globalReset) begin
										pointer <= nxtPointer;
										dataBus.result <= '0;
										dataBus.robEntry <= '0; 
										dataBus.validBroadcast <= '0;
										dataBus.isControl <= '0;
										dataBus.pcControl <= '0;
										dataBus.targetAddress <= '0;
									end
									
									else if(clear & validCommit) begin
										dataBus.validBroadcast <= '0;
									end
									
									/*Potential source for glitches*/
									else if(we) begin
										pointer <= nxtPointer;
										dataBus.result <= value;
										dataBus.robEntry <= rob; 
										dataBus.validBroadcast <= we;//(Value of we to determine if we actually made a request)
										dataBus.isControl <= controlFlow;
										dataBus.pcControl <= controlPC;
										dataBus.targetAddress <= fetchAddress;
									end
									
									/*If not global reset, no instruction requested CDB,no cpuReset then
									we must indicate that the broadcast on ROB is invalid*/
									else begin
										dataBus.validBroadcast <= '0;
									end	
									
								end
endmodule
								
									