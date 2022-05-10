`timescale 1ns/10ps

module fir_filter_tb;
	parameter width = 8;
	reg [width-1:0] fir_in;
	reg clk;
	reg [width-1:0] w_1;
	reg [width-1:0] w_2;
	reg [width-1:0] w_3;
	wire [2*width-1:0] fir_out;

	fir_filter I1(
	.fir_in(fir_in),
	.clk(clk),
	.w_1(w_1),
	.w_2(w_2),
	.w_3(w_3),
	.fir_out(fir_out)
	);

	initial begin
		$stop;
		//$shm_open();
		//$shm_probe(fir_in, w_1, w_2, w_3, fir_out);
		fir_in = 8'b1111_1111;
		clk = 1'b0;
		w_1 = 8'b0101_1011;
		w_2 = 8'b1111_1111;
		w_3 = 8'b1000_0111;
		#1000 $stop;
		//$shm_close();
	end

	initial begin
		$dumpfile("fir_filter.vcd");
		$dumpvars;
	end	

	always begin
		#25 clk = !clk;
	end	

	initial begin
		#50 fir_in = 8'b0000_0000;
		#50 fir_in = 8'b1111_1111;
		#50 fir_in = 8'b0000_0000;
	end
	
endmodule
