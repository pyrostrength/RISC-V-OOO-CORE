/*test bench for ALU reservation station entry and branch Reservation station entry*/


module RSTest #(parameter WIDTH = 31, ROB = 2, C_WIDTH = 3, RS = 3);
					commonDataBus dataBus();
					logic ready1,ready2,clear,clk,execute,writeReq,selectReq,busy,selected,globalReset;
					//logic[RS:0] writeRequests;
					logic signed[WIDTH:0] value1,value2;
					logic [C_WIDTH:0] ALUControl;
					logic[ROB:0] rob1,rob2,robInstr,src2Rob;
					
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
					   ALUControl = 4'b1010 ; robInstr = 3'd5; rob1 = 3'd0; rob2 = 3'd6; #5
					
				      assert (instrRob == robInstr);
					   assert (busy == 1'b1);
						assert (instrInfo == ALUControl);
						assert (src1 == 32'd3);
						assert (src2 == 32'd7);
						$display (src1);
						$display (src2);
					   writeReq = 1'b0;	
						
						
						//Will it quickly indicate entry availability provided that it's been selected for execution?
						selected = 1'b1; #3 
						assert (busy == 1'b0); #2
						
						//Will my instruction capture values it needs from common data bus? Especially if
						//I write to RS entry at the same time as a broadcast on CDB
						ready1 = 1'b0 ; ready2 = 1'b0 ; execute = 1'b1 ; selected = 1'b0;
					   writeReq = 1'b1; value1 = 32'd0 ; value2 = 32'd0;
					   ALUControl = 4'b0110; robInstr = 3'd5; rob1 = 3'd4; rob2 = 3'd0; #3
	
						//Broadcast on CDB. Need to capture the values and bypass as necessary
						dataBus.result = 32'd30 ; dataBus.robEntry = 3'd4 ; dataBus.validBroadcast = 1'b1; //Databus values arrive a bit-later. Resembling the delay
						writeReq = 1'b0; #1
						
						assert (busy == 1'b1);
						assert (src1 == 32'd30) else $display (src1); //Source value isnt captured
						assert (instrInfo == ALUControl); 
						assert (selectReq == 1'b0); #1  //Since equal zero.
						
					
						//Avoid obtaining what isn't needed.
						#3 dataBus.result = 32'd30 ; dataBus.robEntry = 3'd2 ; dataBus.validBroadcast = 1'b1; #1
						assert (selectReq == 1'b0); #1
						
					   //Avoid obtaining what isn't needed - no valid broadcast on CDB yet supposed match on ROB entry.
						#3 dataBus.result = 32'd0; dataBus.robEntry = 3'd0 ; dataBus.validBroadcast = 1'b0; #1
						assert (selectReq == 1'b0); #1
					
						//Obtaining values - what it needs. 
						#3 dataBus.result = 32'd60; dataBus.robEntry = 3'd0 ; dataBus.validBroadcast = 1'b1; #1
						assert (selectReq == 1'b1); #1
						
						
						//Testing write in,broadcast and requesting selection one same cycle.
						writeReq = 1'b1 ; execute = 1'b0 ; ready1 = 1'b0 ; ready2 = 1'b0 ; 
					   value1 = 32'd0 ; value2 = 32'd0; ALUControl = 4'b0010; 
						robInstr = 3'd4; rob1 = 3'd5; rob2 = 3'd5; #3
						
						dataBus.result = 32'd23 ; dataBus.robEntry = 3'd5 ; dataBus.validBroadcast = 1'b1; //Databus values arrive a bit-later. Resembling the delay
						writeReq = 1'b0; #1
						
						assert (busy == 1'b1);
						assert (src1 == 32'd23);
						assert (src2 == 32'd23) ;
						assert (selectReq == 1'b1);
						assert (instrInfo == ALUControl);
					   assert (instrRob == robInstr); 	
					end
endmodule
						
					
					