// This module transmits 8-bit parallel data serially using the UART protocol.
// It uses a state machine to control the transmission sequence.

module uart_transmitter (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        baud_clk_en,     // Single-cycle pulse at the baud rate
    input  wire [7:0]  tx_data,         // 8-bit data to be transmitted
    input  wire        tx_start_send,   // Start transmission when high
    output reg         tx_out           // Serial data output
);

    // FSM states
    localparam [2:0] IDLE        = 3'b000;
    localparam [2:0] START_BIT   = 3'b001;
    localparam [2:0] DATA_BITS   = 3'b010;
    localparam [2:0] STOP_BIT    = 3'b011;

    // Internal registers
    reg [2:0] state;
    reg [3:0] bit_counter;
    reg [7:0] data_shifter;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            tx_out <= 1'b1; // TX line is high when idle
            bit_counter <= 4'b0;
        end else begin
            case (state)
                IDLE: begin
                    tx_out <= 1'b1;
                    if (tx_start_send) begin
                        state <= START_BIT;
                        data_shifter <= tx_data;
                        bit_counter <= 4'b0;
                    end
                end

                START_BIT: begin
                    if (baud_clk_en) begin
                        tx_out <= 1'b0; // Start bit (low)
                        state <= DATA_BITS;
                    end
                end

                DATA_BITS: begin
                    if (baud_clk_en) begin
                        tx_out <= data_shifter[bit_counter]; // LSB first
                        bit_counter <= bit_counter + 1'b1;
                        if (bit_counter == 8) begin
                            state <= STOP_BIT;
                        end
                    end
                end

                STOP_BIT: begin
                    if (baud_clk_en) begin
                        tx_out <= 1'b1; // Stop bit (high)
                        state <= IDLE;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
