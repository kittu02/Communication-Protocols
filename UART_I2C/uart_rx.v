module uart_rx(
    input wire clk,
    input wire rst_n,
    input wire rx,
    output reg [7:0] data_out,
    output reg data_valid
);
    parameter CLK_FREQ = 50000000;
    parameter BAUD_RATE = 9600;
    localparam integer CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;

    reg [15:0] clk_cnt = 0;
    reg [3:0] bit_idx = 0;
    reg [7:0] data_reg = 0;
    reg rx_d = 1;
    reg rx_busy = 0;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_cnt <= 0;
            bit_idx <= 0;
            data_reg <= 0;
            data_valid <= 0;
            rx_busy <= 0;
        end else begin
            data_valid <= 0;
            rx_d <= rx;

            if (!rx_busy && !rx_d) begin
                rx_busy <= 1;
                clk_cnt <= CLKS_PER_BIT/2;
                bit_idx <= 0;
            end else if (rx_busy) begin
                if (clk_cnt == CLKS_PER_BIT-1) begin
                    clk_cnt <= 0;
                    if (bit_idx < 8) begin
                        data_reg[bit_idx] <= rx_d;
                        bit_idx <= bit_idx + 1;
                    end else if (bit_idx == 8) begin
                        data_out <= data_reg;
                        data_valid <= 1;
                        rx_busy <= 0;
                    end
                end else
                    clk_cnt <= clk_cnt + 1;
            end
        end
    end
endmodule
