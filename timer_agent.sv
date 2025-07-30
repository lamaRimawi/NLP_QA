`include "timer_interface.sv"
`include "timer_sequencer.sv"
`include "timer_driver.sv"
`include "timer_monitor.sv"
`include "sequences.sv"
class timer_agent extends uvm_agent;
    
    timer_driver driver;
    timer_sequencer sequencer;
    timer_monitor monitor;
    
    `uvm_component_utils(timer_agent)
    
    function new(string name = "timer_agent", uvm_component parent);
        super.new(name, parent);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        driver = timer_driver::type_id::create("driver", this);
        sequencer = timer_sequencer::type_id::create("sequencer", this);
        monitor = timer_monitor::type_id::create("monitor", this);
    endfunction
    
    virtual function void connect_phase(uvm_phase phase);
        driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction
    
endclass