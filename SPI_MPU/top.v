module top (
  input  wire clk,        // e.g., 50 MHz
  input  wire rst_n,
  input  wire spi_miso,
  output wire spi_clk,
  output wire spi_mosi,
  output wire cs_n,
  output wire [15:0] leds   // 16 LEDs
);

  wire new_sample;

  MPU_Temp_SPI_Controller #(.CLKS_PER_HALF_BIT(4), .SPI_MODE(0)) imu_temp (
    .i_Rst_L(rst_n),
    .i_Clk(clk),
    .i_start_reads(1'b1),   // always keep high for continuous reads
    .o_new_sample(new_sample),
    .o_leds(leds),
    .o_cs_n(cs_n),
    .o_SPI_Clk(spi_clk),
    .i_SPI_MISO(spi_miso),
    .o_SPI_MOSI(spi_mosi)
  );

endmodule
