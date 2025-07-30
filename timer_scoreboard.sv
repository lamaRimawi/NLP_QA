`ifndef TIMER_SCOREBOARD_SV
`define TIMER_SCOREBOARD_SV
`include "timer_golden_model.sv"
class timer_scoreboard extends uvm_scoreboard;
    
    uvm_analysis_imp #(timer_transaction, timer_scoreboard) item_collected_export;
    timer_golden_model golden_model;
    
    int pass_count = 0;
    int fail_count = 0;
    int total_count = 0;
    
    // Track specific test scenarios
    int counter0_mode_tests[5] = '{0,0,0,0,0}; // modes 0-4
    int counter1_mode_tests[5] = '{0,0,0,0,0}; // modes 0-4
    int gate_control_tests = 0;
    int register_write_tests = 0;
    
    `uvm_component_utils(timer_scoreboard)
    
    function new(string name = "timer_scoreboard", uvm_component parent);
        super.new(name, parent);
        item_collected_export = new("item_collected_export", this);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        golden_model = timer_golden_model::type_id::create("golden_model", this);
    endfunction
    
    virtual function void write(timer_transaction pkt);
        timer_transaction expected;
        string result_str;
        logic out0_match, out1_match;
        
        total_count++;
        expected = golden_model.predict(pkt);
        
        out0_match = (pkt.out0 == expected.out0);
        out1_match = (pkt.out1 == expected.out1);
        
        if (out0_match && out1_match) begin
            pass_count++;
            result_str = "PASS";
            `uvm_info("SCOREBOARD", $sformatf("%s: a=%b, d=0x%h, g0=%b, g1=%b | exp_out0=%b, act_out0=%b, exp_out1=%b, act_out1=%b", 
                      result_str, pkt.a, pkt.d, pkt.g0, pkt.g1, expected.out0, pkt.out0, expected.out1, pkt.out1), UVM_MEDIUM)
        end else begin
            fail_count++;
            result_str = "FAIL";
            `uvm_error("SCOREBOARD", $sformatf("%s: a=%b, d=0x%h, g0=%b, g1=%b | exp_out0=%b, act_out0=%b, exp_out1=%b, act_out1=%b", 
                       result_str, pkt.a, pkt.d, pkt.g0, pkt.g1, expected.out0, pkt.out0, expected.out1, pkt.out1))
        end
        
        // Track test coverage
        update_coverage_stats(pkt);
    endfunction
    
    virtual function void update_coverage_stats(timer_transaction pkt);
        // Track register write tests
        if (pkt.a inside {2'b00, 2'b01, 2'b10}) begin
            register_write_tests++;
        end
        
        // Track gate control tests
        if (pkt.g0 == 1'b0 || pkt.g1 == 1'b0) begin
            gate_control_tests++;
        end
    endfunction
    
    virtual function void report_phase(uvm_phase phase);
        `uvm_info("SCOREBOARD", "=== FINAL TEST RESULTS ===", UVM_LOW)
        `uvm_info("SCOREBOARD", $sformatf("Total Transactions: %0d", total_count), UVM_LOW)
        `uvm_info("SCOREBOARD", $sformatf("PASS: %0d", pass_count), UVM_LOW)
        `uvm_info("SCOREBOARD", $sformatf("FAIL: %0d", fail_count), UVM_LOW)
        `uvm_info("SCOREBOARD", $sformatf("Pass Rate: %0.2f%%", (pass_count * 100.0) / total_count), UVM_LOW)
        
        `uvm_info("SCOREBOARD", "=== COVERAGE STATISTICS ===", UVM_LOW)
        `uvm_info("SCOREBOARD", $sformatf("Register Write Tests: %0d", register_write_tests), UVM_LOW)
        `uvm_info("SCOREBOARD", $sformatf("Gate Control Tests: %0d", gate_control_tests), UVM_LOW)
        
        if (fail_count == 0)
            `uvm_info("SCOREBOARD", "*** ALL TESTS PASSED ***", UVM_LOW)
        else
            `uvm_error("SCOREBOARD", "*** SOME TESTS FAILED ***")
    endfunction
    
endclass
 `endif // TIMER_SCOREBOARD_SV
         