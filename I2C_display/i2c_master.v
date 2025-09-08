module i2c_master #(
    parameter I2C_ADDR = 7'h3C,     // OLED address
    parameter CLK_FREQ = 50000000,  // FPGA clk
    parameter I2C_FREQ = 400000     // I²C speed
)(
    input  wire clk,
    input  wire rst_n,
    input  wire start,
    input  wire [7:0] data,
    input  wire is_cmd,       // 1=command, 0=data
    output reg  busy,
    inout  wire sda,
    output reg  scl
);
    localparam CLK_DIV = CLK_FREQ/(I2C_FREQ*2);

    reg [15:0] clk_cnt;
    reg [3:0] bit_cnt;
    reg [9:0] shift_reg;
    reg sda_out, sda_oe;
    reg [2:0] state;

    assign sda = sda_oe ? sda_out : 1'bz;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            scl <= 1; busy <= 0; state <= 0;
            sda_out <= 1; sda_oe <= 0;
        end else begin
            if (clk_cnt < CLK_DIV) clk_cnt <= clk_cnt + 1;
            else begin
                clk_cnt <= 0;
                case (state)
                    0: if (start) begin
                           busy <= 1;
                           sda_out <= 0; sda_oe <= 1; // START
                           bit_cnt <= 7;
                           shift_reg <= {I2C_ADDR,1'b0};
                           state <= 1;
                       end
                    1: begin // Send address
                           scl <= 0;
                           sda_out <= shift_reg[bit_cnt];
                           if (bit_cnt == 0) state <= 2;
                           else bit_cnt <= bit_cnt - 1;
                           scl <= 1;
                       end
                    2: begin // Control byte
                           scl <= 0;
                           shift_reg <= is_cmd ? 8'h00 : 8'h40;
                           bit_cnt <= 7;
                           state <= 3;
                           scl <= 1;
                       end
                    3: begin // Send control
                           scl <= 0;
                           sda_out <= shift_reg[bit_cnt];
                           if (bit_cnt == 0) state <= 4;
                           else bit_cnt <= bit_cnt - 1;
                           scl <= 1;
                       end
                    4: begin // Data
                           scl <= 0;
                           shift_reg <= data;
                           bit_cnt <= 7;
                           state <= 5;
                           scl <= 1;
                       end
                    5: begin
                           scl <= 0;
                           sda_out <= shift_reg[bit_cnt];
                           if (bit_cnt == 0) state <= 6;
                           else bit_cnt <= bit_cnt - 1;
                           scl <= 1;
                       end
                    6: begin // STOP
                           scl <= 1;
                           sda_out <= 1;
                           busy <= 0;
                           state <= 0;
                       end
                endcase
            end
        end
    end
endmodule
