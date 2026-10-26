module APB_slave_tb;
	reg Pclk;
	reg PRESET_n;
	reg [2:0] Padder_i;
	reg Pwrite_i;
	reg Psel_i;
	reg Penable_i;
	reg [7:0] Pwdata_i;
	reg ss_i;
	reg [7:0] miso_data_i;
	reg receive_data_i;
	reg tip_i;
	wire  [7:0] Prdata_o;
	wire mstr_o,cpol_o,cphase_o,lsbe_o,spiswai_o;
	wire [3:0] sppr_o;
	wire [3:0] spr_o;
	wire  spi_interrupt_request_o;
	wire Pready_o, PSlaverr_o;
	wire  send_data_o;
	wire  [7:0] mosi_data_o;
	wire  [1:0] spi_mode_o;
	
	APB_slave DUT (Pclk , PRESET_n , Padder_i , Pwrite_i , Psel_i , Penable_i , Pwdata_i , ss_i, 
					miso_data_i , receive_data_i , tip_i , Prdata_o , mstr_o,cpol_o,cphase_o,lsbe_o,spiswai_o,
					sppr_o , spr_o , spi_interrupt_request_o , Pready_o , PSlaverr_o , send_data_o ,mosi_data_o , spi_mode_o);
					
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
			Pclk = 1'b0;
			PRESET_n = 1'b0;
			Padder_i = 3'b000;
			Pwrite_i = 1'b0;
			Psel_i = 1'b0;            
			Penable_i = 1'b0;
			Pwdata_i = 8'd4;
			ss_i = 1'b1;
			miso_data_i = 8'b0;
			receive_data_i = 1'b0;    
			tip_i = 1'b0;
		end
	endtask
	
	task write_register(input[7:0] ctrl_reg1 , input[7:0] ctrl_reg2 , input [7:0] baud_reg);
		begin
		
			@(negedge Pclk)
			Psel_i = 1'b0;
			
			@(negedge Pclk)
			Padder_i = 3'b000;
			Pwrite_i = 1'b1;
			Psel_i = 1'b1;
			Penable_i = 1'b0;
			Pwdata_i = ctrl_reg1;
			 //SETUP PHASE
			
			@(negedge Pclk)
			Padder_i = 3'b000;
			Pwrite_i = 1'b1;
			Psel_i = 1'b1;
			Penable_i = 1'b1;
			Pwdata_i = ctrl_reg1;  //ENABLE PHASE
			
			@(negedge Pclk)
			wait(Pready_o)
			Penable_i = 1'b0; //IDLE PHASE
			
			
			@(negedge Pclk)
			Psel_i = 1'b0;
			
			@(negedge Pclk)
			Padder_i = 3'b001;
			Pwrite_i = 1'b1;
			Psel_i = 1'b1;
			Penable_i = 1'b0;
			Pwdata_i = ctrl_reg2;
			
			@(negedge Pclk)
			Padder_i = 3'b001;
			Pwrite_i = 1'b1;
			Psel_i = 1'b1;
			Penable_i = 1'b1;
			Pwdata_i = ctrl_reg2;
			
			@(negedge Pclk)
			wait(Pready_o)
			Penable_i = 1'b0;
			
			
			@(negedge Pclk)
			Psel_i = 1'b0;
			
			@(negedge Pclk)
			Padder_i = 3'b010;
			Pwrite_i = 1'b1;
			Psel_i = 1'b1;
			Penable_i = 1'b0;
			Pwdata_i = baud_reg;
			
			@(negedge Pclk)
			Padder_i = 3'b010;        
			Pwrite_i = 1'b1;
			Psel_i = 1'b1;
			Penable_i = 1'b1;
			Pwdata_i = baud_reg;
			
			@(negedge Pclk)
			wait(Pready_o)
			Penable_i = 1'b0;
			
			
		end
	endtask
	
	
	task write_data_reg(input [7:0] data_reg);
		begin
			@(negedge Pclk)
			Padder_i = 3'b101;
			Pwrite_i = 1'b1;
			Psel_i = 1'b1;
			Penable_i = 1'b0;
			Pwdata_i = data_reg;
			
			
			@(negedge Pclk)
			Padder_i = 3'b101;
			Pwrite_i = 1'b1;
			Psel_i = 1'b1;
			Penable_i = 1'b1;
			Pwdata_i = data_reg;
			
			@(negedge Pclk)
			wait(Pready_o)
			Penable_i = 1'b0;
			
		end
	endtask
	
	task read_registers(input [2:0] address);
		begin
			@(negedge Pclk)
			Padder_i = address;
			Pwrite_i = 1'b0;
			Psel_i = 1'b1;
			Penable_i = 1'b0;
			
			@(negedge Pclk)
			Padder_i = address;
			Pwrite_i = 1'b0;
			Psel_i = 1'b1;
			Penable_i = 1'b1;
			
			@(negedge Pclk)
			wait(Pready_o)
			Penable_i = 1'b0;
			
		end
	endtask
	
	task read_ctrl1;
		begin
			read_registers(3'b000);
		end
	endtask
	
	task read_ctrl2;
		begin
			read_registers(3'b001);
		end
	endtask
	
	task read_baud;
		begin
			read_registers(3'b010);
		end
	endtask
	
	task read_status;
		begin
			read_registers(3'b011);
		end
	endtask
	
	task read_data;
		begin
			read_registers(3'b101);
		end
	endtask
	
	task inputs;
		begin
			@(negedge Pclk)
			receive_data_i = 1'b0;
			miso_data_i = 8'h00;
			
			@(negedge Pclk)
			receive_data_i = 1'b1;
			miso_data_i = 8'hFA;
			
			@(negedge Pclk)
			receive_data_i = 1'b0;
			miso_data_i = 8'hFA;
		end
	endtask
	
	initial 
		begin
			initialize;
			reset;
			inputs;
			ss_i = 1'b0;
			tip_i = 1'b1;
			write_register(8'b01011101 , 8'b01100010 , 8'b00000001);
			write_data_reg(8'hAA);
			read_ctrl1;
			read_ctrl2;
			read_data;
			read_baud;
			read_status;
			
		#5000;
		$finish;
		
		end
	
endmodule