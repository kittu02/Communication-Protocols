// Echo version
module top_uart_fpga (
    input  wire clk,        // 50 MHz FPGA clock (Pin 42)
    input  wire rst_n,      // push-button KEY0 (Pin 3), active-low
    input  wire uart_rx_i,  // from Arduino TX
    output wire uart_tx_o,  // to Arduino RX
    output reg  led         // user LED
);
    // baud generator
    wire tick;
    baud_gen #(.CLK_HZ(50_000_000), .BAUD(9600)) BAUD (
        .clk(clk), .rst_n(rst_n), .tick(tick)
    );

    // receiver
    wire [7:0] rx_data;
    wire rx_valid;
    uart_rx RX (
        .clk(clk), .rst_n(rst_n), .tick(tick),
        .rx_i(uart_rx_i), .data_o(rx_data), .valid_o(rx_valid)
    );

    // transmitter
    reg [7:0] tx_data;
    reg start_tx;
    wire tx_busy;
    uart_tx TX (
        .clk(clk), .rst_n(rst_n), .tick(tick),
        .data_i(tx_data), .start_i(start_tx),
        .tx_o(uart_tx_o), .busy_o(tx_busy)
    );

    // simple logic: echo received byte, toggle LED if 'A' received,
    // transmit 'C' if 'B' is received
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            led <= 0;
            start_tx <= 0;
            tx_data <= 8'h00;
        end else begin
            start_tx <= 0;
            if (rx_valid) begin
                if (rx_data == "A") begin
                    // If 'A' is received, toggle LED and echo 'A'
                    led <= ~led;
                    tx_data <= rx_data;
                end else if (rx_data == "B") begin
                    // If 'B' is received, transmit 'C'
                    tx_data <= "C";
                end else begin
                    // For all other characters, simply echo the received byte
                    tx_data <= rx_data;
                end
                start_tx <= 1; // Always start transmission after a valid byte is received
            end
        end
    end
endmodule
