module RSTest #(parameter WIDTH = 31, ROB = 2, C_WIDTH = 3, RS = 3);
					commonDataBus dataBus();
					logic ready1,ready2,clear,clk,execute,writeReq,selectReq,busy,selected;
					//logic[RS:0] writeRequests;
					logic signed[WIDTH:0] value1,value2;
					logic [C_WIDTH:0] ALUControl;
					logic[ROB:0] rob1,rob2,robInstr;
					
					logic[ROB:0] instrRob;
					logic[C_WIDTH:0] instrInfo;
				   //logic[RS:0] busy;
					logic signed[WIDTH:0] src1,src2;
					
					ALURStationEntry reservationStation(.*);
					
					timeunit 1ns; timeprecision 100ps;
					
					initial begin
						clk = 1'b0; //Begin clock pulse at low level.
						forever #2.5 clk = ~clk;
					end
					
					//Instruction of ROB entry 8 has a result that instruction 2,3 depend on.
					//4,5,6 are just ready for execution from the jump.
					initial begin
						clear = 1'b1; #5
						
						//Add in new instructions to reservation station
						//First instruction. Testing selection in the same cycle
						ready1 = 1'b1 ; ready2 = 1'b1 ; execute = 1'b1 ; clear = 1'b0 ;
					   writeReq = 1'b1; value1 = 32'd3 ; value2 = 32'd7;
					   ALUControl = 4'b1010 ; robInstr = 3'd5; rob1 = 3'd0; rob2 = 3'd0; #8
					
				      assert (instrRob == robInstr);
					   assert (busy == 1'b1);
						assert (instrInfo == ALUControl);
						$display (src1);
						$display (src2); #2	
						
						
						//Will it quickly indicate entry availability provided that it's been selected for execution?
						writeReq = 1'b0 ; selected = 1'b1; #3
						assert (busy == 1'b0) #2
						
						//Will my instruction capture values it needs from common data bus? Especially if
						//I write to RS entry at the same time as a broadcast on CDB
						ready1 = 1'b0 ; ready2 = 1'b0 ; execute = 1'b1 ; selected = 1'b0;
					   writeReq = 1'b1; value1 = 32'd0 ; value2 = 32'd0;
					   ALUControl = 4'b0110; robInstr = 3'd5; rob1 = 3'd4; rob2 = 3'd5;
						dataBus.result = 32'd30 ; dataBus.robEntry = 3'd4 ; dataBus.validBroadcast = 1'b1; #3
					   
						writeReq = 1'b0;
						assert (busy == 1'b1);
						assert (ready1 == 1'b1);
						assert (value1 == 32'd30);
						assert (instrInfo == ALUControl); #2
					
						//Obtaining values - not what it needs.
						
						ready1 = 1'b0 ; ready2 = 1'b0 ; execute = 1'b1 ; clear = 1'b0 ;
					   writeReq = 1'b1; value1 = 32'd3 ; value2 = 32'd7;
					   ALUControl = 4'b1000 ; robInstr = 3'd6; rob1 = 3'd2; rob2 = 3'd3; #8
					
						//Obtaining values - what it needs.
						
						ready1 = 1'b0 ; ready2 = 1'b0 ; execute = 1'b1 ; clear = 1'b0 ;
					   writeReq = 1'b1; value1 = 32'd3 ; value2 = 32'd7;
					   ALUControl = 4'b1010 ; robInstr = 3'd5; rob1 = 3'd0; rob2 = 3'd0; #8
					   
						assert (busy == 1'b1);
						
						//Does it ask to execute?
						
						//Have instructions selected for execution by broadcasting on CDB.Testing broadcast and selection in the same cycle.
						
						
						//Have an 2 instructions ready for execution - choose 1. Testing write in,broadcast and selection in the same cycle.
						
						
						//Propagate in incorrect values.
					end
endmodule
						
					
					