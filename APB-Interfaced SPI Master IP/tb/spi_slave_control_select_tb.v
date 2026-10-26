module spi_slave_control_select_tb;
		reg  Pclk, PRESET_n;
		reg mstr;
		reg spiswai_i;
		reg [1:0]spi_mode_i;
		reg send_data_i;
		reg [11:0] baudratedivisor_o;
		wire recieve_data_out;
		wire ss_o;
		wire tip_out;
		
		
		spi_slave_control_select DUT (
								.Pclk(Pclk),
								.PRESET_n(PRESET_n),
								.mstr(mstr),
								.spiswai_i(spiswai_i),
								.spi_mode_i(spi_mode_i),
								.send_data_i(send_data_i),
								.baudratedivisor_o(baudratedivisor_o),
								.recieve_data_out(recieve_data_out),
								.ss_o(ss_o),
								.tip_out(tip_out)
								);
								
		initial 
				begin
					Pclk = 1'b0 ;
					forever #5 Pclk = ~Pclk ;
				end
								
		task initialize;
			begin
				Pclk = 1'b0;
				PRESET_n = 1'b0;
				mstr = 1'b0;
				spiswai_i = 1'b0;
				spi_mode_i = 2'b00;
				send_data_i = 1'b0;
				baudratedivisor_o = 12'b0;
			end
		endtask
		
		
		task reset;
			begin
				@(negedge Pclk)
				PRESET_n = 1'b0 ;
				#1;
				@(negedge Pclk)
				PRESET_n= 1'b1;
				#1;
			end
		endtask  
		
		task stimulus;
			begin
				@(negedge Pclk)
					mstr =1'b1;
					spiswai_i= 1'b0;
					spi_mode_i= 2'b01;
					send_data_i=1'b1;
					@(negedge Pclk)
					send_data_i=1'b0;
			end
		endtask
		
		initial 
			begin
				initialize;
				reset;
				baudratedivisor_o=12'd4;
				stimulus;
				#2000;
				$finish;
			end
endmodule

		
