module top (
    input wire clk,        // 50 MHz FPGA clock
    input wire rst_n,
    input wire uart_rx_pin,
    inout wire i2c_sda,
    output wire i2c_scl
);
    wire [7:0] rx_data;
    wire rx_valid;

    uart_rx #(.CLK_FREQ(50000000), .BAUD_RATE(9600)) U_RX (
        .clk(clk), .rst_n(rst_n),
        .rx(uart_rx_pin),
        .data_out(rx_data),
        .data_valid(rx_valid)
    );

    ssd1306_driver U_OLED (
        .clk(clk), .rst_n(rst_n),
        .char_in(rx_data),
        .char_valid(rx_valid),
        .sda(i2c_sda),
        .scl(i2c_scl)
    );
endmodule
	