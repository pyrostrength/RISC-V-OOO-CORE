/*
The reorder buffer holds instructions results before commit.										

Implemented as a FIFO circular buffer. 
Holds for instructions up until their results ready 
and instruction is head of ROB. Head and tail of
ROB maintained by read and write pointers.
We provide for two cycle instruction wakeup and commit
by bypassing value on CDB broadcast,marking entry as ready
and incrementing read_ptr in next cycle at positive clock edge.

Written to in rename stage 
with instruction control info{regWrite,
memWrite,branch,jump},
result destination,old instruction PC,index used
to access g-share prediction and a snapshot
of register status table.

Clearing of instruction from ROB is completed by
simply incrementing the read_ptr. That way writes
to that entry are allowed.

Written to during broadcast on CDB with correct fetch address
(for JALR/branch instructions),instruction fetch control info
{isControl,nextState,writeBTB,takenBranch,reset}

*/

module reorderBuffer #(parameter WIDTH = 31, CONTROL = 5, INDEX = 7, ROB = 2)
							  (commonDataBus.reorder_buffer dataBus,
							   input logic[ROB:0] rob1,rob2,
								input logic robWrite,freeze,globalReset,
							   writeCommit inputBus,
								writeCommit outputBus,
								output logic[WIDTH:0] ROBValue1,ROBValue2,
								output logic valid1,valid2,full, // Is reorder buffer full? 
								output logic[ROB:0] robAllocation,commitRob,
							   input logic clk);
								
								logic readyBuffer[7:0]; //Indexed by ROB entry,data indicates readiness of instruction commit.
								
								//Use initialization procedure

								logic[ROB:0] write_ptr = 3'b000; // write_ptr determines where to push onto buffer.
								logic[ROB:0] read_ptr = 3'b000;	// read_ptr determines where to pop off from buffer. 
								
								logic[WIDTH:0] valueBuffer[7:0]; // Indexed by ROB entry, data provides result.
								
								logic[WIDTH:0] destinationBuffer[7:0] ;//Indexed by ROB entry,data indicates {destination of result}
								
								//Contains control info {regWrite,memWrite,jump,branch}
								logic[3:0] controlBuffer[7:0];
								
								//Contains target addresses for control flow instructions
								logic[WIDTH:0] addressBuffer[7:0];	
								
								//Contains {isControl,nextstate,writeBTB,takenBranch,reset}	
								logic[CONTROL:0] updateBuffer[7:0];
								 
								//Contains register status table snapshot for reset under branch misprediction.
								logic[WIDTH:0] regStatusBuffer[7:0];
								 
								/*Contains instruction PC for updating the branch target buffer*/
								logic[WIDTH:0] oldPCBuffer[7:0];
								
								//Contains previousIndex for updating the gshare unit
								logic[INDEX:0] previousIndexBuffer[7:0];
								
								//Memory initialization for reorder buffers.
								initial begin
									$readmemb("/home/voidknight/Downloads/CPU_Q/valueInit.txt",valueBuffer);
									$readmemb("/home/voidknight/Downloads/CPU_Q/valueInit.txt",addressBuffer);
									$readmemb("/home/voidknight/Downloads/CPU_Q/readyInit.txt",regStatusBuffer);
									$readmemb("/home/voidknight/Downloads/CPU_Q/valueInit.txt",oldPCBuffer);
									$readmemb("/home/voidknight/Downloads/CPU_Q/controlInit.txt",updateBuffer);
									$readmemb("/home/voidknight/Downloads/CPU_Q/updateInit.txt",controlBuffer);
									$readmemb("/home/voidknight/Downloads/CPU_Q/indexInit.txt",previousIndexBuffer);
									$readmemb("/home/voidknight/Downloads/CPU_Q/valueInit.txt",destinationBuffer);
								end
								
								logic rdy,bypass,commitRdy;
								
								
								//Signal declaration for writing to the commit bus.
								logic[WIDTH:0] value,target;
								logic[CONTROL:0] pcControl;
								logic[WIDTH:0] result,targetAddress,statusSnap,oldPC,destCommit;
								logic[3:0] commitInfo;
								logic[CONTROL:0] controlFlow;
								logic[INDEX:0] previousIndex;
										
								
								/*Compare read_ptr and rob entry broadcast on CDB.If match
								  then our value is ready for commit in next cycle. We simply
								  pass the value through the flipflop by enabling it.*/
								/*read_ptr is incremented if commit occures at positive clock edge*/
								always_comb begin
									bypass = 1'b0;
									if(dataBus.validBroadcast & (dataBus.robEntry == read_ptr)) begin
										bypass = 1'b1; //Ready to commit instruction
								   end
									
									/*If instruction writing CDB as we read from buffers
									is current head of ROB then we
									prepare result for commit in next cycle by bypassing
									the values from CDB. We commit in the next cycle.*/
									result = (bypass) ? dataBus.result : value;
								
									targetAddress = (bypass) ? dataBus.targetAddress :  target;
									
									controlFlow = (bypass) ? {dataBus.isControl,dataBus.pcControl} : pcControl;
									
									commitRdy = bypass | rdy;
									
								end
										
										
								
								
								always_ff @(negedge clk) begin
								/*Synchronous read of values using read_ptr on
								negative clock edge. Read_ptr was incremented at positive
								clock edge if commit occurs*/
										value <= valueBuffer[read_ptr];
										commitInfo <= controlBuffer[read_ptr];
										statusSnap <= regStatusBuffer[read_ptr];
										oldPC <= oldPCBuffer[read_ptr];
										previousIndex <= previousIndexBuffer[read_ptr];
										pcControl <= updateBuffer[read_ptr];
										target <= addressBuffer[read_ptr];
										rdy <= readyBuffer[read_ptr];
										destCommit <= destinationBuffer[read_ptr];
										
								/*Write on negative clock edge since inter-stage flip-flops operate positive clock edge*/
										if(!freeze & robWrite & !globalReset) begin 
											
											//Write instruction destination into destination buffer
											destinationBuffer[write_ptr] <= inputBus.destination;
											
											//Write instruction info into controlBuffer
											controlBuffer[write_ptr] <= inputBus.commitInfo;
											
											//Clear ready buffer of incorrect information
											readyBuffer[write_ptr] <= 1'b0;
											
											/*Increment write_ptr iff pipeline was never frozen,
											a request to write the rob had been made and rob isn't
											full*/
											if(!full) begin
												write_ptr <= write_ptr + 3'b001;
											end
											
											//Write sequential PC associated with an instruction to buffer
											oldPCBuffer[write_ptr] <= inputBus.instrPC;
											
											//Write previous Index into previousIndexBuffer
											previousIndexBuffer[write_ptr] <= inputBus.PHTIndex;
											
											//Write regstatus snapshot associated with an instruction to buffer
											regStatusBuffer[write_ptr] <= inputBus.regStatus;
											
											
										end
										
										if(globalReset) begin
											write_ptr <= '0;
										end
									
									 /*Indicate data value and it's availability after write result stage.
									   Doesn't depend upon fullness of ROB. */
										if(dataBus.validBroadcast) begin
											readyBuffer[dataBus.robEntry] <= 1'b1;
											
											valueBuffer[dataBus.robEntry] <= dataBus.result;
									
										end
									
									/*If instruction is a control flow instruction then we store
									  target address and relevant PC select and branch predictor update
									  control information*/
										if(dataBus.isControl) begin
											addressBuffer[dataBus.robEntry] <= dataBus.targetAddress;
											
											updateBuffer[dataBus.robEntry] <= {dataBus.isControl,dataBus.pcControl};
										end
								end
								
								
								always_comb begin
									//Is buffer full?
									full = ((write_ptr + 3'b001) == read_ptr);
								end
								
								ROBrenamebuffer renamebuffer(.*,.ROBcommit(commitRob),.wcommit(commitRdy));
								
								assign robAllocation = write_ptr;
								
								
								always_ff @(posedge clk) begin
								/*Global reset signal sets the CPU into a known state*/
									if(globalReset) begin
										outputBus.result <= '0;
										outputBus.commitInfo <= '0;
										outputBus.oldPC <= '0;
										outputBus.statusSnap <= '0;
										outputBus.previousIndex <= '0;
										outputBus.controlFlow <= '0;
										outputBus.targetAddress <= '0;
										outputBus.validCommit <= '0;
										outputBus.destCommit <= '0;
										commitRob <= '0;
										read_ptr <= '0;
									end
								/*Pass new value of the read_ptr. Then we
								use the new value to read from buffers at negative
								clock edge. Timing should be met*/
								   
								/*Writing to the commit bus if and only if instruction is ready to commit. We
								also increment read_ptr if and only if instruction was ready to commit.*/
									else if(commitRdy) begin
										outputBus.result <= result;
										outputBus.commitInfo <= commitInfo;
										outputBus.oldPC <= oldPC;
										outputBus.statusSnap <= statusSnap;
										outputBus.previousIndex <= previousIndex;
										outputBus.controlFlow <= controlFlow;
										outputBus.targetAddress <= targetAddress;
										outputBus.validCommit <= 1'b1;
										outputBus.destCommit <= destCommit;
										read_ptr <= read_ptr + 3'b001; //Increment read_ptr
										commitRob <= read_ptr; //the rob entry for currently commiting instruction is commitRob, the initial read_ptr.
									end
									
									
									/* If we received no indication that instruction was ready to commit
									then its imperative that some signals be rendered inactive as opposed to 
									retaining their previous values. These are the control signals
								   that introduce state changes.	*/
									else begin
										outputBus.commitInfo <= '0;
										outputBus.controlFlow <= '0;
										outputBus.validCommit <= '0;
									end
								end
								
endmodule



/*
Define a common interface for signals coming into and out of ROB. 
*/

interface writeCommit #(parameter WIDTH = 31, CONTROL = 7, INDEX = 7);
								logic[WIDTH:0] instrPC,oldPC,regStatus,statusSnap,targetAddress,result;
								logic[INDEX:0] PHTIndex,previousIndex;
								logic[CONTROL:0] controlFlow;
								logic[WIDTH:0] destination,destCommit;
								logic[3:0] commitInfo;
								logic validCommit;
								
endinterface
								

