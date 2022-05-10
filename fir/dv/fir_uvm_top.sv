// Devin Bidstrup 2022
// UVM Top-Level Testbench for FIR Filter

`include "uvm_macros.svh"

//.......................................................
//DUT Interface
//.......................................................
interface fir_dut_if();
  parameter width = 8;
  
  logic [width-1:0] fir_in;
  logic clk;
  logic [width-1:0] w_1;
  logic [width-1:0] w_2;
  logic [width-1:0] w_3;	
  logic [2*width-1:0] fir_out;
endinterface: fir_dut_if


//.......................................................
// Top
//.......................................................
module top;

  import uvm_pkg::*;
  import fir_comp_pkg::*;
  
  fir_dut_if fir_dut_if1 ();
  
  fir_filter fir_dut (
	  .fir_in(fir_dut_if1.fir_in),
	  .clk(fir_dut_if1.clk),
	  .w_1(fir_dut_if1.w_1),
	  .w_2(fir_dut_if1.w_2),
	  .w_3(fir_dut_if1.w_3),
	  .fir_out(fir_dut_if1.fir_out)
	);

  // Clock and reset generator
  initial
  begin
    fir_dut_if1.clk = 0;
    forever #25 fir_dut_if1.clk = ~fir_dut_if1.clk;
  end

  initial
  begin: blk
    uvm_config_db #(virtual fir_dut_if)::set(null, "uvm_test_top", "dut_vi", fir_dut_if1);
    
    uvm_top.finish_on_completion  = 1;
    
    run_test("base_test");
  end

endmodule: top

