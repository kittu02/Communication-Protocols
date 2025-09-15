// MPU_Temp_SPI_Controller.v
// Simplified top-level controller for MPU9250/6500
// - Reads only 2 bytes (TEMP_OUT_H/L) starting at 0x41
// - Outputs raw signed 16-bit temperature value to LEDs

module MPU_Temp_SPI_Controller
  #(
    parameter CLKS_PER_HALF_BIT = 4,   // adjust per your i_Clk frequency to get desired SPI speed
    parameter SPI_MODE = 0            // use mode 0 (or set to 3 if needed)
   )
   (
    input  wire        i_Rst_L,
    input  wire        i_Clk,

    // Control
    input  wire        i_start_reads,   // trigger continuous reads
    output reg         o_new_sample,    // pulses 1 clk when new sample available

    // LED output (raw temperature value)
    output reg signed [15:0] o_leds,

    // SPI pins
    output reg        o_cs_n,        // active low CS to MPU
    output wire       o_SPI_Clk,
    input  wire       i_SPI_MISO,
    output wire       o_SPI_MOSI
   );

  // local wires to/from SPI_Master
  reg        m_i_TX_DV;
  reg [7:0]  m_i_TX_Byte;
  wire       m_o_TX_Ready;
  wire       m_o_RX_DV;
  wire [7:0] m_o_RX_Byte;

  // instantiate your SPI_Master
  SPI_Master #(.SPI_MODE(SPI_MODE), .CLKS_PER_HALF_BIT(CLKS_PER_HALF_BIT)) spi_master_inst (
    .i_Rst_L(i_Rst_L),
    .i_Clk(i_Clk),

    .i_TX_Byte(m_i_TX_Byte),
    .i_TX_DV(m_i_TX_DV),
    .o_TX_Ready(m_o_TX_Ready),

    .o_RX_DV(m_o_RX_DV),
    .o_RX_Byte(m_o_RX_Byte),

    .o_SPI_Clk(o_SPI_Clk),
    .i_SPI_MISO(i_SPI_MISO),
    .o_SPI_MOSI(o_SPI_MOSI)
  );

  // MPU registers
  localparam ADDR_TEMP_OUT_H = 8'h41;
  localparam ADDR_PWR_MGMT_1 = 8'h6B;
  localparam READ_FLAG       = 8'h80;

  // states
  localparam S_BOOT        = 3'd0,
             S_INIT_WAIT   = 3'd1,
             S_INIT_WRITEA = 3'd2,
             S_INIT_WRITEB = 3'd3,
             S_IDLE        = 3'd4,
             S_SEND_ADDR   = 3'd5,
             S_BURST_READ  = 3'd6,
             S_DONE_STORE  = 3'd7;

  reg [2:0] state;

  // counters
  reg [2:0] rx_count;
  reg [15:0] delay_cnt;

  // storage of incoming bytes (2 bytes only)
  reg [7:0] rx_buf [0:1];

  // -----------------------------------------------------------------------
  // FSM
  // -----------------------------------------------------------------------
  integer i;
  always @(posedge i_Clk or negedge i_Rst_L) begin
    if (~i_Rst_L) begin
      state <= S_BOOT;
      m_i_TX_DV <= 1'b0;
      m_i_TX_Byte <= 8'h00;
      o_cs_n <= 1'b1;
      rx_count <= 3'd0;
      o_new_sample <= 1'b0;
      delay_cnt <= 16'd0;
      o_leds <= 16'd0;
      for (i=0; i<2; i=i+1) rx_buf[i] <= 8'h00;
    end
    else begin
      m_i_TX_DV <= 1'b0;
      o_new_sample <= 1'b0;

      // capture received bytes
      if (m_o_RX_DV && rx_count < 2) begin
        rx_buf[rx_count] <= m_o_RX_Byte;
        rx_count <= rx_count + 1'b1;
      end

      // FSM
      case (state)
        S_BOOT: begin
          delay_cnt <= 16'd1000; // startup delay
          state <= S_INIT_WAIT;
        end

        S_INIT_WAIT: begin
          if (delay_cnt != 0) delay_cnt <= delay_cnt - 1;
          else state <= S_INIT_WRITEA;
        end

        // send PWR_MGMT_1 address (write)
        S_INIT_WRITEA: begin
          o_cs_n <= 1'b0;
          if (m_o_TX_Ready) begin
            m_i_TX_Byte <= ADDR_PWR_MGMT_1;
            m_i_TX_DV <= 1'b1;
            state <= S_INIT_WRITEB;
          end
        end

        // send wake-up data
        S_INIT_WRITEB: begin
          if (m_o_TX_Ready) begin
            m_i_TX_Byte <= 8'h00; // wake up
            m_i_TX_DV <= 1'b1;
            o_cs_n <= 1'b1;
            state <= S_IDLE;
          end
        end

        S_IDLE: begin
          o_cs_n <= 1'b1;
          if (i_start_reads) begin
            rx_count <= 0;
            o_cs_n <= 1'b0;
            state <= S_SEND_ADDR;
          end
        end

        S_SEND_ADDR: begin
          if (m_o_TX_Ready) begin
            m_i_TX_Byte <= (ADDR_TEMP_OUT_H | READ_FLAG);
            m_i_TX_DV <= 1'b1;
            rx_count <= 0;
            state <= S_BURST_READ;
          end
        end

        S_BURST_READ: begin
          if (rx_count < 2) begin
            if (m_o_TX_Ready) begin
              m_i_TX_Byte <= 8'h00; // dummy byte
              m_i_TX_DV <= 1'b1;
            end
          end else begin
            o_cs_n <= 1'b1;
            state <= S_DONE_STORE;
          end
        end

        S_DONE_STORE: begin
          o_leds <= {rx_buf[0], rx_buf[1]}; // show raw temp on LEDs
          o_new_sample <= 1'b1;
          state <= S_IDLE;
        end
      endcase
    end
  end

endmodule
