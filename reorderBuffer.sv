/*
The reorder buffer holds instructions results before commit.										

Acts as a FIFO circular buffer for instructions up until
they have their results ready for writing to register file or memory. 
Written to during writeRS&ROB stage 
with instruction control info{regWrite,
memWrite,branch,jump,dest}.

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
*/

module reorderBuffer #(parameter WIDTH = 31, CONTROL = 5, INDEX = 7, ROB = 2)
							  (commonDataBus.reorder_buffer dataBus,
							   input logic[WIDTH:0] validAddress,
							   writeCommit.writeROB inputBus,
								writeCommit.commitROB outputBus,
							   input logic clk,isJAL);
								
								logic readyBuffer[7:0]; //Indexed by ROB entry,data indicates readiness of instruction commit.
								
								//Use initialization procedure
								logic[ROB:0] write_ptr = 3'b0; // write_ptr determines where to push onto buffer.
								logic[ROB:0] read_ptr = 3'b0;	// read_ptr determines where to pop off from buffer.
								logic full; // Is reorder buffer full? 
								
								logic[WIDTH:0] valueBuffer[7:0]; // Indexed by ROB entry, data provides result.
								
								logic[WIDTH + 4:0] infoBuffer[7:0] ;//Indexed by ROB entry,data indicates {instruction info,destination of result}
								
								//Contains target addresses for control flow instructions
								logic[WIDTH:0] addressBuffer[7:0];	
								
								//Contains {state,writeBTB,takenBranch,mispredict,misdirect}	
								logic[CONTROL:0] updateBuffer[7:0];
								 
								//Contains register status table snapshot for reset under branch misprediction.
								logic[WIDTH:0] regStatusBuffer[7:0];
								 
								//Contains sequential PC & previousIndex for reset in case of branch misprediction
								logic[WIDTH + 8:0] seqPCBuffer[7:0];
								
								always_comb begin
										outputBus.result = valueBuffer[read_ptr];
										outputBus.commitInfo = infoBuffer[read_ptr];
										outputBus.seqPCC = seqPCBuffer[read_ptr][WIDTH:0];
										outputBus.regStatusC = regStatusBuffer[read_ptr];
										outputBus.previousIndex = seqPCBuffer[read_ptr][WIDTH + INDEX + 1:WIDTH];
										outputBus.controlFlow = updateBuffer[read_ptr];
										outputBus.targetAddress = addressBuffer[read_ptr];
								end
								
								
								always_ff @(negedge clk) begin
									//If instruction ready to commit,increment read_ptr
									   read_ptr <= {2'b00,readyBuffer[read_ptr]} + read_ptr;
										if(!full) begin
											
											//Write instruction information into infobuffer
											infoBuffer[write_ptr] <= inputBus.instrInfo;
											
											//Clear ready buffer of incorrect information
											readyBuffer[write_ptr] <= isJAL; //If instruction is a JAL instruction then it's ready.
											
											//Increment write_ptr for subsequent writes.
											write_ptr <= write_ptr + '1;
											
											//Write sequential PC associated with an instruction to buffer
											seqPCBuffer[write_ptr] <= {inputBus.PHTIndex,inputBus.seqPCW};
											
											//Write regstatus snapshot associated with an instruction to buffer
											regStatusBuffer[write_ptr] <= inputBus.regStatusW;
											
											/*Write a result from branchTargetResolve to valueBuffer on
											writeRS&ROB stage to allow for faster execution of JAL instructions
											and LUI,AUIPC instructions. This saves space on RS for subsequent
											instructions and executes U-type and JAL instructions in 4 less
											cycles. I'll consider revamping to allow fast execution on JALR
										   instructions. Note that if we can execute the instruction in the 
											rename stage then we can add to ROB without worrying about dependency.
											*/	
											
											valueBuffer[write_ptr] <= validAddress;
											
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
											
											updateBuffer[dataBus.robEntry] <= dataBus.pcControl;
										end
								end
								
								//Can perform combinational logic for branch prediction unit,
								always_comb begin
									//Is buffer full?
									full = ((write_ptr + 1) == read_ptr);
									//Determining branch misprediction
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

interface writeCommit #(parameter WIDTH = 31, CONTROL = 5, INDEX = 7);
								logic[WIDTH:0] seqPCW,seqPCC,regStatusW,regStatusC,targetAddress,result;
								logic[INDEX:0] PHTIndex,previousIndex;
								logic[CONTROL:0] controlFlow;
								logic[WIDTH+4:0] instrInfo,commitInfo;
								
								modport writeROB (input seqPCW,regStatusW,PHTIndex,instrInfo);
								modport commitROB (output seqPCC,regStatusC,previousIndex,commitInfo,result,targetAddress,controlFlow);
endinterface
								

