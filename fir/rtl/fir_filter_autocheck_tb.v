`timescale 1ns/10ps

module fir_filter_autocheck_tb;
	parameter width = 8;
	reg [width-1:0] fir_in;
	reg clk;
	reg [width-1:0] w_1;
	reg [width-1:0] w_2;
	reg [width-1:0] w_3;
	wire [2*width-1:0] fir_out;
	reg dut_error;
	reg [71:0] input_data;
	integer i;
	
	fir_filter I1(
	.fir_in(fir_in),
	.clk(clk),
	.w_1(w_1),
	.w_2(w_2),
	.w_3(w_3),
	.fir_out(fir_out)
	);

	event terminate_sim;

	initial begin
		$display ("###################################################");
		fir_in = 8'b1111_1111;
		clk = 1'b0;
		w_1 = 8'b0101_1011;
		w_2 = 8'b1111_1111;
		w_3 = 8'b1000_0111;
		dut_error = 1'b0;
		input_data = 72'h00_00_00_00_FF_00_FF_XX_XX;
		#500 -> terminate_sim;
		//$shm_close();
		//$stop;
	end

	always begin
		#25 clk = !clk;
	end	

	initial begin
		#50 fir_in = 8'b0000_0000;
		#50 fir_in = 8'b1111_1111;
		#50 fir_in = 8'b0000_0000;
	end
	
	initial
	@ (terminate_sim)  begin
	 $display ("Terminating simulation");
	 if (dut_error == 1'b0) begin
	   $display ("Simulation Result : PASSED");
	 end
	 else begin
	   $display ("Simulation Result : FAILED");
	 end
	 $display ("###################################################");
	 #1 $finish;
	end


	reg [2*width-1:0] fir_out_compare;

	always @ (negedge clk) begin
	// Code the functionality of the DUT
		fir_out_compare <= w_1 * input_data[23:16] + w_2 * input_data[15:8] +  w_3 * input_data[7:0];
		input_data <= input_data >> 8;
		//$display("Time = %d Calc Value = %h Sim Value = %h",$time,fir_out_compare,fir_out);
	end

	always @ (negedge clk) begin
		if(fir_out != fir_out_compare) begin
			$display ("DUT ERROR AT TIME %d", $time);
			$display ("Expected value = %h Got value = %h",fir_out_compare,fir_out);
			dut_error=1;
			#5 -> terminate_sim;			
		end
	end

endmodule
