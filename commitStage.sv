module commitStage #(parameter WIDTH = 31, ROB = 2, B_WIDTH = 7, RS = 1 , A_WIDTH = 3, INDEX = 7,CONTROL = 6)
                    (commonDataBus.reorder_buffer dataBus,
							input logic[ROB:0] rob1,rob2,
							input logic clk,isJAL,
							input logic[INDEX:0] PHTIndex,
							input logic[WIDTH:0] seqPCW,regStatusW,
							input logic[WIDTH+4:0] instrInfo,commitInfo,
							output logic[CONTROL:0] controlFlow,
							output logic[WIDTH:0] ROBValue1,ROBValue2,result,targetAddress,regStatusC,seqPCC,
							output logic[INDEX:0] previousIndex,
							output logic valid1,valid2);
							
							

//add reorder buffer,reorder rename buffer,make connections to instruction fetch decode etc using commit bus
//need to monitor data bus,output values on commit bus,write values to reorder rename buffer,
//reset PC if necessary.
endmodule
