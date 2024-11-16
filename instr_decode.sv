/*Code for the instruction decode stage


*/





module instr_decode #(parameter WIDTH = 31, V_WIDTH = 63, I_WIDTH = 14, ROB = 3)
							(input logic[WIDTH : 0] instruction,ROBValue,
							 input logic wasTaken,clk,ROBavailable,ROBcommit, //is a ROB entry available,
							 input logic[3:0][1:0] RSstation, //Vector indicating availability in the 4 reservation stations.
							 input logic[3:0] ROBentry, //ROB entry that's available to write to.
							 input logic[4:0] freedReg, //ROB destination register that's being freed during instruction commit
							 output logic[I_WIDTH:0] instrInfo1,instrInfo2,instrInfo3,instrInfo4); //Instruction info to write to reservation stations
							 //output logic[V_WIDTH:0] valuesRS1,valuesRS2,valuesRS3,valuesRS4); //Instruction source operand values to be buffered in reservation stations.
							 
							 
							 //Register file
							 logic[WIDTH:0]  regValue1,regValue2;
							 register_file regfile(.*,.a1(instruction[19:15]),.a2(instruction[24:20]),
																.a3(freedReg),.we(ROBcommit),.rd1(regValue1),
																.rd2(regValue2),.wd(ROBValue));
							 
							 //Register status table
							 //Corner case of unnecessary ball-hogging. YOU SHOULD REALLY LOOK INTO THIS!
							 logic[ROB:0] rob1,rob2;
							 register_status regStatus(.*,.rob1(rob1),.rob2(rob2),.we(ROBavailable),.rs1(instruction[19:15]),
																.rs2(instruction[24:20]),.wd(instruction[11:7]),
																.wrob(freedReg),.wdvalue(ROBentry));
																
							 //Instruction decoder and immediate extension
							 
							 logic[3:0] ALUControl;
							 logic[WIDTH:0] immExt;
							 logic memWrite,branch,jump,useImm;
							 
							 decodeextend decodeextender (.*,.ALUControl(ALUControl),.immExt(immExt),.memWrite(memWrite),
																	.branch(branch),.jump(jump),.useImm(useImm),.RSstation(RSstation));
																
							
							 
							 
							 //Data value determination.
							 
							 logic [WIDTH:0] instrValue1,instrValue2;
							 logic [WIDTH:0] extraImm; //Specifically for branch instructions which have an extra immediate added to PC.
							 logic [2*WIDTH:0] instrValues;
							 logic [I_WIDTH:0] instrInfo;
							 logic ready1,ready2;
							 
							 
							
							////////////////////////////////////////////////////////////////////////////
							
							assign instrInfo = {instruction[3:0],rob1[2:0],rob2[2:0],ready1,ready2};
							
							/*logic[V_WIDTH:0] valuesRS1,valuesRS2,valuesRS3,valuesRS4;
							
							//Demux logic. Constructing instruction info
							always_comb begin
								unique case(RSstation)
								//ALU reservation station
									2'b00:
										valuesRS1 = instrValues;
										instrInfo = {ROBALUControl,rob1[2:0],rob2[2:0],ready1,ready2,
								//Precase assignments
								
								{instrInfo1,instrInfo2,instrInfo3,instrInfo4} = 15'b0;
								{valuesRS1,valuesRS2,valuesRS3,valuesRS4} = 64'b0;
								
								unique case(instruction[3:0])
									//JALR,JAL,BRANCH,U-TYPE to branch condition evaluation subunit
									4'b0011,4'b0100,4'b0101,4'b0110,4'b0111:begin
										if (RSstation[1] == 2'b01) begin  //01 indicates that RS for branching unit is available
											instrInfo2 = instrInfo;
											valuesRS2 = instrValues;
										end
									end
								
									4'b1000,4'b0010: begin
										if (RSstation[0] == 2'b00) begin //00 indicates that RS for load/store unit is available
											instrInfo1 = instrInfo;
											valuesRS1 = instrValues;
										end
									end
								
									4'b1001,4'b1010,4'b1011: begin // 10 indicates multiplication
										if(RSstation[2] == 2'b10) begin
											instrInfo3 = instrInfo;
											valuesRS3 = instrValues;
										end
									end
									
									default: begin //11 indicates that RS for ALU operations is available.
										if(RSstation[3] == 2'b11) begin
											instrInfo4 = instrInfo;
											valuesRS4 = instrValues;
										end
									end
								endcase
						   end */
endmodule
								
								
										
									
									
							
									
							 