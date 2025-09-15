// Top-level module for a UART communication demonstration
// with manual inputs and LED outputs on the FPGA board.

module uart_top (
    input  wire        clk_50mhz,        // Onboard 50 MHz clock
    input  wire        rst_n,            // Active-low reset button
    
    // Manual inputs for the transmitter
    input  wire [7:0]  switches_in,      // 8-bit data from switches
    input  wire        btn_start_tx,     // Button to start transmission
    
    // Manual outputs for the receiver
    output wire [7:0]  leds_out,         // 8-bit output to LEDs
    output wire        led_data_valid,   // LED to show valid data received
    
    // UART I/O pins for communication with the microcontroller
    output wire        fpga_tx_out,      // Connect to microcontroller's RX
    input  wire        fpga_rx_in        // Connect to microcontroller's TX
);

    // Internal wires and registers
    wire        baud_clk_en;
    reg  [7:0]  tx_data;
    reg         tx_start_send;
    wire [7:0]  rx_data_from_receiver;
    wire        rx_data_valid_from_receiver;
    wire        command_received;

    // Instance of the baud rate generator
    baud_rate_generator #(
        .CLOCK_FREQ(50_000_000), // 50 MHz
        .BAUD_RATE(9600)
    ) i_baud_rate_generator (
        .clk(clk_50mhz),
        .rst_n(rst_n),
        .baud_clk_en(baud_clk_en)
    );

    // Instance of the UART transmitter
    uart_transmitter i_uart_transmitter (
        .clk(clk_50mhz),
        .rst_n(rst_n),
        .baud_clk_en(baud_clk_en),
        .tx_data(tx_data),
        .tx_start_send(tx_start_send),
        .tx_out(fpga_tx_out)
    );

    // Instance of the UART receiver
    uart_receiver i_uart_receiver (
        .clk(clk_50mhz),
        .rst_n(rst_n),
        .baud_clk_en(baud_clk_en),
        .rx_in(fpga_rx_in),
        .rx_data(rx_data_from_receiver),
        .rx_data_valid(rx_data_valid_from_receiver),
        .command_received(command_received)
    );
    
    // Logic to control the transmitter based on manual inputs and received commands
    always @(posedge clk_50mhz or negedge rst_n) begin
        if (!rst_n) begin
            tx_data <= 8'h00;
            tx_start_send <= 1'b0;
        end else begin
            // Manual transmission: When the button is pressed, send the switch data.
            if (btn_start_tx) begin
                tx_data <= switches_in;
                tx_start_send <= 1'b1;
            end 
            // Automatic response: When the command 'A' is received, send back 'B'.
            else if (command_received) begin
                tx_data <= 8'h42; // ASCII for 'B'
                tx_start_send <= 1'b1;
            end else begin
                tx_start_send <= 1'b0; // Reset transmit signal
            end
        end
    end

    // Assigning outputs to the physical LEDs on the board
    assign leds_out = rx_data_from_receiver;
    assign led_data_valid = rx_data_valid_from_receiver;

endmodule
