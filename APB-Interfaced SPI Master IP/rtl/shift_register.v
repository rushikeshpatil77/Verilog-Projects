module shift_register(
	input Pclk,
	input PRESET_n,
	input ss_i,
	input send_data_i,
	input lsbfe_i,
	input cpha_i , cpol_i,
	input mosi_send_neg,       //cpha_i = 0 , cpol_i = 1 or cpha_i = 1 , cpol_i = 0
	input mosi_send_pos,      //cpha_i = 1 , cpol_i = 1 or cpha_i = 0 , cpol_i = 0
	input miso_receive_neg,  //cpha_i = 0 , cpol_i = 1 or cpha_i = 1 , cpol_i = 0
	input miso_receive_pos, //cpha_i = 1 , cpol_i = 1 or cpha_i = 0 , cpol_i = 0
	input [7:0] data_mosi_i,
	input miso_i,
	input receive_data_i,
	output reg mosi_o,
	output [7:0] data_miso_o
);

	reg[2:0] count , count1;
	reg[2:0] count2 ,count3;
	
	reg[7:0] shif_reg;
	reg[7:0] temp_reg;
	
	assign data_miso_o = receive_data_i ? temp_reg : 8'h00;
	
	always@(posedge Pclk or negedge PRESET_n) begin
		if(!PRESET_n) begin
			shif_reg <= 8'b0;
		end
		else begin
			if (send_data_i) begin
				shif_reg <= data_mosi_i;
			end
			
			else begin
				shif_reg <= shif_reg;
			end
		end
	end
	
	always@(posedge Pclk or negedge PRESET_n) begin
		if(!PRESET_n) begin
			count <= 3'b000;
			count1 <= 3'b111;
			mosi_o <= 1'b0;
		end
		else begin
			if (!ss_i) begin
				if (cpha_i != cpol_i) begin
					if(lsbfe_i) begin
						if(count <= 3'd7 && mosi_send_neg) begin
								mosi_o <= shif_reg[count];
								count <= count + 1'b1;
								end
							else begin
								mosi_o <= mosi_o;
							end
						end
					
					else begin
						if (count1 >= 3'd0 && mosi_send_neg) begin
								mosi_o <= shif_reg[count1];
								count1 <= count1 - 1'b1;
								end
							else begin
								mosi_o <= mosi_o;
							end
						end
				    end
				
				else if ( cpha_i == cpol_i) begin
					if(lsbfe_i) begin
						if(count <= 3'd7 && mosi_send_pos) begin
								count <= count + 1'b1;
								mosi_o <= shif_reg[count];
								end
							else begin
								mosi_o <= mosi_o;
							end
						end
						
						else begin
							if(count1 >= 3'd0 && mosi_send_pos) begin
									count1 <= count1 - 1'b1;
									mosi_o <= shif_reg[count1];
									end
								else begin
									mosi_o <= mosi_o;
									end
								end
							end
		
						else begin
							mosi_o <= 1'b0;
							count <= 3'b0;
							count1 <= 3'd7;
						end
					end
					else begin
						mosi_o <= 1'b0;
						count <= 3'b0;
						count1 <= 3'd7;
					end
				end
			end
			
											
always@(posedge Pclk or negedge PRESET_n) begin
		if(!PRESET_n)begin
			temp_reg <= 8'b0;
			count2 <= 3'b0;
			count3 <= 3'd7;
		end
		else begin
			if(!ss_i)begin	
				if(cpha_i != cpol_i)begin
					if(lsbfe_i) begin
						if(count2 <= 3'd7 && miso_receive_neg) begin
								temp_reg[count2] <= miso_i;
								count2 <= count2 + 1'b1;
								end
							else begin
								temp_reg[count2] <= temp_reg[count2];
								count2 <= count2;
							end
						end
					else begin
						if(count3 >= 3'd0 && miso_receive_neg) begin
								temp_reg[count3] <= miso_i;
								count3 <= count3 - 1'b1;
								end
							else begin
								temp_reg[count3] <= temp_reg[count3];
								count3 <= count3;
								end
							end
							
					    end
								
					else if (cpha_i == cpol_i) begin
						if(lsbfe_i) begin
							if (count2 <= 3'd7 && miso_receive_pos) begin
									temp_reg[count2] <= miso_i;
									count2 <= count2 + 1'b1;
									end
								else begin
									temp_reg[count2] <= temp_reg[count2];
									count2 <= count2;
									end
								end
								
								else begin
									if(count3 >= 3'd0 && miso_receive_pos) begin
											temp_reg[count3] <= miso_i;
											count3 <= count3 - 1'b1;
											end
											else begin
												temp_reg[count3] <= temp_reg[count3];
												count3 <= count3;
											end
										end
									end
								else begin
									temp_reg <= temp_reg;
									count2 <= 3'b000;
									count3 <= 3'b111;
								end
							end
							else begin
									temp_reg <= temp_reg;
									count2 <= 3'b000;
									count3 <= 3'b111;
								end
							end
						end
									
							
endmodule							
		
	