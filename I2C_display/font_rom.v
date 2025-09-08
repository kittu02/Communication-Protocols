module font_rom (
    input  wire [7:0] char_code,  // ASCII input
    input  wire [2:0] col_idx,    // column index (0–7)
    output reg  [7:0] col_bits    // 8 pixels for column
);

    always @(*) begin
        case (char_code)
            "H": case (col_idx)
                    0: col_bits = 8'b10010000;
                    1: col_bits = 8'b10010000;
                    2: col_bits = 8'b11110000;
                    3: col_bits = 8'b10010000;
                    4: col_bits = 8'b10010000;
                    default: col_bits = 8'b00000000;
                endcase
            "E": case (col_idx)
                    0: col_bits = 8'b11110000;
                    1: col_bits = 8'b10000000;
                    2: col_bits = 8'b11100000;
                    3: col_bits = 8'b10000000;
                    4: col_bits = 8'b11110000;
                    default: col_bits = 8'b00000000;
                endcase
            "L": case (col_idx)
                    0: col_bits = 8'b10000000;
                    1: col_bits = 8'b10000000;
                    2: col_bits = 8'b10000000;
                    3: col_bits = 8'b10000000;
                    4: col_bits = 8'b11110000;
                    default: col_bits = 8'b00000000;
                endcase
            "O": case (col_idx)
                    0: col_bits = 8'b01100000;
                    1: col_bits = 8'b10010000;
                    2: col_bits = 8'b10010000;
                    3: col_bits = 8'b10010000;
                    4: col_bits = 8'b01100000;
                    default: col_bits = 8'b00000000;
                endcase
            default: col_bits = 8'b00000000;
        endcase
    end
endmodule
