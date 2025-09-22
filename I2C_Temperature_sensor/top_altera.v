`timescale 1ns / 1ps
module top_altera(
    input         CLK50MHZ,        // altera board clock
    input         reset,           // active high reset
    inout         TMP_SDA,         // i2c sda - bidirectional
    output        TMP_SCL,         // i2c scl
    output [6:0]  SEG,             
    output [3:0]  AN,              
    output [3:0]  NAN,             
    output [7:0]  LED              
    );

    wire sda_dir;                   
    wire w_200kHz;                  
    wire [7:0] w_data;              

    // Instantiate clkgen (50MHz -> 200kHz)
    clkgen_200kHz_altera cgen(
        .clk_50MHz(CLK50MHZ),
        .clk_200kHz(w_200kHz)
    );

    // Instantiate i2c master
    i2c_master_altera master(
        .clk_200kHz(w_200kHz),
        .reset(reset),
        .temp_data(w_data),
        .SDA(TMP_SDA),
        .SDA_dir(sda_dir),
        .SCL(TMP_SCL)
    );
    
    // Instantiate 7 segment control
    seg7_altera seg(
        .clk_50MHz(CLK50MHZ),
        .temp_data(w_data),
        .SEG(SEG),
        .NAN(NAN),
        .AN(AN)
    );
    
    assign LED = w_data;

endmodule
