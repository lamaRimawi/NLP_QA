class timer_basic_test extends timer_base_test;
    `uvm_component_utils(timer_basic_test)
    
    function new(string name = "timer_basic_test", uvm_component parent);
        super.new(name, parent);
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        timer_register_config_sequence config_seq;
        timer_gate_control_sequence gate_seq;
        
        phase.raise_objection(this);
        
        `uvm_info("TEST", "=== Starting Basic Timer Test ===", UVM_LOW)
        
        // First configure the timers
        config_seq = timer_register_config_sequence::type_id::create("config_seq");
        config_seq.start(env.agent.sequencer);
        
        // Then test gate control
        gate_seq = timer_gate_control_sequence::type_id::create("gate_seq");
        gate_seq.start(env.agent.sequencer);
        
        `uvm_info("TEST", "=== Basic Timer Test Completed ===", UVM_LOW)
        
        phase.drop_objection(this);
    endtask
endclass

// Comprehensive test
class timer_comprehensive_test extends timer_base_test;
    `uvm_component_utils(timer_comprehensive_test)
    
    function new(string name = "timer_comprehensive_test", uvm_component parent);
        super.new(name, parent);
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        timer_register_config_sequence config_seq;
       timer_mode_test_sequence mode_seq;
       timer_boundary_test_sequence boundary_seq;
        timer_edge_case_sequence edge_seq;
        timer_random_sequence random_seq;
        
        phase.raise_objection(this);
        
        `uvm_info("TEST", "=== Starting Comprehensive Timer Test ===", UVM_LOW)
        
        // 1. Basic configuration
       //config_seq = timer_register_config_sequence::type_id::create("config_seq");
       //config_seq.start(env.agent.sequencer);
        
       // 2. Mode testing
       // mode_seq = timer_mode_test_sequence::type_id::create("mode_seq");
       // mode_seq.start(env.agent.sequencer);
        
        // 3. Boundary value testing
       //boundary_seq = timer_boundary_test_sequence::type_id::create("boundary_seq");
       // boundary_seq.start(env.agent.sequencer);
        
        // 4. Edge case testing
     // edge_seq = timer_edge_case_sequence::type_id::create("edge_seq");
       //edge_seq.start(env.agent.sequencer);
        
        // 5. Random testing
       random_seq = timer_random_sequence::type_id::create("random_seq");
       random_seq.start(env.agent.sequencer);
        
        `uvm_info("TEST", "=== Comprehensive Timer Test Completed ===", UVM_LOW)
        
        phase.drop_objection(this);
    endtask
endclass

// Random test
class timer_random_test extends timer_base_test;
    `uvm_component_utils(timer_random_test)
    
    function new(string name = "timer_random_test", uvm_component parent);
        super.new(name, parent);
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        timer_random_sequence random_seq;
        
        phase.raise_objection(this);
        
        `uvm_info("TEST", "=== Starting Random Timer Test ===", UVM_LOW)
        
        // Run random sequence multiple times
        repeat(3) begin
            random_seq = timer_random_sequence::type_id::create("random_seq");
            random_seq.start(env.agent.sequencer);
        end
        
        `uvm_info("TEST", "=== Random Timer Test Completed ===", UVM_LOW)
        
        phase.drop_objection(this);
    endtask
endclass
