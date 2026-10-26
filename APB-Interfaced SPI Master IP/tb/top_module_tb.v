module top_module_tb;
	reg Pclk , PRESET_n; 
	reg [2:0] Padder;
	reg Psel ,Penable , Pwrite;
	reg [7:0] Pwdata;
	reg miso;
	wire [7:0] Prdata; 
	wire Pready , Pslverr;
	wire mosi;
	wire ss , sclk;
	wire spi_interrupt_request;
	
	integer i;
	integer j;
	
	top_module DUT (.Pclk(Pclk),
					.PRESET_n(PRESET_n),
					.Padder(Padder),
					.Psel(Psel),
					.Penable(Penable),
					.Pwrite(Pwrite),
					.Pwdata(Pwdata),
					.miso(miso),
					.Prdata(Prdata),
					.Pready(Pready),
					.Pslverr(Pslverr),
					.mosi(mosi),
					.ss(ss),
					.sclk(sclk),
					.spi_interrupt_request(spi_interrupt_request)
				);
	
	initial begin
		Pclk = 1'b0;
		forever #5 Pclk = ~Pclk;
	end
	
	task reset;
		begin
			@(negedge Pclk)
			PRESET_n = 1'b0;
			
			@(negedge Pclk)
			PRESET_n = 1'b1;
			
		end
	endtask
	
	task initialize;
		begin
			PRESET_n = 1'b0;
			Padder = 3'b000;
			Pwrite = 1'b0;
			Psel = 1'b1;
			Penable = 1'b0;
			Pwdata = 8'b0;
			miso = 1'b0;
		end
	endtask
	
	task write_register(input [7:0] ctrl_reg1 , 
						input [7:0] ctrl_reg2 , 
						input [7:0] baud_reg 
					);
					
					begin
						@(negedge Pclk)
						Padder = 3'b000;
						Pwrite = 1'b1;
						Psel = 1'b1;
						Penable = 1'b0;
						Pwdata = ctrl_reg1;
						
						@(negedge Pclk)
						Padder = 3'b000;
						Pwrite = 1'b1;
						Psel = 1'b1;
						Penable = 1'b1;
						Pwdata = ctrl_reg1;
						
						@(negedge Pclk)
						wait(Pready)
						Penable = 1'b0;
						
						@(negedge Pclk)
						Padder = 3'b001;
						Pwrite = 1'b1;
						Psel = 1'b1;
						Penable = 1'b0;
						Pwdata = ctrl_reg2;
						
						@(negedge Pclk)
						Padder = 3'b001;
						Pwrite = 1'b1;
						Psel = 1'b1;
						Penable = 1'b1;
						Pwdata = ctrl_reg2;
						
						@(negedge Pclk)
						wait(Pready)
						Penable = 1'b0;
						
						@(negedge Pclk)
						Padder = 3'b010;
						Pwrite = 1'b1;
						Psel = 1'b1;
						Penable = 1'b0;
						Pwdata = baud_reg;
						
						@(negedge Pclk)
						Padder = 3'b010;
						Pwrite = 1'b1;
						Psel = 1'b1;
						Penable = 1'b1;
						Pwdata = baud_reg;
						
						@(negedge Pclk)
						wait(Pready)
						Penable = 1'b0;
					end
	endtask
	
	task write_data_reg(input [7:0] data_reg);
				begin
					@(negedge Pclk)
					Padder = 3'b101;
					Pwrite = 1'b1;
					Psel = 1'b1;
					Penable = 1'b0;
					Pwdata = data_reg;
						
					@(negedge Pclk)
					Padder = 3'b101;
					Pwrite = 1'b1;
					Psel = 1'b1;
					Penable = 1'b1;
					Pwdata = data_reg;
						
					@(negedge Pclk)
					wait(Pready)
					Penable = 1'b0;
				
				end
	endtask
	
	task miso_data_neg_lsbe(input [7:0] data);
		begin
			miso = 1'b0;
			wait(~ss)
			for(i=0; i<=7; i=i+1)
				begin
					@(negedge Pclk)
					miso = data[i];
				end
		end
	endtask
	
	task miso_data_neg_lsbe0(input [7:0] data);
		begin
			miso = 1'b0;
			wait(~ss)
			for(i=7; i>=0; i=i-1)
				begin
					@(negedge Pclk)
					miso = data[i];
				end
		end
	endtask
	
	task miso_data_pos_lsbe(input [7:0] data);
		begin
			miso = 1'b0;
			wait(~ss)
			for(j=0; j<=7; j=j+1)
				begin
					@(posedge Pclk)
					miso = data[i];
				end
		end
	endtask
	
	task miso_data_pos_lsbe0(input [7:0] data);
		begin
			miso = 1'b0;
			wait(~ss)
			for(i=7; j>=0; j=j-1)
				begin
					@(posedge Pclk)
					miso = data[i];
				end
		end
	endtask
	
	task read_register(input [2:0] address);
		begin
			@(negedge Pclk)
			Padder = address;
			Pwrite = 1'b0;
			Psel = 1'b1;
			Penable = 1'b0;
			
			@(negedge Pclk)
			Padder = address;
			Pwrite = 1'b0;
			Psel = 1'b1;
			Penable = 1'b1;
			
			@(negedge Pclk)
			wait(Pready)
			Penable = 1'b0;
		end
	endtask
	
	task read_ctrl1;
		begin
			read_register(3'b000);
		end
	endtask
	
	task read_ctrl2;
		begin
			read_register(3'b001);
		end
	endtask
	
	task read_baud;
		begin
			read_register(3'b010);
		end
	endtask
	
	task read_status;
		begin
			read_register(3'b011);
		end
	endtask
	
	task read_data;
		begin
			read_register(3'b101);
		end
	endtask
	
	initial
		begin
			initialize;
			reset;
			write_register(8'b01011111 , 8'b00000000 , 8'b000000001);
			write_data_reg(8'hAA);
			miso_data_neg_lsbe(8'hFA);
			read_ctrl1;
			read_ctrl2;
			read_baud;
			read_status;
			read_data;
		
			#5000;
			$finish;
		end
		
endmodule
		