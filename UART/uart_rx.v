module uart_rx (
    input  wire clk,
    input  wire rst_n,
    input  wire tick,       // baud tick
    input  wire rx_i,       // UART RX line
    output reg  [7:0] data_o,
    output reg        valid_o
);
    reg [3:0] bit_cnt;
    reg [7:0] shreg;
    reg [1:0] state;

    localparam IDLE=0, START=1, DATA=2, STOP=3;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state   <= IDLE;
            bit_cnt <= 0;
            shreg   <= 0;
            valid_o <= 0;
        end else begin
            valid_o <= 0;
            case (state)
                IDLE:  if (!rx_i) state <= START; // detect start
                START: if (tick) state <= DATA;
                DATA:  if (tick) begin
                           shreg <= {rx_i, shreg[7:1]};
                           if (bit_cnt == 7) begin
                               bit_cnt <= 0;
                               state <= STOP;
                           end else bit_cnt <= bit_cnt + 1;
                       end
                STOP:  if (tick) begin
                           data_o  <= shreg;
                           valid_o <= 1;
                           state   <= IDLE;
                       end
            endcase
        end
    end
endmodule
