module uart_receiver (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        baud_clk_en,
    input  wire        rx_in,
    output reg  [7:0]  rx_data,
    output reg         rx_data_valid,
    output reg         command_received
);

    localparam [2:0] IDLE      = 3'b000;
    localparam [2:0] START_BIT = 3'b001;
    localparam [2:0] DATA_BITS = 3'b010;
    localparam [2:0] STOP_BIT  = 3'b011;

    reg [2:0] state;
    reg [3:0] bit_counter;
    reg [7:0] data_buffer;

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
            bit_counter <= 0;
            data_buffer <= 0;
        end else begin
            rx_data_valid <= 1'b0;
            command_received <= 1'b0;

            case (state)
                IDLE: begin
                    if (rx_in_synced == 1'b0) begin
                        state <= START_BIT;
                        bit_counter <= 0;
                    end
                end

                START_BIT: begin
                    if (baud_clk_en) begin
                        if (rx_in_synced == 1'b0)
                            state <= DATA_BITS;
                        else
                            state <= IDLE;
                    end
                end

                DATA_BITS: begin
                    if (baud_clk_en) begin
                        data_buffer[bit_counter] <= rx_in_synced;
                        bit_counter <= bit_counter + 1'b1;
                        if (bit_counter == 8)
                            state <= STOP_BIT;
                    end
                end

                STOP_BIT: begin
                    if (baud_clk_en) begin
                        state <= IDLE;
                        rx_data <= data_buffer;
                        rx_data_valid <= 1'b1;
                        if (data_buffer == 8'h41) // 'A'
                            command_received <= 1'b1;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end
endmodule
