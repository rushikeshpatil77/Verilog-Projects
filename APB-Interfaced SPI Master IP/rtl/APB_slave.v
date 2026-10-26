
module APB_slave (
    input Pclk,
    input PRESET_n,
    input [2:0] Padder_i,
    input Pwrite_i,
    input Psel_i,
    input Penable_i,
    input [7:0] Pwdata_i,
    input ss_i,
    input [7:0] miso_data_i,
    input receive_data_i,
    input tip_i,
    output reg [7:0] Prdata_o,
    output mstr_o, cpol_o, cphase_o, lsbe_o, spiswai_o,
    output [3:0] sppr_o,
    output [3:0] spr_o,
    output reg spi_interrupt_request_o,
    output Pready_o, PSlaverr_o,
    output reg send_data_o,
    output reg [7:0] mosi_data_o,
    output reg [1:0] spi_mode_o
);

    reg [7:0] spi_cr1, spi_cr2, spi_br, spi_dr;
    wire [7:0] spi_sr;

    wire rd_en, wr_en;

    wire spie, spe, sptie, ssoe;
    wire modfen;
    wire spif, sptef, modf;
	 
	

    parameter IDLE = 2'b00,
              SETUP = 2'b01,
              ENABLE = 2'b10;

    parameter RUN = 2'b00,
              WAIT = 2'b01,
              STOP = 2'b10;
			  
	reg [ 1 : 0 ]state, next_state;
	
	always@(posedge Pclk or negedge PRESET_n) begin
		if(!PRESET_n)begin
			state <= IDLE;
		end
		else begin
			state <= next_state;
		end
	end
	
	always@(*) begin
		case(state)
		
		IDLE:	begin	if(Psel_i && !Penable_i)
							next_state = SETUP;
						else
							next_state = IDLE;
				end
				
		SETUP:	begin	if(!Psel_i)
							next_state = IDLE;
						else if (Psel_i && Penable_i)
							next_state = ENABLE;
						else
							next_state = SETUP;
				end
				
		ENABLE:	begin	if(!Psel_i)
							next_state = IDLE;
						else if (Psel_i && !Penable_i)
							next_state = SETUP;
						else
							next_state = ENABLE;
				end
		
		default: next_state = IDLE;
	endcase
end

reg [1:0] n_mode;

	always@(posedge Pclk or negedge PRESET_n) begin
		if(!PRESET_n)begin
			spi_mode_o <= RUN;
		end
		else begin
			spi_mode_o <= n_mode;
		end
	end
	
	always@(*) begin
		case(spi_mode_o)
			
			RUN:	begin	if(!spe)
								n_mode = WAIT;
							else
								n_mode = RUN;
					end
			
			WAIT:	begin	if(spiswai_o)
								n_mode = STOP;
							else if (spe)
								n_mode = RUN;
							else
								n_mode = WAIT;
					end
					
			STOP:	begin	if(spe)
								n_mode = RUN;
							else if(!spiswai_o)
								n_mode = WAIT;
							else
								n_mode = STOP;
					end
					
			default: n_mode = RUN;
		endcase
	end

    assign Pready_o = (state == ENABLE) ? 1'b1 : 1'b0;
    assign PSlaverr_o = (state == ENABLE) ? (~tip_i) : 1'b0;

    assign rd_en = ((!Pwrite_i) && (state == ENABLE)) ? 1'b1 : 1'b0;
    assign wr_en = ((Pwrite_i) && (state == ENABLE)) ? 1'b1 : 1'b0;

    assign mstr_o = spi_cr1[4];
    assign cpol_o = spi_cr1[3];
    assign cphase_o = spi_cr1[2];
    assign lsbe_o = spi_cr1[0];

    assign spie = spi_cr1[7];
    assign spe = spi_cr1[6];
    assign sptie = spi_cr1[5];
    assign modfen = spi_cr2[4];
    assign spiswai_o = spi_cr2[1];

    assign sppr_o = spi_br[6:4];
    assign spr_o = spi_br[2:0];
    assign ssoe = spi_cr1[1];

    assign modf = ((!ss_i) & mstr_o & modfen & (!ssoe));

    assign sptef = (spi_dr == 8'b0000_0000) ? 1'b1 : 1'b0;
    assign spif = (spi_dr != 8'b0000_0000) ? 1'b1 : 1'b0;

    assign spi_sr = (!PRESET_n) ? 8'b0010_0000 :
                    {spif, 1'b0, sptef, modf, 4'b0};

    parameter cr2_mask = 8'b0001_1011;
    parameter br_mask = 8'b0111_0111;

    always @(posedge Pclk or negedge PRESET_n) begin
        if (!PRESET_n) begin
            spi_cr1 <= 8'h04;
        end
        else begin
            if (wr_en) begin
                if (Padder_i == 3'b000) begin
                    spi_cr1 <= Pwdata_i;
                end
                else begin
                    spi_cr1 <= spi_cr1;
                end
            end
            else begin
                spi_cr1 <= spi_cr1;
            end
        end
    end

    always @(posedge Pclk or negedge PRESET_n) begin
        if (!PRESET_n) begin
            spi_cr2 <= 8'h00;
        end
        else begin
            if (wr_en) begin
                spi_cr2 <= 8'h00;
                if (Padder_i == 3'b001) begin
                    spi_cr2 <= Pwdata_i & cr2_mask;
                end
                else begin
                    spi_cr2 <= spi_cr2;
                end
            end
            else begin
                spi_cr2 <= spi_cr2;
            end
        end
    end

    always @(posedge Pclk or negedge PRESET_n) begin
        if (!PRESET_n) begin
            spi_br <= 8'h00;
        end
        else begin
            if (wr_en) begin
                if (Padder_i == 3'b010) begin
                    spi_br <= Pwdata_i & br_mask;
                end
                else begin
                    spi_br <= spi_br;
                end
            end
            else begin
                spi_br <= spi_br;
            end
        end
    end

	always @(posedge Pclk or negedge PRESET_n) begin
        if (!PRESET_n) begin
            spi_dr <= 8'b0;
        end
        else begin
            if (wr_en) begin
                if (Padder_i == 3'b101) begin
                    spi_dr <= Pwdata_i;
                end
                else begin
                    spi_dr <= spi_dr;
                end
            end
            else begin
                if ((spi_dr == Pwdata_i) &&
                    (spi_dr != miso_data_i) &&
                    ((spi_mode_o == RUN) || (spi_mode_o == WAIT))) begin
                    spi_dr <= 8'b0;
                end
                else if (((spi_mode_o == RUN) || (spi_mode_o == WAIT)) &&
                        receive_data_i) begin      
                    spi_dr <= miso_data_i;
                end
                else begin
                    spi_dr <= spi_dr;
                end
            end
        end
    end


    always @(posedge Pclk or negedge PRESET_n) begin
        if (!PRESET_n) begin
            send_data_o <= 1'b0;
        end
        else begin
            if ((spi_dr == Pwdata_i) &&
                (spi_dr != miso_data_i) &&
                ((spi_mode_o == RUN) || (spi_mode_o == WAIT))) begin
				
                send_data_o <= 1'b1;
				
            end
            else begin
			
                send_data_o <= 1'b0;
				
            end
			
        end
    end

    always @(posedge Pclk or negedge PRESET_n) begin
        if (!PRESET_n) begin
            mosi_data_o <= 8'b0;
        end
        else begin
            if ((spi_dr == Pwdata_i) &&
                (spi_dr != miso_data_i) &&
                ((spi_mode_o == RUN) || (spi_mode_o == WAIT))) begin
                mosi_data_o <= spi_dr;
            end
            else begin
                mosi_data_o <= mosi_data_o;
            end
        end
    end

    always @(*) begin
        if (!spie && !sptie) begin
            spi_interrupt_request_o = 1'b0;
        end
        else begin
            if (!sptie && spie) begin
                spi_interrupt_request_o = spif | modf;
            end
            else begin
                if (!spie && sptie) begin
                    spi_interrupt_request_o = sptef;
                end
                else begin
                    spi_interrupt_request_o = spif | modf | sptef;
                end
            end
        end
    end

    always @(*) begin
        if (!rd_en) begin
            Prdata_o = 8'b0;
        end
        else begin
            case (Padder_i)
                3'b000: Prdata_o = spi_cr1;
                3'b001: Prdata_o = spi_cr2;
                3'b010: Prdata_o = spi_br;
                3'b011: Prdata_o = spi_sr;
                3'b100: Prdata_o = 8'b0;
                3'b101: Prdata_o = spi_dr;
                3'b110: Prdata_o = 8'b0;
                3'b111: Prdata_o = 8'b0;
                default: Prdata_o = 8'b0;
            endcase
        end
    end

endmodule
