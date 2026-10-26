module baud_generator_tb;
	reg Pclk;
	reg PRESET_n;
	reg [1:0] spi_mode_i;
	reg spiswai_i;
	reg [2:0] sppr_i;
	reg [2:0] spr_i;
	reg cpol_i , cpha_i , ss_i;
	wire miso_receive_pos ;
	wire miso_receive_neg ;
	wire mosi_send_neg ;
	wire mosi_send_pos ;
	wire [11:0] baudratedivisor_o;
	wire sclk_o ;
	
	baud_generator DUT (Pclk , PRESET_n , spi_mode_i ,spiswai_i , sppr_i , spr_i , cpol_i ,cpha_i , ss_i , miso_receive_pos , miso_receive_neg , mosi_send_neg , mosi_send_pos , baudratedivisor_o ,sclk_o);
	
	initial begin
		Pclk = 1'b0;
		forever #5 Pclk = ~Pclk;
	end
	
	task reset;
		begin
			@(negedge Pclk);
			PRESET_n = 1'b0;
			
			@(negedge Pclk);
			PRESET_n = 1'b1;
		end
	endtask
	
	task initizalize;
		begin
			Pclk = 1'b0;
			PRESET_n = 1'b0;
			spi_mode_i = 2'b00;
			spiswai_i = 1'b0;
			sppr_i = 3'b000;
			spr_i = 3'b000;
			cpol_i = 1'b0;
			cpha_i = 1'b0;
			ss_i = 1'b1;
		end
	endtask
	
	task inputs (input[2:0] i , input[2:0] j , input x ,input y );
		begin
			spi_mode_i = 2'b01;
			sppr_i = i;
			spr_i = j;
			spiswai_i = 1'b0;
			cpol_i = x;
			cpha_i = y;
			ss_i = 1'b0;
		end
	endtask
	
	initial begin
		initizalize;
		reset;
		
		inputs (3'b001 , 3'b001 , 0 , 0);
		#200;
		inputs (3'b001 , 3'b001 , 0 , 1);
		
		#200;
		$finish;
		
		end
		
	endmodule
		