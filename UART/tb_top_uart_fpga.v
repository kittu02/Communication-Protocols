`timescale 1ns / 1ps

module tb_updated_uart_fpga;

    // Parameters for the testbench
    localparam CLK_HZ = 50_000_000;
    localparam BAUD   = 9600;
    localparam CLK_PERIOD = 1_000_000_000 / CLK_HZ; // 20 ns
    localparam BIT_PERIOD = 1_000_000_000 / BAUD; // ~104167 ns

    // Testbench signals
    reg clk;
    reg rst_n;
    reg uart_rx_i;
    wire uart_tx_o;
    wire led;

    // Instantiate the top-level module (DUT)
    top_uart_fpga DUT (
        .clk(clk),
        .rst_n(rst_n),
        .uart_rx_i(uart_rx_i),
        .uart_tx_o(uart_tx_o),
        .led(led)
    );

    // Clock generation
    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    // Test stimulus
    initial begin
        // Initialize signals
        $dumpfile("tb_updated_uart_fpga.vcd");
        $dumpvars(0, tb_updated_uart_fpga);
        $display("Starting simulation of the updated design...");
        rst_n = 1'b0;      // Assert active-low reset
        uart_rx_i = 1'b1;  // Idle high

        #100; // Wait for a moment to establish signals
        rst_n = 1'b1; // De-assert reset
        $display("Reset released. Starting tests.");

        // --- Test Case 1: Send 'A' (ASCII 65, 8'b01000001) ---
        // This should toggle the LED and echo 'A'.
        #2_000_000;
        $display("Time %0t: Test 1: Transmitting 'A'. Expect LED toggle and 'A' echo.", $time);
        
        // Start bit
        uart_rx_i = 1'b0;
        #(BIT_PERIOD);
        
        // Data bits (LSB first: 10000010)
        uart_rx_i = 1'b1; // Bit 0
        #(BIT_PERIOD);
        uart_rx_i = 1'b0; // Bit 1
        #(BIT_PERIOD);
        uart_rx_i = 1'b0; // Bit 2
        #(BIT_PERIOD);
        uart_rx_i = 1'b0; // Bit 3
        #(BIT_PERIOD);
        uart_rx_i = 1'b0; // Bit 4
        #(BIT_PERIOD);
        uart_rx_i = 1'b0; // Bit 5
        #(BIT_PERIOD);
        uart_rx_i = 1'b1; // Bit 6
        #(BIT_PERIOD);
        uart_rx_i = 1'b0; // Bit 7
        #(BIT_PERIOD);
        
        // Stop bit
        uart_rx_i = 1'b1;
        #(BIT_PERIOD);
        
        $display("Time %0t: Transmission of 'A' complete. Waiting for echo and LED change.", $time);
        
        // --- Test Case 2: Send 'B' (ASCII 66, 8'b01000010) ---
        // This should transmit 'C' (ASCII 67, 8'b01000011) and not toggle the LED.
        #5_000_000;
        $display("Time %0t: Test 2: Transmitting 'B'. Expect 'C' echo and no LED change.", $time);
        
        // Start bit
        uart_rx_i = 1'b0;
        #(BIT_PERIOD);
        
        // Data bits (LSB first: 01000010)
        uart_rx_i = 1'b0; // Bit 0
        #(BIT_PERIOD);
        uart_rx_i = 1'b1; // Bit 1
        #(BIT_PERIOD);
        uart_rx_i = 1'b0; // Bit 2
        #(BIT_PERIOD);
        uart_rx_i = 1'b0; // Bit 3
        #(BIT_PERIOD);
        uart_rx_i = 1'b0; // Bit 4
        #(BIT_PERIOD);
        uart_rx_i = 1'b0; // Bit 5
        #(BIT_PERIOD);
        uart_rx_i = 1'b1; // Bit 6
        #(BIT_PERIOD);
        uart_rx_i = 1'b0; // Bit 7
        #(BIT_PERIOD);
        
        // Stop bit
        uart_rx_i = 1'b1;
        #(BIT_PERIOD);

        $display("Time %0t: Transmission of 'B' complete. Waiting for echo of 'C'.", $time);

        // --- Test Case 3: Send 'D' (ASCII 68) ---
        // This should just echo 'D' and not affect the LED.
        #5_000_000;
        $display("Time %0t: Test 3: Transmitting 'D'. Expect 'D' echo.", $time);
        
        // Start bit
        uart_rx_i = 1'b0;
        #(BIT_PERIOD);
        
        // Data bits (LSB first: 01000100)
        uart_rx_i = 1'b0; // Bit 0
        #(BIT_PERIOD);
        uart_rx_i = 1'b0; // Bit 1
        #(BIT_PERIOD);
        uart_rx_i = 1'b1; // Bit 2
        #(BIT_PERIOD);
        uart_rx_i = 1'b0; // Bit 3
        #(BIT_PERIOD);
        uart_rx_i = 1'b0; // Bit 4
        #(BIT_PERIOD);
        uart_rx_i = 1'b0; // Bit 5
        #(BIT_PERIOD);
        uart_rx_i = 1'b1; // Bit 6
        #(BIT_PERIOD);
        uart_rx_i = 1'b0; // Bit 7
        #(BIT_PERIOD);
        
        // Stop bit
        uart_rx_i = 1'b1;
        #(BIT_PERIOD);
        
        $display("Time %0t: Transmission of 'D' complete. Waiting for echo.", $time);

        #10_000_000;
        $display("Simulation finished.");
        $finish;
    end

    // Monitor outputs
    initial begin
        $monitor("Time %0t: LED = %b, uart_tx_o = %b", $time, led, uart_tx_o);
    end

endmodule
