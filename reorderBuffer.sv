/*
The reorder buffer holds instructions results before commit.										

Acts as a FIFO circular buffer for instructions up until
they have their results ready for writing to register file or memory. 
Written to during writeRS&ROB stage 
with instruction control info{regWrite,
memWrite,branch,jump,destination(32bits)}.

Uses read and write pointers. Read_ptr
points to the head of the ROB and implements the pop
operation. Write pointer points to current write
location and implements push operation.

Uses full and empty signals to indicate whether we can write
to ROB. 

Regwrite and memWrite determine if we're writing 
to register file or memory.
Branch and jump handle the specific cases of conditional 
and unconditional branching instructions.

Read_ptr incremented with each successive read and
write_ptr with every write.

We risk placing useless state changes on 
register file,memory or even during instruction commit
broadcast thus necessasitating a signal determining validity
of an instruction commit prior to commit cycle. For this
allow asynchronous reads on ready buffer.

When an instruction writes results we indicate
availability of result in ready buffer.
When an instruction gets assigned to ROB we clear
it's associated ready buffer entry
otherwise we'll commit unready instructions.

MLAB implementation is possible and it would allow
for single cycle change in instruction fetch. Not
two cycle in which we fetch after commit cycle.

We maintain a separate buffer
for updating branch predictor and for maintaining
appropriate control flow of program execution.

Written to during writeRS&ROB stage 
with instruction state snapshot info{regStatus,sequentialPC,
previousIndex} and during instruction write
result stage with control flow and predictor update info
{targetAddress,writeBTB,takenBranch,state}.

Uses the same read and write pointer as reorder buffer
Buffer combinations
{sequential PC},{previousIndex,mispredict,writeBTB,takenBranch,state},
{regstatus},{targetaddress}.

If instruction is a JAL instruction we've finished executing in rename
stage prior to entering instruction to ROB or reservation station.
Thus we indicate availability of its result straightaway in ROB 
after rename stage.

Added reset signal to control Flow buffer.

Use read_ptr to synchronously read the memory buffers. 
Perform comparisons on with broadcast on CDB to determine instruction
readiness.

Must bypass for all instructions : value,target address,control flow info etc
*/

module reorderBuffer #(parameter WIDTH = 31, CONTROL = 7, INDEX = 7, ROB = 2)
							  (commonDataBus.reorder_buffer dataBus,
							   input logic[ROB:0] rob1,rob2,
								input logic robWrite,freeze,
							   writeCommit inputBus,
								writeCommit outputBus,
								output logic[WIDTH:0] ROBValue1,ROBValue2,
								output logic valid1,valid2,full, // Is reorder buffer full? 
								output logic[ROB:0] robAllocation,commitRob,
							   input logic clk);
								
								logic readyBuffer[7:0]; //Indexed by ROB entry,data indicates readiness of instruction commit.
								
								//Use initialization procedure

								logic[ROB:0] write_ptr = 3'b0; // write_ptr determines where to push onto buffer.
								logic[ROB:0] read_ptr = 3'b0;	// read_ptr determines where to pop off from buffer. 
								
								logic[WIDTH:0] valueBuffer[7:0]; // Indexed by ROB entry, data provides result.
								
								logic[WIDTH:0] destinationBuffer[7:0] ;//Indexed by ROB entry,data indicates {destination of result}
								
								//Contains control info {regWrite,memWrite,jump,branch}
								logic[3:0] controlBuffer[7:0];
								
								//Contains target addresses for control flow instructions
								logic[WIDTH:0] addressBuffer[7:0];	
								
								//Contains {state,writeBTB,takenBranch,mispredict,misdirect,isControl,reset}	
								logic[CONTROL:0] updateBuffer[7:0];
								 
								//Contains register status table snapshot for reset under branch misprediction.
								logic[WIDTH:0] regStatusBuffer[7:0];
								 
								/*Contains instruction PC for reset in case of branch misprediction and for
								updating the branch target buffer*/
								logic[WIDTH:0] oldPCBuffer[7:0];
								
								//Contains previousIndex for updating the gshare unit
								logic[INDEX:0] previousIndexBuffer[7:0];
								
								//Memory initialization for reorder buffers.
								initial begin
									$readmemb("valueInit.txt",valueBuffer);
									$readmemb("valueInit.txt",addressBuffer);
									$readmemb("readyInit.txt",regStatusBuffer);
									$readmemb("valueInit.txt",oldPCBuffer);
									$readmemb("controlInit.txt",updateBuffer);
									$readmemb("updateInit.txt",controlBuffer);
									$readmemb("indexInit.txt",previousIndexBuffer);
									$readmemb("valueInit.txt",destinationBuffer);
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
										
										/*Write on negative clock edge since values are pushed out
								of flip-flops at positive clock edge*/
										if(!freeze & robWrite) begin 
											
											//Write instruction destination into destination buffer
											destinationBuffer[write_ptr] <= inputBus.destination;
											
											//Write instruction info into controlBuffer
											controlBuffer[write_ptr] <= inputBus.commitInfo;
											
											//Clear ready buffer of incorrect information
											readyBuffer[write_ptr] <= 1'b0;
											
											//Increment write_ptr for subsequent writes.
											write_ptr <= write_ptr + 1'b1;
											
											//Write sequential PC associated with an instruction to buffer
											oldPCBuffer[write_ptr] <= inputBus.instrPC;
											
											//Write previous Index into previousIndexBuffer
											previousIndexBuffer[write_ptr] <= inputBus.PHTIndex;
											
											//Write regstatus snapshot associated with an instruction to buffer
											regStatusBuffer[write_ptr] <= inputBus.regStatus;
											
											
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
								
								//target address,{isControl,pcControl}
								
								//Can perform combinational logic for branch prediction unit,
								always_comb begin
									//Is buffer full?
									full = ((write_ptr + 3'd1) == read_ptr);
									//Determining branch misprediction
								end
								
								ROBrenamebuffer renamebuffer(.*,.ROBcommit(commitRob),.wcommit(commitRdy));
								
								assign robAllocation = write_ptr;
								
								
								always_ff @(posedge clk) begin
								/*Pass new value of the read_ptr. Then we
								use the new value to read from buffers at negative
								clock edge. Timing should be met*/
								   
								/*Writing to the commit bus if and only if instruction is ready to commit. We
								also increment read_ptr if and only if instruction was ready to commit.*/
									if(commitRdy) begin
										outputBus.result <= result;
										outputBus.commitInfo <= commitInfo;
										outputBus.oldPC <= oldPC;
										outputBus.statusSnap <= statusSnap;
										outputBus.previousIndex <= previousIndex;
										outputBus.controlFlow <= controlFlow;
										outputBus.targetAddress <= targetAddress;
										outputBus.validCommit <= 1'b1;
										outputBus.destCommit <= destCommit;
										read_ptr <= read_ptr + 3'd1; //Increment read_ptr
										commitRob <= read_ptr; //the rob entry for currently commiting instruction is commitRob, the initial read_ptr.
									end
									
									/* If we received no indication that instruction was ready to commit
									then its imperative that some signals be rendered inactive as opposed to 
									retaining their previous values. These are the control signals
								   that introduce state changes.	*/
									else begin
										outputBus.commitInfo <= '0;
										outputBus.controlFlow <= '0;
										outputBus.validCommit <= 1'b0;
									end
								end
								
endmodule



/*
Define a common interface for signals coming into and out of ROB. During write ROB and RS
stage a snapshot of the register status table,the sequential PC and previousIndex
used to access PHT and instruction info is written into the ROB.

During commit, result of instruction,correct target address,previous index
to update PHT if necessary, branch resolution info, sequential PC of
instruction and snapshot of regStatus is passed out of the ROB.
*/

interface writeCommit #(parameter WIDTH = 31, CONTROL = 7, INDEX = 7);
								logic[WIDTH:0] instrPC,oldPC,regStatus,statusSnap,targetAddress,result;
								logic[INDEX:0] PHTIndex,previousIndex;
								logic[CONTROL:0] controlFlow;
								logic[WIDTH:0] destination,destCommit;
								logic[3:0] commitInfo;
								logic validCommit;
								
								//modport writeROB (input instrPC,regStatus,PHTIndex,destination,commitInfo);
								//modport commitROB (output oldPC,statusSnap,previousIndex,commitInfo,result,
														// targetAddress,controlFlow,validCommit,destCommit);
								//modport instr_decode(input statusSnap,result,commitInfo,controlFlow,
								                     // validCommit,destCommit); //for updating the register status file
							                                                                           //and register file	
endinterface
								

