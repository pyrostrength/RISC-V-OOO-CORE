module RSArbiterTest #(parameter WIDTH = 31, RS = 1, BRANCH = 1, ALU = 3);
                     logic[RS:0] RSstation;
						   logic stationRequest,ALUFull,branchFull;
						   logic[BRANCH:0] branchBusyVector;
						   logic[ALU:0] ALUBusyVector;
						   logic[BRANCH:0] branchRequests;
						   logic[ALU:0] ALURequests;
							
							
							initial begin
								RSstation = 2'b00; stationRequest = 1'b1 ; ALUBusyVector = 4'b0000; #10
								assert (ALURequests == 4'b0001) else $display(ALURequests);
								
								/*RSstation = 2'b00; stationRequest = 1'b1 ; ALUBusyVector = 4'b1001; #5
								assert (ALURequests == 4'b0010) else $display(ALURequests); #5
								
								RSstation = 2'b00; stationRequest = 1'b0 ; ALUBusyVector = 4'b1001; #5
								assert (ALURequests == 4'b0000) else $display(ALURequests); #5
								
								RSstation = 2'b01; stationRequest = 1'b1 ; branchBusyVector = 2'b01; #5
								assert (branchRequests == 2'b10); 
								assert (ALURequests == 4'b0000); #5
								
								RSstation = 2'b11 ; stationRequest = 1'b1 ; #5 
								assert (branchRequests == 2'b00);
								assert (ALURequests == 4'b0000); */
							end
endmodule