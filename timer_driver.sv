`include "timer_transaction.sv"
class timer_driver extends uvm_driver #(timer_transaction);
    
    virtual timer_interface vif;
    
    `uvm_component_utils(timer_driver)
    
    function new(string name = "timer_driver", uvm_component parent);
        super.new(name, parent);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual timer_interface)::get(this, "", "vif", vif))
            `uvm_fatal("DRIVER", "Could not get vif")
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        timer_transaction req;
        
        // Initialize signals
        vif.driver_cb.d <= 4'h0;
        vif.driver_cb.a <= 2'b11; // Undefined address initially
        vif.driver_cb.g0 <= 1'b0;
        vif.driver_cb.g1 <= 1'b0;
        
        // Wait for reset to complete (timer has 3-cycle reset)
        repeat(10) @(vif.driver_cb);
        
        // Enable gates after reset
        vif.driver_cb.g0 <= 1'b1;
        vif.driver_cb.g1 <= 1'b1;
        
        forever begin
            seq_item_port.get_next_item(req);
            drive_transaction(req);
            seq_item_port.item_done();
        end
    endtask
    
    virtual task drive_transaction(timer_transaction req);
        `uvm_info("DRIVER", $sformatf("Driving transaction: a=%b, d=0x%h, g0=%b, g1=%b", 
                  req.a, req.d, req.g0, req.g1), UVM_HIGH)
        
        // Apply inputs
        @(vif.driver_cb);
        vif.driver_cb.a <= req.a;
        vif.driver_cb.d <= req.d;
        vif.driver_cb.g0 <= req.g0;
        vif.driver_cb.g1 <= req.g1;
        
        // Hold for one cycle
        @(vif.driver_cb);
        
        // For register writes, hold the address/data for proper capture
        if (req.a != 2'b11) begin
            repeat(2) @(vif.driver_cb); // Hold for register write
        end
        
        // Return to safe state
        vif.driver_cb.a <= 2'b11; // Undefined address
        
        // Wait a bit to observe counter behavior
        repeat(5) @(vif.driver_cb);
    endtask
    
endclass