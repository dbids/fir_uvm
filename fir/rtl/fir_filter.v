`timescale 1ns/10ps

module fir_filter(fir_in, clk, w_1, w_2, w_3, fir_out);

	parameter width = 8;

	input [width-1:0] fir_in;
	input clk;
	input [width-1:0] w_1;
	input [width-1:0] w_2;
	input [width-1:0] w_3;	

	output [2*width-1:0] fir_out;

	reg [2*width-1:0] fir_out;

	reg [width-1:0] ff_out_1;
	reg [width-1:0] ff_out_2;
	reg [width-1:0] ff_out_3;

	wire [2*width-1:0] add_in_1;
	wire [2*width-1:0] add_in_2;
	wire [2*width-1:0] add_in_3;
	wire [2*width-1:0] add_out;

	always @ (posedge clk) begin
		ff_out_1 <= fir_in;
	end		
	assign add_in_1 = w_1 * ff_out_1;

	always @ (posedge clk) begin
		ff_out_2 <= ff_out_1;
	end
	assign add_in_2 = w_2 * ff_out_2;

	always @ (posedge clk) begin
		ff_out_3 <= ff_out_2;
	end
	assign add_in_3 = w_3 * ff_out_3;		

	assign add_out = add_in_1 + add_in_2 + add_in_3;

	always @ (posedge clk) begin
		fir_out <= add_out;
	end

endmodule
