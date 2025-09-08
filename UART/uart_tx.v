module uart_tx (
    input  wire clk,
    input  wire rst_n,
    input  wire tick,         // from baud_gen
    input  wire [7:0] data_i, // byte to send
    input  wire start_i,      // pulse to start sending
    output reg  tx_o,         // UART TX line
    output reg  busy_o        // high while transmitting
);
    reg [3:0] bit_cnt;
    reg [9:0] shreg; // start + 8 data + stop

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tx_o    <= 1'b1; // idle high
            busy_o  <= 1'b0;
            bit_cnt <= 0;
            shreg   <= 10'b1111111111;
        end else begin
            if (!busy_o && start_i) begin
                shreg   <= {1'b1, data_i, 1'b0}; // stop, data, start
                busy_o  <= 1'b1;
                bit_cnt <= 0;
            end else if (busy_o && tick) begin
                tx_o    <= shreg[0];
                shreg   <= {1'b1, shreg[9:1]};
                bit_cnt <= bit_cnt + 1;
                if (bit_cnt == 9) busy_o <= 1'b0;
            end
        end
    end
endmodule
