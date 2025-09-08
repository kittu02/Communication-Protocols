module ssd1306_driver (
    input  wire clk,
    input  wire rst_n,
    input  wire [7:0] char_in,
    input  wire char_valid,
    inout  wire sda,
    output wire scl
);
    reg [7:0] init_seq [0:23];
    reg [4:0] init_idx;
    reg init_done;
    wire busy;
    reg start;
    reg [7:0] data;
    reg is_cmd;

    initial begin
        init_seq[0]  = 8'hAE;
        init_seq[1]  = 8'h20; init_seq[2] = 8'h00;
        init_seq[3]  = 8'hB0;
        init_seq[4]  = 8'hC8;
        init_seq[5]  = 8'h00; init_seq[6] = 8'h10;
        init_seq[7]  = 8'h40;
        init_seq[8]  = 8'h81; init_seq[9] = 8'h7F;
        init_seq[10] = 8'hA1;
        init_seq[11] = 8'hA6;
        init_seq[12] = 8'hA8; init_seq[13] = 8'h3F;
        init_seq[14] = 8'hA4;
        init_seq[15] = 8'hD3; init_seq[16] = 8'h00;
        init_seq[17] = 8'hD5; init_seq[18] = 8'h80;
        init_seq[19] = 8'hD9; init_seq[20] = 8'hF1;
        init_seq[21] = 8'hDA; init_seq[22] = 8'h12;
        init_seq[23] = 8'hAF;
    end

    reg [2:0] col_idx;
    wire [7:0] font_bits;

    font_rom font(
        .char_code(char_in),
        .col_idx(col_idx),
        .col_bits(font_bits)
    );

    i2c_master I2C(
        .clk(clk), .rst_n(rst_n),
        .start(start), .data(data), .is_cmd(is_cmd),
        .busy(busy), .sda(sda), .scl(scl)
    );

    reg [2:0] state;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            init_idx <= 0; init_done <= 0;
            start <= 0; state <= 0;
        end else begin
            case (state)
                0: if (!busy && !init_done) begin
                        data <= init_seq[init_idx]; is_cmd <= 1;
                        start <= 1; state <= 1;
                    end
                1: begin start <= 0;
                        if (!busy) begin
                            if (init_idx == 23) begin
                                init_done <= 1; state <= 2;
                            end else begin
                                init_idx <= init_idx + 1; state <= 0;
                            end
                        end
                    end
                2: if (char_valid && init_done) begin
                        col_idx <= 0; state <= 3;
                    end
                3: if (!busy) begin
                        data <= font_bits; is_cmd <= 0;
                        start <= 1; state <= 4;
                    end
                4: begin start <= 0;
                        if (!busy) begin
                            if (col_idx == 4) state <= 2;
                            else begin col_idx <= col_idx + 1; state <= 3; end
                        end
                    end
            endcase
        end
    end
endmodule
