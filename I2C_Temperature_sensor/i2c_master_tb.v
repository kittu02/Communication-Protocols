`timescale 1ns / 1ps

module i2c_master_TB;
	reg clk;
	reg reset;
	wire SDA;
	wire SDA_dir;
	wire SCL;
	
	i2c_master_altera master(
		.clk_200kHz(clk),
		.reset(reset),
		.SDA(SDA),
		.SDA_dir(SDA_dir),
		.SCL(SCL)
	);

	always #1 clk = !clk;
	
	initial begin
		$dumpfile("i2c_master.vcd") ;
		$dumpvars(0, i2c_master_TB) ;
	end
	
	initial begin
		clk = 1;
		reset = 0;
		
		#30000 $finish;
	end

endmodule