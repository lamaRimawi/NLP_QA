												  `include "timer_interface.sv" 
`include "timer_base_test.sv"
`include "tests.sv"

module timer_tb_top;
    
    logic clk;
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Interface instantiation
    timer_interface vif(clk);
    
    // DUT instantiation
    timer dut (
        .d(vif.d),
        .a(vif.a),
        .clk(vif.clk),
        .g0(vif.g0),
        .g1(vif.g1),
        .out0(vif.out0),
        .out1(vif.out1)
    );
    
    // UVM configuration and test execution
    initial begin
        // Configure interface in UVM database
        uvm_config_db#(virtual timer_interface)::set(null, "*", "vif", vif);
        
        // Set verbosity level
        uvm_config_db#(int unsigned)::set(null, "*", "recording_detail", UVM_FULL);
        
        // Run the test
      run_test("timer_comprehensive_test");
    end
    
    // Dump waveforms
    initial begin
        $dumpfile("timer_tb.vcd");
        $dumpvars(0, timer_tb_top);
    end
    
    // Simulation timeout
    initial begin
        #1000000; // 1ms timeout
        `uvm_fatal("TIMEOUT", "Simulation timeout reached")
    end
    
endmodule