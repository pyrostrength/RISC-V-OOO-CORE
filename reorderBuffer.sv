/*The reorder buffer holds instructions results before commit.

Acts as a FIFO circular buffer for instructions currently under
consideration for execution or executing or instructions
that are to write to register file or memory. Written to 
during writeRS&ROB stage with instruction control info{regWrite,
memWrite,branch,jump}


Read pointer points to the head of the ROB and implements the pop
operation. Write pointer points to current write
location and implements push operation. 

Buffer considered full when the next write pointer will point to
the read pointer.

Regwrite and memWrite help decide if we're writing 
to register file or memory.
Branch and jump handle the specific cases of conditional 
and unconditional branching instructions.

We must implement a separate buffer that indicates
misprediction information for an associated branch entry.

Read_ptr incremented with each successive read.
Nonetheless we risk placing useless state changes on 
register file,memory or even during instruction commit
broadcast. Thus we must have a signal indicating the validity
of an instruction commit as this value is broadcast to other modules.
This is done via the commitRdy signal.

Write_ptr incremented after every write to ROB.

We implement a ready buffer using ALM. This ready buffer determines whether
the head of the ROB has it's result ready. Data values indicates result availability.
Indexed by ROB entry of instruction which is just the read_ptr.

When an instruction writes results we indicate in the ready buffer the availability of result for 
When an instruction gets assigned to ROB we clear
it's associated ready buffer entry to remove prior state information,
otherwise we'll commit instructions whose results aren't available yet.

We maintain a target address buffer to determine intended jump/branch
target addresses of instructions during commit.

For that we must have indications for whether instruction was a branch
or jump and whether it was taken as mispredicted or not.
We include a taken bit to update global history register with correct 
information and a mispredicted bit to update pattern history table.

How to reset register mapping during write result stage - important.

ROBResult and instrResult are now part of the declared interface.
*/

module reorderBuffer #(parameter ROB = 2, WIDTH = 31)
							  (commonDataBus.reorder_buffer dataBus,
							   input logic[WIDTH + 4:0] instrInfo,
							   input logic clk,reset,
								output logic[WIDTH:0] commitResult,
								output logic[WIDTH + 4:0] commitInfo);
								
								logic readybuffer[7:0]; //Indexed by ROB entry,data indicates readiness of instruction commit.
								
								//Use initialization procedure
								logic[ROB:0] write_ptr = 3'b0; // write_ptr determines where to push onto buffer.
								logic[ROB:0] read_ptr = 3'b0;	// read_ptr determines where to pop off from buffer.
								logic full; // Is reorder buffer full? 
								
								logic[WIDTH:0] valuebuffer[7:0]; // Indexed by ROB entry, data provides result.
								
								logic[WIDTH + 4:0] infobuffer[7:0] ;//Indexed by ROB entry,data indicates {instruction info,destination of result}
								
								//Sequential read for instruction result and info.
								always_ff @(negedge clk) begin
										commitResult <= valuebuffer[read_ptr];
										commitInfo <= infobuffer[read_ptr];
										read_ptr <= {2'b00,readybuffer[read_ptr]} + read_ptr;
									//If instruction ready to commit,increment read_ptr
								end
								
								//Sequential write to place instruction into ROB.
								//Or update buffers during write result stage.
								always_ff @(negedge clk) begin
										if(!full) begin
											
											//Write instruction information into infobuffer
											infobuffer[write_ptr] <= instrInfo;
											
											//Clear ready buffer of incorrect information
											readybuffer[write_ptr] <= 1'b0;
											
											//Increment write_ptr for subsequent writes.
											write_ptr <= write_ptr + '1;
										end
									
									 //Indicate data value and it's availability after write result stage.
									 //Doesn't depend upon fullness of ROB.
										if(dataBus.validBroadcast) begin
											readybuffer[dataBus.robEntry] <= 1'b1;
											
											valuebuffer[dataBus.robEntry] <= dataBus.result;
										end
								end
								
								//Can perform combinational logic for branch prediction unit,
								always_comb begin
									//Is buffer full?
									full = ((write_ptr + 1) == read_ptr);
									//Determining branch misprediction
								end
								
endmodule

