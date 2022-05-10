// Devin Bidstrup 2022
// UVM Config Objects for FIR Filter


package fir_cfg_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"
  
  //.......................................................
  // Agent
  //.......................................................
  class agt_config extends uvm_object;
    `uvm_object_utils(agt_config)

    //Config parameteres
    virtual fir_dut_if dut_vi;
    
    function new (string name = "");
      super.new(name);
    endfunction

  endclass : agt_config
  
  //.......................................................
  // Environment
  //.......................................................
  class env_config extends uvm_object;
    `uvm_object_utils(env_config)

    //Config parameteres
    virtual fir_dut_if dut_vi;
    
    function new (string name = "");
      super.new(name);
    endfunction

  endclass : env_config
  
  //.......................................................
  // Test
  //.......................................................
  class tst_config extends uvm_object;
    `uvm_object_utils(tst_config)

    //Config parameteres
    virtual fir_dut_if dut_vi;
    
    function new (string name = "");
      super.new(name);
    endfunction

  endclass : tst_config
  
endpackage : fir_cfg_pkg
