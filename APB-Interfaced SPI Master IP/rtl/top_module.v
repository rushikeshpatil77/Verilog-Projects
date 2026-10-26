module top_module(
	input Pclk , PRESET_n , 
	input [2:0] Padder,
	input Psel ,Penable , Pwrite,
	input [7:0] Pwdata,
	input miso,
	output [7:0] Prdata, 
	output Pready , Pslverr,
	output mosi ,
	output ss , sclk,
	output spi_interrupt_request
);
	
	wire miso_receive_pos_0 ;
	wire miso_receive_neg0_o ;
	wire mosi_send_neg0_o ;
	wire mosi_send_pos_0 ;
	wire [11:0] baudratedivisor;
	wire [1:0] spi_mode;
	wire spiswai;
	wire [3:0] sppr;
	wire [3:0] spr;
	wire cpol, cpha , rcv_d , send_data , lsbef;
	wire tip , mstr_o;
	wire [7:0] data_miso , data_mosi;
	
		baud_generator SPI1 (.Pclk(Pclk) , 
							.PRESET_n(PRESET_n) , 
							.spi_mode_i(spi_mode) ,
							.spiswai_i(spiswai) , 
							.sppr_i(sppr[2:0]) , 
							.spr_i(spr[2:0]) , 
							.cpol_i(cpol), 
							.cpha_i(cpha), 
							.ss_i(ss) , 
							.miso_receive_pos(miso_receive_pos_0), 
							.miso_receive_neg(miso_receive_neg0_o) , 
							.mosi_send_neg(mosi_send_neg0_o) , 
							.mosi_send_pos(mosi_send_pos_0) , 
							.baudratedivisor_o(baudratedivisor) ,
							.sclk_o(sclk)
						);
						
		spi_slave_control_select SPI2 (
								.Pclk(Pclk),
								.PRESET_n(PRESET_n),
								.mstr(mstr_o),
								.spiswai_i(spiswai),
								.spi_mode_i(spi_mode),
								.send_data_i(send_data),
								.baudratedivisor_o(baudratedivisor),
								.recieve_data_out(rcv_d),
								.ss_o(ss),
								.tip_out(tip)
								);
		
		shift_register SPI3 ( .Pclk(Pclk) , 
							 .PRESET_n(PRESET_n) , 
							 .ss_i(ss) , 
							 .send_data_i(send_data) , 
							 .lsbfe_i(lsbef) ,
							 .cpha_i(cpha), 
							 .cpol_i(cpol) , 
							 .mosi_send_neg(mosi_send_neg0_o) , 
							 .mosi_send_pos(mosi_send_pos_0) , 
							 .miso_receive_neg(miso_receive_neg0_o) , 
							 .miso_receive_pos(miso_receive_pos_0) , 
							 .data_mosi_i(data_mosi) , 
							 .miso_i(miso),
							 .receive_data_i(rcv_d) , 
							 .mosi_o(mosi) , 
							 .data_miso_o(data_miso)
							);
							
		APB_slave SP4 (	.Pclk(Pclk) , 
						.PRESET_n(PRESET_n) , 
						.Padder_i(Padder) , 
						.Pwrite_i(Pwrite) , 
						.Psel_i(Psel) , 
						.Penable_i(Penable) ,
						.Pwdata_i(Pwdata) , 
						.ss_i(ss), 
						.miso_data_i(data_miso) , 
						.receive_data_i(rcv_d) , 
						.tip_i(tip) , 
						.Prdata_o(Prdata) , 
						.mstr_o(mstr_o),
						.cpol_o(cpol),
						.cphase_o(cpha),
						.lsbe_o(lsbef),
						.spiswai_o(spiswai),
						.sppr_o(sppr) , 
						.spr_o(spr) , 
						.spi_interrupt_request_o(spi_interrupt_request) , 
						.Pready_o(Pready) , 
						.PSlaverr_o(Pslverr) , 
						.send_data_o(send_data) ,
						.mosi_data_o(data_mosi) , 
						.spi_mode_o(spi_mode)
					);
		
endmodule		

	