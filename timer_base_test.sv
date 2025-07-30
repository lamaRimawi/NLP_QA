`include "timer_env.sv"
class timer_base_test extends uvm_test;
    
    timer_env env;
    
    `uvm_component_utils(timer_base_test)
    
    function new(string name = "timer_base_test", uvm_component parent);
        super.new(name, parent);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = timer_env::type_id::create("env", this);
    endfunction
    
    virtual function void end_of_elaboration_phase(uvm_phase phase);
        `uvm_info("TEST", "End of elaboration phase", UVM_LOW)
        print();
    endfunction
    
endclass