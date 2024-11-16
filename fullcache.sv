module fullcache #(parameter CAM_WIDTH=32,
									  NUM_CELL=32)
							(input clk, rst,write_en, read_en,
							input [CAM_WIDTH-1:0] search_key, 
							output [CAM_WIDTH-1:0] cam_out,
							output cam_full, match_found);
							
							logic [CAM_WIDTH-1:0] cam_mem [NUM_CELL-1:0]; // Array to store CAM cell data
							logic [NUM_CELL-1:0]  match_flag; // Flags indicating a match for each CAM cell
							logic [NUM_CELL-1:0]  valid, valid_comb; // Valid flags for each CAM cell

							always_ff @(posedge clk or negedge rst) begin
								if (!rst) begin
									match_flag <= '0;
									valid <= '0;
								end
								else begin
									match_flag <= match_flag;
									valid <= valid_comb;
								end   
							end

							always_comb begin
							foreach (int i = 0; i < NUM_CELL; i++) begin
									if (read_en || write_en) begin
										if (search_key == cam_cell[i])
										match_flag[i] = 1'b1; // Set match flag if search key matches CAM cell data
										else
											 match_flag[i] = 1'b0; // Reset match flag otherwise
									end
								end
							end

						  always_comb begin
							 foreach (int i = 0; i < NUM_CELL; i++) begin
								if (match_flag[i] && read_en) 
								  cam_output = cam_mem[i]; // Set output to the CAM cell data if a match is found
							 end
						  end

						  generate
							foreach (int i = 0; i < NUM_CELL; i++) begin
								always_ff @(posedge clk or negedge rst) begin
								  if ((!cam_full) && write_en && (!match_found) && !(valid[i])) begin
									 cam_mem[i] <= search_key; // Write the search key to the CAM cell if entry not found.
									 val_comb[i] <= 1'b1;   
								  end
								end
							end
						  endgenerate

						  assign match_found = (|match_flag); // Set match_found output if any match flag is true
						  assign cam_full = (&valid); // Set cam_full output if all valid flags are true
endmodule
						
						