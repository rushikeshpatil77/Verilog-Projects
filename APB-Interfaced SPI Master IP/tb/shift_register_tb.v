module shift_register_tb;
	reg Pclk;
	reg PRESET_n;
	reg ss_i;
	reg send_data_i;
	reg lsbfe_i;
	reg cpha_i , cpol_i;
	wire mosi_send_neg;       //cpha_i = 0 , cpol_i = 1 or cpha_i = 1 , cpol_i = 0
	wire mosi_send_pos;       //cpha_i = 1 , cpol_i = 1 or cpha_i = 0 , cpol_i = 0
	wire miso_receive_neg;    //cpha_i = 0 , cpol_i = 1 or cpha_i = 1 , cpol_i = 0
	wire miso_receive_pos;    //cpha_i = 1 , cpol_i = 1 or cpha_i = 0 , cpol_i = 0
	reg [7:0] data_mosi_i;
	reg miso_i;
	reg receive_data_i;
	wire  mosi_o;
	wire [7:0] data_miso_o;
	

	
	shift_register DUT ( Pclk , PRESET_n , ss_i , send_data_i , lsbfe_i ,cpha_i , cpol_i , mosi_send_neg , mosi_send_pos , miso_receive_neg , miso_receive_pos , data_mosi_i , miso_i,
								receive_data_i , mosi_o , data_miso_o );
								
	wire [11:0] baudratedivisor_o;
	wire sclk_o ;
	reg [1:0] spi_mode_i;
	reg spiswai_i;
	reg [2:0] sppr_i;
	reg [2:0] spr_i;
	
	
	
	baud_generator BG1 (Pclk , PRESET_n , spi_mode_i ,spiswai_i , sppr_i , spr_i , cpol_i ,cpha_i , ss_i , miso_receive_pos , miso_receive_neg , mosi_send_neg , mosi_send_pos , baudratedivisor_o ,sclk_o);

	
initial 
	begin
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
		@(negedge Pclk)
		PRESET_n = 1'b0;
		ss_i = 1'b1;
		send_data_i = 1'b0;
		lsbfe_i = 1'b0;
		cpha_i = 1'b0;
		cpol_i = 1'b0;
		data_mosi_i = 8'd0;
		miso_i = 1'b0;
		receive_data_i = 1'b0;
		sppr_i = 3'b000;
		spr_i = 3'b000;
		spi_mode_i = 2'b00;
		spiswai_i = 1'b0;
	end
endtask
	
task stimulus;
	begin
		@(negedge Pclk)
		ss_i = 1'b0;
		spr_i = 3'b010;
		sppr_i = 3'b000;
		spi_mode_i = 2'b01;
		spiswai_i = 1'b0;
		cpha_i = 1'b1;
		cpol_i = 1'b1;
	end
endtask
	
task send_stimulus(input [7:0] data, input lsb);
		begin
			@(negedge Pclk)
			send_data_i = 1'b1;
			data_mosi_i = data;
			lsbfe_i = lsb;
			@(negedge Pclk)
			send_data_i = 1'b0;
		end
endtask

task receive_stimulus(input [7:0] data);
	integer i;
		begin
			miso_i = 1'b0;
			wait(~ss_i);
				for(i=0; i<=7; i=i+1)
					begin
					@(posedge sclk_o)
						begin
							miso_i <= data[7-i];
						end
					end
		end
endtask

task receive_data;
	begin
		@(posedge Pclk)
		receive_data_i = 1'b1;
		@(posedge Pclk)
		receive_data_i = 1'b0;
	end
endtask
		

initial begin
	initialize;
	reset;
	stimulus;
	send_stimulus(8'hFA , 1'b1);
	receive_stimulus(8'hAA);
	receive_data;
	
	end
			
	initial
	#5000 $finish();
	
endmodule