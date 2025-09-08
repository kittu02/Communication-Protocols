module top (
    input  wire clk,      // 50 MHz FPGA clock
    input  wire rst_n,
    inout  wire i2c_sda,
    output wire i2c_scl
);
    reg [7:0] test_char;
    reg test_valid;

    ssd1306_driver oled(
        .clk(clk), .rst_n(rst_n),
        .char_in(test_char), .char_valid(test_valid),
        .sda(i2c_sda), .scl(i2c_scl)
    );

    initial begin
        test_char = "H"; test_valid = 1; #1000000;
        test_char = "E"; test_valid = 1; #1000000;
        test_char = "L"; test_valid = 1; #1000000;
        test_char = "L"; test_valid = 1; #1000000;
        test_char = "O"; test_valid = 1;
    end
endmodule
