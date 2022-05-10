// Devin Bidstrup 2022
// UVM Sequences for FIR Filter


package fir_seq_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  //.......................................................
  // Transaction
  //.......................................................
  class my_transaction extends uvm_sequence_item;
  
    `uvm_object_utils(my_transaction)
   
    // transaction bits
    parameter  width = 8;
    rand bit  [width-1:0]   fir_in;
    rand bit  [width-1:0]   w_1;
    rand bit  [width-1:0]   w_2;
    rand bit  [width-1:0]   w_3;
    bit  	    [2*width-1:0] fir_out;	
	
    function new (string name = "");
      super.new(name);
    endfunction: new
    
    function void do_copy(uvm_object rhs);
      my_transaction rhs_;

      if(!$cast(rhs_, rhs)) begin
        uvm_report_error("do_copy:", "Cast failed");
        return;
      end
      super.do_copy(rhs);
      fir_in = rhs_.fir_in;
      w_1 = rhs_.w_1;
      w_2 = rhs_.w_2;
      w_3 = rhs_.w_3;
      fir_out = rhs_.fir_out;
     endfunction: do_copy

     function bit do_compare(uvm_object rhs, uvm_comparer comparer);
      my_transaction rhs_;

      if(!$cast(rhs_, rhs)) begin
        return 0;
      end
      return(super.do_compare(rhs, comparer) && (fir_out == rhs_.fir_out));
    endfunction: do_compare

    function string convert2string();
     string s;
     s = super.convert2string();
     $sformat(s, "fir_in %d\t w_1 %d\t w_2 %d\t w_3 %d\t fir_out %d\n",
              fir_in, w_1, w_2, w_3, fir_out);
     return s;
    endfunction: convert2string
    
  endclass: my_transaction
  
  //.......................................................
  // Sequence
  //.......................................................

  // Sequence that randomizes all inputs
  class rand_sequence extends uvm_sequence #(my_transaction);
  
    `uvm_object_utils(rand_sequence)
    
    function new (string name = "");
      super.new(name);
    endfunction: new

    task body;
      my_transaction tx;
      parameter  width = 8;
      bit  [width-1:0]   fir_in;
      bit  [width-1:0]   w_1;
      bit  [width-1:0]   w_2;
      bit  [width-1:0]   w_3;
      //uvm_test_done.raise_objection(this);
      tx = my_transaction::type_id::create("tx");
      start_item(tx);
      assert (tx.randomize() /*with {fir_in==8'b1111_1111;}*/);
      finish_item(tx);
      //uvm_test_done.drop_objection(this);
    endtask: body
   
  endclass: rand_sequence

  // Sequence that randomizes only the w's
  class randw_sequence extends uvm_sequence #(my_transaction);
  
    `uvm_object_utils(randw_sequence)
    
    function new (string name = "");
      super.new(name);
    endfunction: new

    task body;
      my_transaction tx;
      parameter  width = 8;
      bit  [width-1:0]   fir_in;
      bit  [width-1:0]   w_1;
      bit  [width-1:0]   w_2;
      bit  [width-1:0]   w_3;
      tx = my_transaction::type_id::create("tx");
      start_item(tx);
      assert (tx.randomize() with {fir_in==8'd0;});
      finish_item(tx);
    endtask: body
   
  endclass: randw_sequence

  
  // Sequence that randomizes only the fir_in input
  class randin_sequence extends uvm_sequence #(my_transaction);
  
    `uvm_object_utils(randin_sequence)
    
    function new (string name = "");
      super.new(name);
    endfunction: new

    task body;
      my_transaction tx;
      parameter  width = 8;
      bit  [width-1:0]   fir_in;
      bit  [width-1:0]   w_1;
      bit  [width-1:0]   w_2;
      bit  [width-1:0]   w_3;
      tx = my_transaction::type_id::create("tx");
      start_item(tx);
      assert (tx.randomize() with { w_1==8'd0; w_2==8'd0; w_3==8'd0;});
      finish_item(tx);
    endtask: body
   
  endclass: randin_sequence
  
  // Sequence that sets all inputs to zero
  class zero_sequence extends uvm_sequence #(my_transaction);
  
    `uvm_object_utils(zero_sequence)
    
    function new (string name = "");
      super.new(name);
    endfunction: new

    task body;
      my_transaction tx;
      parameter  width = 8;
      bit  [width-1:0]   fir_in;
      bit  [width-1:0]   w_1;
      bit  [width-1:0]   w_2;
      bit  [width-1:0]   w_3;
      tx = my_transaction::type_id::create("tx");
      start_item(tx);
      assert (tx.randomize() with {fir_in==8'd0; w_1==8'd0; w_2==8'd0; w_3==8'd0;});
      finish_item(tx);
    endtask: body
   
  endclass: zero_sequence

  //.......................................................
  // Hierarchical Sequences
  //......................................................

  // Sequences a random number of randomized input sequences.
   class seq_of_commands extends uvm_sequence #(my_transaction);
  
    `uvm_object_utils(seq_of_commands)

    rand int n;
    constraint how_many { n inside {[4:6]}; }

    function new (string name = "");
      super.new(name);
    endfunction: new

    task body;
      `uvm_info("seq", $psprintf("N is %d", n), UVM_NONE);
      repeat(n)
      begin
        rand_sequence seq;
        seq = rand_sequence::type_id::create("seq");
        seq.start(m_sequencer, this);
      end
    endtask: body
   
  endclass: seq_of_commands
 
  // Sequences a single fir_in to watch propogate 
  class single_signal_sequence extends uvm_sequence #(my_transaction);
    `uvm_object_utils(single_signal_sequence)

    function new (string name = "");
      super.new(name);
    endfunction: new

    task body;
      begin
        rand_sequence  seq1;
        randw_sequence seq2;
        randw_sequence seq3;
        randw_sequence seq4;
        seq1 = rand_sequence::type_id::create("seq1");
        seq2 = randw_sequence::type_id::create("seq2");
        seq3 = randw_sequence::type_id::create("seq3");
        seq4 = randw_sequence::type_id::create("seq4");
        
        seq1.start(m_sequencer, this);
        seq2.start(m_sequencer, this);
        seq3.start(m_sequencer, this);
        seq4.start(m_sequencer, this);
      end
    endtask: body
  endclass: single_signal_sequence

  // Sends a bunch of zeros at the inputs between nested sequences 
  class clear_between_sequence extends uvm_sequence #(my_transaction);
    `uvm_object_utils(clear_between_sequence)

    function new (string name = "");
      super.new(name);
    endfunction: new

    task body;
      begin
        zero_sequence seq1;
        zero_sequence seq2;
        zero_sequence seq3;
        zero_sequence seq4;
        seq1 = zero_sequence::type_id::create("seq1");
        seq2 = zero_sequence::type_id::create("seq2");
        seq3 = zero_sequence::type_id::create("seq3");
        seq4 = zero_sequence::type_id::create("seq4");
        
        seq1.start(m_sequencer, this);
        seq2.start(m_sequencer, this);
        seq3.start(m_sequencer, this);
        seq4.start(m_sequencer, this);
      end
    endtask: body
  endclass: clear_between_sequence

endpackage : fir_seq_pkg
