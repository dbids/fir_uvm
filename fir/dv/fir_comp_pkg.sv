// Devin Bidstrup 2022
// UVM Components for FIR Filter Testbench

package fir_comp_pkg;

  `include "uvm_macros.svh"
  import uvm_pkg::*;
  import fir_seq_pkg::*;
  import fir_cfg_pkg::*;

  //.......................................................
  // Sequencer
  //.......................................................
  typedef uvm_sequencer #(my_transaction) my_sequencer;

  //.......................................................
  // Driver
  //.......................................................
  class my_driver extends uvm_driver #(my_transaction);
  
    `uvm_component_utils(my_driver)

    virtual fir_dut_if dut_vi;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction: new
    
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
    endfunction : build_phase
   
    task run_phase(uvm_phase phase);
      forever
      begin
        my_transaction tx;
        
        @(posedge dut_vi.clk);
        seq_item_port.get(tx);
        
        dut_vi.fir_in  = tx.fir_in;
        dut_vi.w_1 	   = tx.w_1;
        dut_vi.w_2     = tx.w_2;
        dut_vi.w_3     = tx.w_3;
		    dut_vi.fir_out = tx.fir_out;

      end
    endtask: run_phase

  endclass: my_driver

  //.......................................................
  // Monitor
  //.......................................................
  class my_monitor extends uvm_monitor;
  
    `uvm_component_utils(my_monitor)

    uvm_analysis_port #(my_transaction) aport;
    
    virtual fir_dut_if dut_vi;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction: new
    
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      aport = new("aport", this);
    endfunction : build_phase
   
    task run_phase(uvm_phase phase);
      forever
      begin
        my_transaction tx;
        
        @(posedge dut_vi.clk);
        tx = my_transaction::type_id::create("tx");
        tx.fir_in  = dut_vi.fir_in;
        tx.w_1 	   = dut_vi.w_1;
        tx.w_2     = dut_vi.w_2;
        tx.w_3     = dut_vi.w_3;
		    tx.fir_out = dut_vi.fir_out;
        
      `uvm_info("monitor", $psprintf("monitor sending tx %s", tx.convert2string()), UVM_FULL);

        aport.write(tx);
      end
    endtask: run_phase

  endclass: my_monitor
  
  //.......................................................
  // Coverage Collector
  //.......................................................
  class my_cov_col extends uvm_subscriber #(my_transaction);
  
    `uvm_component_utils(my_cov_col)
    
    parameter width = 8;
    bit  [width-1:0]   fir_in;
    bit  [width-1:0]   w_1;
    bit  [width-1:0]   w_2;
    bit  [width-1:0]   w_3;
	  bit  [2*width-1:0] fir_out;
        
    covergroup cover_fir;
      coverpoint fir_in {
        bins zero = {'d0};
        bins nonzero[10] = {[8'd1:8'd255]};
      }
      coverpoint w_1 { 
        bins zero = {'d0};
        bins nonzero[10] = {[8'd1:8'd255]};
      }
      coverpoint w_2 { 
        bins zero = {'d0};
        bins nonzero[10] = {[8'd1:8'd255]};
      }
      coverpoint w_3 { 
        bins zero = {'d0};
        bins nonzero[10] = {[8'd1:8'd255]};
      }
      coverpoint fir_out { 
        bins zero        = {'d0};
        bins nonzero[20] = {[16'd1:16'd65535]};
        bins single_tran = ('d0 => [16'd1:16'd65535] => 'd0);
      }

      input_cross: cross fir_in, w_1, w_2, w_3;

    endgroup: cover_fir
    
    function new(string name, uvm_component parent);
      super.new(name, parent);
      cover_fir = new;  
    endfunction: new

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
    endfunction: build_phase
    
    function void write(my_transaction t);
      //Print the received transacton
      `uvm_info("coverage_collector", $psprintf("Coverage collector received tx %s", 
                t.convert2string()), UVM_HIGH);
      
      //Sample coverage info
      fir_in  = t.fir_in;
      w_1 	  = t.w_1;
      w_2     = t.w_2;
      w_3     = t.w_3;
      fir_out = t.fir_out;
      cover_fir.sample();
      
    endfunction: write

  endclass: my_cov_col

  //.......................................................
  // Predictor 
  //.......................................................
  class my_predictor extends uvm_subscriber #(my_transaction);
  
    `uvm_component_utils(my_predictor)

    uvm_analysis_port #(my_transaction) results_ap;
    my_transaction out_tx;
    
    parameter width = 8;
    bit  [width-1:0]     fir_in_q [$];
    bit  [width-1:0]     fir_in_q2[$];
    bit  [width-1:0]     fir_in_q3[$];
    bit  [width-1:0]     curr_fir_in_q, curr_fir_in_q2, curr_fir_in_q3;
    bit  [2*width-1:0]   fir_out_q [$];

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      results_ap = new("results_ap", this);
      out_tx = my_transaction::type_id::create("out_tx");
    endfunction: build_phase
    
    function void start_of_simulation_phase(uvm_phase phase);
      //Create queue of input data offset by 1, 2, and 3 cycles
      fir_in_q.push_back(8'b0);
      fir_in_q2.push_back(8'b0);
      fir_in_q2.push_back(8'b0);
      fir_in_q3.push_back(8'b0);
      fir_in_q3.push_back(8'b0);
      fir_in_q3.push_back(8'b0);

      //Offset output value by 1 cycle
      fir_out_q.push_back(16'b0);
    endfunction: start_of_simulation_phase

    function void write(my_transaction t);
      //Print the received transacton
      `uvm_info("predictor", $psprintf("predictor received tx %s", 
                t.convert2string()), UVM_HIGH);
      
      //Copy the transaction and add it to the local variables
      out_tx.copy(t);
      fir_in_q.push_back(t.fir_in);
      fir_in_q2.push_back(t.fir_in);
      fir_in_q3.push_back(t.fir_in);

      //Pop from queues and predict
      curr_fir_in_q = fir_in_q.pop_front();
      curr_fir_in_q2 = fir_in_q2.pop_front();
      curr_fir_in_q3 = fir_in_q3.pop_front();
      out_tx.fir_out = out_tx.w_1  * curr_fir_in_q  +
                        out_tx.w_2 * curr_fir_in_q2 +
                        out_tx.w_3 * curr_fir_in_q3;
      `uvm_info("prediction", $psprintf("Prediting %d * %d + %d * %d + %d * %d = %d",
                out_tx.w_1, curr_fir_in_q, out_tx.w_2, curr_fir_in_q2, out_tx.w_3, 
                curr_fir_in_q3, out_tx.fir_out), UVM_FULL);

      //Write to analysis port with delay of 1 cycle
      fir_out_q.push_back(out_tx.fir_out);
      out_tx.fir_out = fir_out_q.pop_front();
      results_ap.write(out_tx);
    endfunction: write

  endclass: my_predictor
  
  //.......................................................
  // Comparator
  //.......................................................
  `uvm_analysis_imp_decl(_PRED)
  `uvm_analysis_imp_decl(_DUT)
  class my_comparator extends uvm_component;
  
    `uvm_component_utils(my_comparator)

    uvm_analysis_imp_PRED #(my_transaction, my_comparator) pred_export;
    uvm_analysis_imp_DUT  #(my_transaction, my_comparator) dut_export;

    my_transaction dut_queue[$];
    my_transaction pred_queue[$];
    my_transaction curr_dut_t, in_dut_t;
    my_transaction curr_pred_t, in_pred_t;
    
    int matchNum, mismatchNum;

    function new(string name, uvm_component parent);
      super.new(name, parent);
      matchNum    = 0;
      mismatchNum = 0;
    endfunction: new

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      pred_export = new("pred_export", this);
      dut_export  = new("dut_export", this);
      curr_dut_t  = my_transaction::type_id::create("curr_dut_t");
      in_dut_t    = my_transaction::type_id::create("in_dut_t");
      curr_pred_t = my_transaction::type_id::create("curr_pred_t");
      in_pred_t   = my_transaction::type_id::create("in_pred_t");
    endfunction: build_phase
    
    //Compare for equality
    protected virtual function void compare_data();
      curr_pred_t = pred_queue.pop_front();
      curr_dut_t  = dut_queue.pop_front();
      if(!curr_dut_t.compare(curr_pred_t)) begin
        `uvm_error("Comparator Mismatch", $sformatf("%s from dut does not match predicted %s", 
                  curr_dut_t.convert2string(), curr_pred_t.convert2string()));
        mismatchNum++;
      end else begin
        matchNum++;
      end
    endfunction : compare_data
    
    // Actions taken when transaction is received on PRED analysis port
    function void write_PRED(my_transaction t);
      //Print the received transacton
      `uvm_info("comparator_PRED", $psprintf("Comparator received from predictor tx %s", 
                t.convert2string()), UVM_MEDIUM);
      
      //Add transaction to the queue
      in_pred_t.copy(t);
      pred_queue.push_back(in_pred_t);

      //If there is a transaction in the DUT queue then compare
      if(dut_queue.size())
        compare_data();
    endfunction: write_PRED
    
    // Actions taken when transaction is received on DUT analysis port
    function void write_DUT(my_transaction t);
      //Print the received transacton
      `uvm_info("comparator_DUT", $psprintf("Comparator received from dut tx %s", 
                t.convert2string()), UVM_HIGH);

      //Add transaction to the queue
      in_dut_t.copy(t);
      dut_queue.push_back(in_dut_t);
      
      //If there is a transaction in the DUT queue then compare
      if(pred_queue.size())
        compare_data();
    endfunction: write_DUT

    //Report matches and mismatches
    function void report_phase(uvm_phase phase);
      `uvm_info("Comparator", $sformatf("Matches:    %0d", matchNum), UVM_LOW);
      `uvm_info("Comparator", $sformatf("Mismatches: %0d", mismatchNum), UVM_LOW);
    endfunction : report_phase

  endclass: my_comparator
  
  //.......................................................
  // Scoreboard
  //.......................................................
  class my_scoreboard extends uvm_subscriber#(my_transaction);
  
    `uvm_component_utils(my_scoreboard)
    
    my_transaction in_tx;
    uvm_analysis_port #(my_transaction) pred_in_ap;
    uvm_analysis_port #(my_transaction) comp_in_ap;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
      super.build_phase(phase); 
      pred_in_ap = new("pred_in_ap", this);
      comp_in_ap = new("comp_in_ap", this);
      in_tx = my_transaction::type_id::create("in_tx");
    endfunction: build_phase

    function void write(my_transaction t);
      `uvm_info("scoreboard", $psprintf("Scoreboard received tx %s", t.convert2string()), UVM_HIGH);

      //Give transaction to both the predictor and comparator
      in_tx.copy(t);
      pred_in_ap.write(in_tx);
      comp_in_ap.write(in_tx);

    endfunction: write
    
  endclass: my_scoreboard
  
  //.......................................................
  // Agent
  //.......................................................
  class base_agent extends uvm_agent;

    `uvm_component_utils(base_agent)
    
    uvm_analysis_port #(my_transaction) aport;
    
    my_sequencer my_sequencer_h;
    my_driver    my_driver_h;
    my_monitor   my_monitor_h;
    
    agt_config    agt_cfg; 
    
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction: new
    
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      aport = new("aport", this);
      my_sequencer_h = my_sequencer::type_id::create("my_sequencer_h", this);
      my_driver_h    = my_driver   ::type_id::create("my_driver_h"   , this);
      my_monitor_h   = my_monitor  ::type_id::create("my_monitor_h"  , this);
      
      // Get and pass configuration information from test to the agent
      agt_cfg = agt_config::type_id::create("agt_cfg");
      if(!uvm_config_db#(agt_config)::get(this, "", "agt_config", agt_cfg))
        `uvm_fatal("NO_CFG", "No agent config set")
      
    endfunction: build_phase
    
    function void connect_phase(uvm_phase phase);
      my_driver_h.seq_item_port.connect( my_sequencer_h.seq_item_export );
      my_monitor_h.       aport.connect( aport );
      
      //Set virtual interface for driver and monitor
      my_driver_h.dut_vi = agt_cfg.dut_vi;
      my_monitor_h.dut_vi = agt_cfg.dut_vi;
    endfunction: connect_phase
    
  endclass: base_agent  
  
  //.......................................................
  // Environment
  //.......................................................
  class base_env extends uvm_env;

    `uvm_component_utils(base_env)
    
    base_agent    base_agent_h;
    my_cov_col    my_cov_col_h;
    my_scoreboard my_scoreboard_h;
    my_predictor  my_predictor_h;
    my_comparator my_comparator_h;
    env_config    env_cfg;
    agt_config    agt_cfg;    
    
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction: new
    
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      base_agent_h    = base_agent::type_id::create("base_agent_h",   this);
      my_cov_col_h    = my_cov_col::type_id::create("my_cov_col_h", this);
      my_scoreboard_h = my_scoreboard::type_id::create("my_scoreboard_h", this);
      my_predictor_h  = my_predictor::type_id::create("my_predictor_h", this);
      my_comparator_h  = my_comparator::type_id::create("my_comparator_h", this);
      
      // Get and pass configuration information from test to the agent
      env_cfg = env_config::type_id::create("env_cfg");
      agt_cfg = agt_config::type_id::create("agt_cfg");
      if(!uvm_config_db#(env_config)::get(this, "", "env_config", env_cfg))
        `uvm_fatal("NO_CFG", "No enviornment config set")
      agt_cfg.dut_vi = env_cfg.dut_vi;
      uvm_config_db#(agt_config)::set(this, "*", "agt_config", agt_cfg);
    endfunction: build_phase
    
    function void connect_phase(uvm_phase phase);
      base_agent_h.aport.connect(my_cov_col_h.analysis_export);
      base_agent_h.aport.connect(my_scoreboard_h.analysis_export);
      my_scoreboard_h.pred_in_ap.connect(my_predictor_h.analysis_export);
      my_scoreboard_h.comp_in_ap.connect(my_comparator_h.dut_export);
      my_predictor_h.results_ap.connect(my_comparator_h.pred_export);
    endfunction: connect_phase
    
    //function void start_of_simulation_phase(uvm_phase phase);
    //  uvm_top.set_report_verbosity_level_hier(UVM_HIGH);
    //endfunction: start_of_simulation_phase

  endclass: base_env
  
  //.......................................................
  // Test
  //.......................................................
  class base_test extends uvm_test;
  
    `uvm_component_utils(base_test)
    
    virtual fir_dut_if dut_vi;
    
    base_env   base_env_h;
    env_config env_cfg;
   
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction: new
    
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      base_env_h = base_env::type_id::create("base_env_h", this);
      
      // Get and pass configuration information to the enviornment
      env_cfg = env_config::type_id::create("env_cfg");
      if(!uvm_config_db#(virtual fir_dut_if)::get(this, "", "dut_vi", env_cfg.dut_vi))
        `uvm_fatal("NO_CFG", "No virtual interface set")
      uvm_config_db#(env_config)::set(this, "*", "env_config", env_cfg);
    endfunction: build_phase
    
    task run_phase(uvm_phase phase);
      seq_of_commands seq1;
      single_signal_sequence seq2;
      clear_between_sequence cseq;

      phase.raise_objection(this, "Starting Sequences");

      seq1 = seq_of_commands::type_id::create("seq1");
      seq2 = single_signal_sequence::type_id::create("seq2");
      cseq = clear_between_sequence::type_id::create("cseq");
      
      `uvm_info("test", "Starting seq1", UVM_HIGH);
      assert( seq1.randomize() );
      seq1.start( base_env_h.base_agent_h.my_sequencer_h);
      #300
      
      `uvm_info("test", "Starting cseq", UVM_HIGH);
      assert( cseq.randomize());
      cseq.start( base_env_h.base_agent_h.my_sequencer_h);
      #300

      `uvm_info("test", "Starting seq2", UVM_HIGH);
      assert( seq2.randomize() );
      seq2.start( base_env_h.base_agent_h.my_sequencer_h);
      #300
      
      phase.drop_objection(this, "Finished sequences");
    endtask: run_phase
    
  endclass: base_test
  
  
endpackage: fir_comp_pkg
