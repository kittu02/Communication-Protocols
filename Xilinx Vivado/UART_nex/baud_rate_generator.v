module baud_rate_generator #(
    parameter CLOCK_FREQ = 100_000_000, // 100 MHz default for Nexys4 DDR
    parameter BAUD_RATE  = 9600         // UART baud rate
)(
    input  wire clk,
    input  wire rst_n,
    output reg  baud_clk_en // One-cycle pulse at baud rate
);

    localparam COUNTER_LIMIT = (CLOCK_FREQ + BAUD_RATE/2) / BAUD_RATE - 1;

    reg [31:0] counter;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 0;
            baud_clk_en <= 1'b0;
        end else begin
            if (counter == COUNTER_LIMIT) begin
                counter <= 0;
                baud_clk_en <= 1'b1;
            end else begin
                counter <= counter + 1;
                baud_clk_en <= 1'b0;
            end
        end
    end

endmodule
