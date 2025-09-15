// This module receives a serial bitstream and converts it into 8-bit parallel data.
// It samples the input on the `baud_clk_en` pulse.

module uart_receiver (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        baud_clk_en,     // Single-cycle pulse at the baud rate
    input  wire        rx_in,           // Serial data input
    output reg  [7:0]  rx_data,         // Received 8-bit data
    output reg         rx_data_valid,    // Goes high for one cycle when data is ready
    output reg         command_received // Indicates a specific command was received
);

    // FSM states
    localparam [2:0] IDLE       = 3'b000;
    localparam [2:0] START_BIT  = 3'b001;
    localparam [2:0] DATA_BITS  = 3'b010;
    localparam [2:0] STOP_BIT   = 3'b011;

    // Internal registers
    reg [2:0] state;
    reg [3:0] bit_counter;
    reg [7:0] data_buffer;

    // Add a simple synchronizer to avoid metastability on the asynchronous input `rx_in`
    reg [1:0] rx_sync_reg;
    always @(posedge clk) begin
        rx_sync_reg[0] <= rx_in;
        rx_sync_reg[1] <= rx_sync_reg[0];
    end
    wire rx_in_synced = rx_sync_reg[1];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            rx_data_valid <= 1'b0;
            command_received <= 1'b0;
            bit_counter <= 4'b0;
            data_buffer <= 8'b0;
        end else begin
            rx_data_valid <= 1'b0; // Default to low
            command_received <= 1'b0; // Default to low

            case (state)
                IDLE: begin
                    if (rx_in_synced == 1'b0) begin // Detect a falling edge (start bit)
                        state <= START_BIT;
                        bit_counter <= 4'b0;
                    end
                end

                START_BIT: begin
                    if (baud_clk_en) begin
                        // Check if the start bit is still low at the middle of the bit period
                        if (rx_in_synced == 1'b0) begin
                            state <= DATA_BITS;
                        end else begin
                            state <= IDLE; // Spurious start bit, go back to idle
                        end
                    end
                end

                DATA_BITS: begin
                    if (baud_clk_en) begin
                        data_buffer[bit_counter] <= rx_in_synced; // Sample and store the bit
                        bit_counter <= bit_counter + 1'b1;
                        if (bit_counter == 8) begin
                            state <= STOP_BIT;
                        end
                    end
                end

                STOP_BIT: begin
                    if (baud_clk_en) begin
                        state <= IDLE;
                        rx_data <= data_buffer;
                        rx_data_valid <= 1'b1; // Signal that new data is available
                        // Check for a specific command, e.g., the ASCII character 'A'
                        if (data_buffer == 8'h41) begin
                            command_received <= 1'b1;
                        end
                    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end

endmodule
