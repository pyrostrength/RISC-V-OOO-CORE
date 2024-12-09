module ALUSelectTest #(parameter WIDTH = 31, RS = 3);
							  logic[3:0] requests;
						     logic clear,clk;
						     logic[3:0] grants;
							
								//Bus arbitration functionality
								
								logic[1:0] nxtPointer,pointer; 
								
								/*Pointer points to respective entry.
								Lower numbered entries are indicated
								on least significant bits.
								1 for ALU,0 for branch*/
								always_comb begin
									case(pointer)
										2'b00: begin //Points to first entry
											if(requests[0]) grants = 4'b0001;
											else if(requests[1]) grants = 4'b0010;
											else if(requests[2]) grants = 4'b0100;
											else if(requests[3]) grants = 4'b1000;
											else grants = 4'b0000;
										end
										2'b01: begin //Points to second entry
											if(requests[1]) grants = 4'b0010;
											else if(requests[2]) grants = 4'b0100;
											else if(requests[3]) grants = 4'b1000;
											else if(requests[0]) grants = 4'b0001;
											else grants = 4'b0000;
										end
										2'b10: begin //Points to third entry
											if(requests[2]) grants = 4'b0100;
											else if(requests[3]) grants = 4'b1000;
											else if(requests[0]) grants = 4'b0001;
											else if(requests[1]) grants = 4'b0010;
											else grants = 4'b0000;
										end
										2'b11: begin //Points to fourth entry
											if(requests[3]) grants = 4'b1000;
											else if(requests[0]) grants = 4'b0001;
											else if(requests[1]) grants = 4'b0010;
											else if(requests[2]) grants = 4'b0100;
											else grants = 4'b0000;
										end
									endcase
								end
									
								
								
								//Critical path is shifting out value of pointer then
								//based on its value calculating the grant,the values and rob
								//and then finding nxtPointer. nxtPointer always starts from
								//zero though so this simplifies things.
								//Priority shifting logic
								always_comb begin
								   nxtPointer = 2'b00;
									case(grants)
										4'b0001: nxtPointer = 2'b01; //Grant priority to branchALU
										4'b0010: nxtPointer = 2'b10; //Grant priority to ALU.
										4'b0100: nxtPointer = 2'b11;
										4'b1000: nxtPointer = 2'b00;
									endcase
								end
										
								//Pointer reset on clear or take on of next pointer value
								always_ff @(posedge clk) begin
									if(clear) begin
										pointer <= '0;
									end else begin
										pointer <= nxtPointer;
									end
								end
								
								timeunit 1ns; timeprecision 100ps;
								
								initial begin
									clk = '0; //Begin clock pulse at low level.
									forever #2.5 clk = ~clk; //Clock period of 5 nanoseconds. Corresponds to a duty period of 5 nanoseconds. 100 Mhz signal
								end
								
								initial begin
								//Set pointer to an initial state
										clear = 1'b1; #3
										clear = 1'b0;
								//Make the requests to ALUselect logic. Combinational logic decision to decide on value for grants.
										requests = 4'b1001; #2 //Simultaneous change of data input and assertion won't work out well in simulation.
										assert (grants == 4'b0001) else $display(grants); #5
										assert (grants == 4'b1000) else $display(grants); #3
										requests = 4'b0000;#2 
										assert (grants == 4'b0000) else $display(grants);#3
										assert (pointer == 2'b00) else $display(grants);
										requests = 4'b1011;#3
										assert (grants == 4'b0001) else $display(grants);#2
										assert (grants == 4'b0010) else $display(grants);#5
										assert (grants == 4'b1000) else $display(grants);
								end
endmodule
										