`include "timer_agent.sv"
`include "timer_scoreboard.sv"
class timer_env extends uvm_env;
    
    timer_agent agent;
    timer_scoreboard scoreboard;
    
    `uvm_component_utils(timer_env)
    
    function new(string name = "timer_env", uvm_component parent);
        super.new(name, parent);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        agent = timer_agent::type_id::create("agent", this);
        scoreboard = timer_scoreboard::type_id::create("scoreboard", this);
    endfunction
    
    virtual function void connect_phase(uvm_phase phase);
        agent.monitor.item_collected_port.connect(scoreboard.item_collected_export);
    endfunction
    
endclass