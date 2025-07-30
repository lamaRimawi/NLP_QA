class timer_monitor extends uvm_monitor;
    
    virtual timer_interface vif;
    uvm_analysis_port #(timer_transaction) item_collected_port;
    
    `uvm_component_utils(timer_monitor)
    
    function new(string name = "timer_monitor", uvm_component parent);
        super.new(name, parent);
        item_collected_port = new("item_collected_port", this);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual timer_interface)::get(this, "", "vif", vif))
            `uvm_fatal("MONITOR", "Could not get vif")
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        timer_transaction trans;
        
        forever begin
            @(vif.monitor_cb);
            
            // Capture transaction
            trans = timer_transaction::type_id::create("trans");
            trans.a = vif.monitor_cb.a;
            trans.d = vif.monitor_cb.d;
            trans.g0 = vif.monitor_cb.g0;
            trans.g1 = vif.monitor_cb.g1;
            trans.out0 = vif.monitor_cb.out0;
            trans.out1 = vif.monitor_cb.out1;
            
            `uvm_info("MONITOR", $sformatf("Collected transaction: a=%b, d=0x%h, g0=%b, g1=%b, out0=%b, out1=%b", 
                      trans.a, trans.d, trans.g0, trans.g1, trans.out0, trans.out1), UVM_HIGH)
            
            item_collected_port.write(trans);
        end
    endtask
endclass