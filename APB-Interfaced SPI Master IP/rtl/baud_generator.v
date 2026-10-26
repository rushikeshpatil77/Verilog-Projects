
module baud_generator (
    input Pclk,
    input PRESET_n,
    input [1:0] spi_mode_i,
    input spiswai_i,
    input [2:0] sppr_i,
    input [2:0] spr_i,
    input cpol_i, cpha_i, ss_i,
    output reg miso_receive_pos,
    output reg miso_receive_neg,
    output reg mosi_send_neg,
    output reg mosi_send_pos,
    output [11:0] baudratedivisor_o,
    output reg sclk_o
);

    reg [11:0] counter;
    wire pre_sclk_s;

    parameter RUN = 2'b00,
              WAIT = 2'b01,
              STOP = 2'b10;

    assign baudratedivisor_o = (sppr_i + 1) * 2 ** (spr_i + 1);

    assign pre_sclk_s = cpol_i ? 1'b1 : 1'b0;

    always @(posedge Pclk or negedge PRESET_n) begin
        if (!PRESET_n) begin
            counter <= 12'b0;
            sclk_o <= pre_sclk_s;
        end
        else if (((spi_mode_i == RUN) || (spi_mode_i == WAIT)) &&
                 (!ss_i) && (!spiswai_i)) begin

            if (counter == baudratedivisor_o / 2 - 1) begin
                sclk_o <= ~sclk_o;
                counter <= 12'b0;
            end
            else begin
                sclk_o <= sclk_o;
                counter <= counter + 1'b1;
            end
        end
        else begin
            sclk_o <= pre_sclk_s;
            counter <= 12'b0;
        end
    end

    always @(posedge Pclk or negedge PRESET_n) begin
        if (!PRESET_n) begin
            mosi_send_pos <= 1'b0;
            mosi_send_neg <= 1'b0;
        end
        else if (cpha_i != cpol_i) begin // 1 0 or 0 1
            if (sclk_o) begin
                if (counter == baudratedivisor_o / 2 - 2'b10) begin
                    mosi_send_neg <= 1'b1;
                end
                else begin
                    mosi_send_neg <= 1'b0;
                end
            end
            else begin
                mosi_send_neg <= 1'b0;
            end
        end
        else if (cpha_i == cpol_i) begin // 0 0 or 1 1
            if (!sclk_o) begin
                if (counter == baudratedivisor_o / 2 - 2'b10) begin
                    mosi_send_pos <= 1'b1;
                end
                else begin
                    mosi_send_pos <= 1'b0;
                end
            end
            else begin
                mosi_send_pos <= 1'b0;
            end
        end
        else begin
            mosi_send_neg <= 1'b0;
            mosi_send_pos <= 1'b0;
        end
    end

    always @(posedge Pclk or negedge PRESET_n) begin
        if (!PRESET_n) begin
            miso_receive_neg <= 1'b0;
            miso_receive_pos <= 1'b0;
        end
        else if (cpha_i != cpol_i) begin // 1 0 or 0 1
			miso_receive_pos <= 1'b0;
            if (sclk_o) begin
                if (counter == baudratedivisor_o / 2 - 1'b1) begin
                    miso_receive_neg <= 1'b1;
                end
                else begin
                    miso_receive_neg <= 1'b0;
                end
            end
            else begin
                miso_receive_neg <= 1'b0;
            end
        end
        else if (cpha_i == cpol_i) begin // 0 0 or 1 1
			miso_receive_neg <= 1'b0;
            if (!sclk_o) begin
                if (counter == baudratedivisor_o / 2 - 1'b1) begin
                    miso_receive_pos <= 1'b1;
                end
                else begin
                    miso_receive_pos <= 1'b0;
                end
            end
            else begin
                miso_receive_pos <= 1'b0;
            end
        end
        else begin
            miso_receive_neg <= 1'b0;
            miso_receive_pos <= 1'b0;
        end
    end

endmodule
