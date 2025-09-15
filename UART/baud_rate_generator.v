// This module generates a single-cycle pulse at the specified baud rate.
// This pulse is used by the TX and RX modules to time their operations.
// The CLOCK_FREQ and BAUD_RATE are passed as parameters from the top module.

module baud_rate_generator #(
    parameter CLOCK_FREQ = 50000000, // Default clock frequency in Hz (e.g., 50 MHz)
    parameter BAUD_RATE  = 9600      // Default baud rate in bits per second
) (
    input  wire clk,
    input  wire rst_n,
    output reg  baud_clk_en // One-cycle pulse at baud rate
);

    // Calculate the counter limit to achieve the desired baud rate.
    // The '+ BAUD_RATE/2' is for rounding.
    localparam COUNTER_LIMIT = (CLOCK_FREQ + BAUD_RATE/2) / BAUD_RATE - 1;

    // Internal counter for generating the baud rate pulse
    reg [15:0] counter;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 16'b0;
            baud_clk_en <= 1'b0;
        end else begin
            // Check if the counter has reached its limit
            if (counter == COUNTER_LIMIT) begin
                counter <= 16'b0;       // Reset the counter
                baud_clk_en <= 1'b1;    // Generate the pulse for one clock cycle
            end else begin
                counter <= counter + 1'b1; // Increment the counter
                baud_clk_en <= 1'b0;    // Pulse is low
            end
        end
    end

endmodule
