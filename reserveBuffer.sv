/*
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
{sequential PC},{mispredict,writeBTB,takenBranch,state},
{regstatus,previousIndex}

*/


module controlBuffer #(parameter WIDTH = 31, CONTROL = 13);
							 (commonDataBus.reorder_buffer dataBus,
							  input logic[WIDTH:0] seqPCW,regStatusW,
							  input logic clk,reset,
							  output logic[WIDTH:0] regStatusC,seqPCC,targetAddress,
							  output logic[CONTROL:0] controlFlow);
							 
								//Contains target addresses for control flow instructions
								logic[WIDTH:0] addressbuffer[7:0]; 
								
								//Contains {previousIndex,state,writeBTB,takenBranch,mispredict,misdirect}	
								logic[CONTROL:0] predictorBuffer[7:0];
								 
								//Contains register status table snapshot for reset under branch misprediction.
								logic[WIDTH;0] regStatusBuffer[7:0];
								 
								//Contains sequential PC for reset in case of branch misprediction
								logic[WIDTH:0] seqPCbuffer[7:0];
								 
								
								//Contains register status table snapshot for reset under branch misprediction.
								logic[WIDTH:0] regStatusBuffer[7:0];
								 
								logic[WIDTH:0] readyBuffer
									
								
								//Asynchronous read for instruction result and info.
								always_comb begin
										commitResult = valuebuffer[read_ptr];
										commitInfo = infobuffer[read_ptr];
										
								end
								
								//Sequential write to place instruction into ROB.
								//Or update buffers during write result stage.
								always_ff @(negedge clk) begin
									//If instruction ready to commit,increment read_ptr
									   read_ptr <= {2'b00,readybuffer[read_ptr]} + read_ptr;
										if(!full) begin
											
											//Write instruction information into infobuffer
											infobuffer[write_ptr] <= instrInfo;
											
											//Clear ready buffer of incorrect information
											readybuffer[write_ptr] <= 1'b0;
											
											//Increment write_ptr for subsequent writes.
											write_ptr <= write_ptr + '1;
											
											//Write sequential PC associated with an instruction to buffer
											seqPCBuffer[write_ptr] <= seqPC;
											
											//Write regstatus snapshot associated with an instruction to buffer
											regStatusBuffer[write_ptr] <= regStatus;
											
											
										end
									
									 //Indicate data value and it's availability after write result stage.
									 //Doesn't depend upon fullness of ROB.
										if(dataBus.validBroadcast) begin
											readybuffer[dataBus.robEntry] <= 1'b1;
											
											valuebuffer[dataBus.robEntry] <= dataBus.result;
											
											addressBuffer[dataBus.robEntry] <= dataBus.targetAddress;
											
											predictorBuffer[dataBus.robEntry] <= dataBus.pcControl;
										end
								end
								
								//Can perform combinational logic for branch prediction unit,
								always_comb begin
									//Is buffer full?
									full = ((write_ptr + 1) == read_ptr);
									//Determining branch misprediction
								end
								


								

								
endmodule

endmodule