`timescale 1ns / 1ps
module clkgen_200kHz(
    input clk_50MHz,
    output clk_200kHz
    );
    
    // 50e6 / 200e3 / 2 = 125  => counter from 0..124
    reg [7:0] counter = 8'h00;
    reg clk_reg = 1'b1;
    
    always @(posedge clk_50MHz) begin
        if(counter == 8'd124) begin
            counter <= 8'h00;
            clk_reg <= ~clk_reg;
        end
        else
            counter <= counter + 1;
    end
    
    assign clk_200kHz = clk_reg;
    
endmodule