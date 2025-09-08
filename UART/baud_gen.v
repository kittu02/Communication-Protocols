module baud_gen #(
    parameter CLK_HZ = 50_000_000,  // FPGA clock frequency
    parameter BAUD   = 9600
)(
    input  wire clk,
    input  wire rst_n,
    output reg  tick
);
    localparam DIV = CLK_HZ / BAUD;
    reg [31:0] cnt;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt  <= 0;
            tick <= 1'b0;
        end else begin
            if (cnt == DIV-1) begin
                cnt  <= 0;
                tick <= 1'b1;
            end else begin
                cnt  <= cnt + 1;
                tick <= 1'b0;
            end
        end
    end
endmodule
