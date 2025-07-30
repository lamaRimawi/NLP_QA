`include "timer_transaction.sv" 
class timer_sequencer extends uvm_sequencer #(timer_transaction);
    `uvm_component_utils(timer_sequencer)
    
    function new(string name = "timer_sequencer", uvm_component parent);
        super.new(name, parent);
    endfunction
    
endclass