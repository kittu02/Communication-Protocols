module uart_top (
    input  wire        clk_100mhz,       // 100 MHz onboard clock
    input  wire        rst_n,            // Active-low reset
    
    // input for Tx
    input  wire [7:0]  switches_in,      
    input  wire        btn_start_tx,     // Button to start tx
    
    // output for Rx 
    output wire [7:0]  leds_out,         
    output wire        led_data_valid,   // to show valid data 
    
    output wire        fpga_tx_out,      
    input  wire        fpga_rx_in       
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
        .CLOCK_FREQ(100_000_000), // 100 MHz
        .BAUD_RATE(9600)
    ) i_baud_rate_generator (
        .clk(clk_100mhz),
        .rst_n(rst_n),
        .baud_clk_en(baud_clk_en)
    );

    // Instance of the UART transmitter
    uart_transmitter i_uart_transmitter (
        .clk(clk_100mhz),
        .rst_n(rst_n),
        .baud_clk_en(baud_clk_en),
        .tx_data(tx_data),
        .tx_start_send(tx_start_send),
        .tx_out(fpga_tx_out)
    );

    // Instance of the UART receiver
    uart_receiver i_uart_receiver (
        .clk(clk_100mhz),
        .rst_n(rst_n),
        .baud_clk_en(baud_clk_en),
        .rx_in(fpga_rx_in),
        .rx_data(rx_data_from_receiver),
        .rx_data_valid(rx_data_valid_from_receiver),
        .command_received(command_received)
    );
    
    // Logic to control the transmitter based on manual inputs and received commands
    always @(posedge clk_100mhz or negedge rst_n) begin
        if (!rst_n) begin
            tx_data <= 8'h00;
            tx_start_send <= 1'b0;
        end else begin
            // Manual transmission
            if (btn_start_tx) begin
                tx_data <= switches_in;
                tx_start_send <= 1'b1;
            end 
            // if 'A' is received, send back 'B'.
            else if (command_received) begin
                tx_data <= 8'h42; // ASCII for 'B'
                tx_start_send <= 1'b1;
            end else begin
                tx_start_send <= 1'b0; // Reset transmit signal
            end
        end
    end

    // outputs to the physical LEDs
    assign leds_out = rx_data_from_receiver;
    assign led_data_valid = rx_data_valid_from_receiver;

endmodule
