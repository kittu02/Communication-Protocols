module uart_transmitter (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        baud_clk_en,
    input  wire [7:0]  tx_data,
    input  wire        tx_start_send,
    output reg         tx_out
);

    localparam [2:0] IDLE      = 3'b000;
    localparam [2:0] START_BIT = 3'b001;
    localparam [2:0] DATA_BITS = 3'b010;
    localparam [2:0] STOP_BIT  = 3'b011;

    reg [2:0] state;
    reg [3:0] bit_counter;
    reg [7:0] data_shifter;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            tx_out <= 1'b1;
            bit_counter <= 0;
        end else begin
            case (state)
                IDLE: begin
                    tx_out <= 1'b1;
                    if (tx_start_send) begin
                        state <= START_BIT;
                        data_shifter <= tx_data;
                        bit_counter <= 0;
                    end
                end

                START_BIT: begin
                    if (baud_clk_en) begin
                        tx_out <= 1'b0;
                        state <= DATA_BITS;
                    end
                end

                DATA_BITS: begin
                    if (baud_clk_en) begin
                        tx_out <= data_shifter[bit_counter];
                        bit_counter <= bit_counter + 1'b1;
                        if (bit_counter == 8)
                            state <= STOP_BIT;
                    end
                end

                STOP_BIT: begin
                    if (baud_clk_en) begin
                        tx_out <= 1'b1;
                        state <= IDLE;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end
endmodule
