module spi_slave_control_select (
		input Pclk, PRESET_n,
		input mstr,
		input spiswai_i,
		input [1:0]spi_mode_i,
		input send_data_i,
		input [11:0]baudratedivisor_o,
		output reg recieve_data_out,
		output reg ss_o,
		output tip_out );
		
		wire [15:0] target;
		reg [15:0] count ;
		assign tip_out = ~ss_o ;
		reg rcv ;
		assign target = 4'd8 * baudratedivisor_o ;
		
		always@(posedge Pclk or negedge PRESET_n)
			begin
				if(!PRESET_n)
					begin
						ss_o <= 1'b1 ;
						count <= 16'hffff ;
						rcv <= 1'b0;
						recieve_data_out <= 1'b0 ;
					end
				else
					begin
						recieve_data_out <= rcv ;
						if(mstr && ((spi_mode_i == 2'b00)||(!spiswai_i && spi_mode_i == 2'b01)))
							begin
								if(send_data_i)
									begin 
										rcv <= 1'b0 ;
										ss_o <= 1'b0 ;
										count <= 16'b0 ;
									end
								else
									begin 
										if(count <= target - 1'b1)
											begin
												count <= count + 1'b1 ;
												ss_o <= 1'b0 ;
												if(count == target - 1'b1)
													rcv <= 1'b1 ;
												else 
													rcv <= 1'b0;
													
											end	
										else 
											begin	
												rcv <= 1'b0 ;
												count <= 16'hffff;
												ss_o <= 1'b1;
											end
													
									end
							end
						else
							begin 
								ss_o <= 1'b0 ;
								count  <= 16'hffff;
								rcv <= 1'b0;
							end
					end
			end
endmodule