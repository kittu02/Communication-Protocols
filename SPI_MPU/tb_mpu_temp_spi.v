`timescale 1ns/1ps

module tb_mpu_temp_spi;

    reg clk;
    reg rst_n;
    reg start_reads;
    wire cs_n, sclk, mosi;
    reg miso;
    wire [15:0] leds;
    wire new_sample;

    // Instantiate DUT
    MPU_Temp_SPI_Controller dut (
        .i_Clk(clk),
        .i_Rst_L(rst_n),
        .i_start_reads(start_reads),
        .o_cs_n(cs_n),
        .o_SPI_Clk(sclk),
        .o_SPI_MOSI(mosi),
        .i_SPI_MISO(miso),
        .o_leds(leds),
        .o_new_sample(new_sample)
    );

    // Clock gen (50 MHz)
    initial begin
        clk = 0;
        forever #10 clk = ~clk;  // 20ns period
    end

    // Reset + start
    initial begin
        rst_n = 0;
        start_reads = 0;
        #200;
        rst_n = 1;
        start_reads = 1;
    end

    // Dummy MPU-9250 SPI slave model
    // Sends back 0x01, 0x90 as TEMP_OUT_H/L when master sends 0xC1
    reg [7:0] dummy_mem [0:1];
    initial begin
        dummy_mem[0] = 8'h01; // TEMP_OUT_H
        dummy_mem[1] = 8'h90; // TEMP_OUT_L  -> 0x0190 = 400 decimal
                              // Temp ≈ 21 + (400/333.87) ≈ 22.2 °C
    end

    integer bit_cnt = 0;
    integer byte_cnt = 0;

    always @(negedge sclk or posedge cs_n) begin
        if (cs_n) begin
            bit_cnt <= 0;
            byte_cnt <= 0;
            miso <= 1'b0;
        end else begin
            if (byte_cnt < 2) begin
                miso <= dummy_mem[byte_cnt][7-bit_cnt];
                bit_cnt = bit_cnt + 1;
                if (bit_cnt == 8) begin
                    bit_cnt = 0;
                    byte_cnt = byte_cnt + 1;
                end
            end else begin
                miso <= 1'b0;
            end
        end
    end

    // Monitor outputs
    always @(posedge new_sample) begin
        $display("Time=%0t ns, LED output (temp_raw) = 0x%h", $time, leds);
    end

    initial begin
        #500000; // run sim
        $stop;
    end

endmodule
