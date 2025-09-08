module font_rom (
    input  wire [7:0] char_code,  // ASCII
    input  wire [2:0] col_idx,    // column index (0–7)
    output reg  [7:0] col_bits
);
    reg [7:0] rom [0:2047];  // 256 chars × 8 columns

    initial begin
        $readmemh("font.hex", rom);  // load font data
    end

    always @(*) begin
        col_bits = rom[{char_code, col_idx}];
    end
endmodule
