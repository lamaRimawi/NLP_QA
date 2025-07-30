// Base sequence
class timer_base_sequence extends uvm_sequence #(timer_transaction);
    `uvm_object_utils(timer_base_sequence)
    
    function new(string name = "timer_base_sequence");
        super.new(name);
    endfunction
endclass

// Register configuration sequence
class timer_register_config_sequence extends timer_base_sequence;
    `uvm_object_utils(timer_register_config_sequence)
    
    function new(string name = "timer_register_config_sequence");
        super.new(name);
    endfunction
    
    virtual task body();
        timer_transaction req;
        
        `uvm_info("SEQUENCE", "Starting register configuration sequence", UVM_MEDIUM)
        
        // Configure Counter0 with value 10 (0x0A)
        // Write lower nibble first
        req = timer_transaction::type_id::create("counter0_lower");
        start_item(req);
        assert(req.randomize() with {a == 2'b00; d == 4'hA; g0 == 1'b1; g1 == 1'b1;});
        req.trans_type = timer_transaction::WRITE_LOWER;
        finish_item(req);
        
        // Write upper nibble
        req = timer_transaction::type_id::create("counter0_upper");
        start_item(req);
        assert(req.randomize() with {a == 2'b00; d == 4'h0; g0 == 1'b1; g1 == 1'b1;});
        req.trans_type = timer_transaction::WRITE_UPPER;
        req.full_value = 8'h0A;
        finish_item(req);
        
        // Configure Counter0 mode to 1
        req = timer_transaction::type_id::create("counter0_mode");
        start_item(req);
        assert(req.randomize() with {a == 2'b10; d == 4'b0001; g0 == 1'b1; g1 == 1'b1;}); // c=0, mode=1
        req.trans_type = timer_transaction::CONTROL_WRITE;
        req.target_counter = 1'b0;
        req.target_mode = 3'd1;
        finish_item(req);
        
        // Configure Counter1 with value 60 (0x3C)
        // Write lower nibble first
        req = timer_transaction::type_id::create("counter1_lower");
        start_item(req);
        assert(req.randomize() with {a == 2'b01; d == 4'hC; g0 == 1'b1; g1 == 1'b1;});
        req.trans_type = timer_transaction::WRITE_LOWER;
        finish_item(req);
        
        // Write upper nibble
        req = timer_transaction::type_id::create("counter1_upper");
        start_item(req);
        assert(req.randomize() with {a == 2'b01; d == 4'h3; g0 == 1'b1; g1 == 1'b1;});
        req.trans_type = timer_transaction::WRITE_UPPER;
        req.full_value = 8'h3C;
        finish_item(req);
        
        // Configure Counter1 mode to 2
        req = timer_transaction::type_id::create("counter1_mode");
        start_item(req);
        assert(req.randomize() with {a == 2'b10; d == 4'b1010; g0 == 1'b1; g1 == 1'b1;}); // c=1, mode=2
        req.trans_type = timer_transaction::CONTROL_WRITE;
        req.target_counter = 1'b1;
        req.target_mode = 3'd2;
        finish_item(req);
        
        `uvm_info("SEQUENCE", "Register configuration sequence completed", UVM_MEDIUM)
    endtask
endclass

// Gate control sequence
class timer_gate_control_sequence extends timer_base_sequence;
    `uvm_object_utils(timer_gate_control_sequence)
    
    function new(string name = "timer_gate_control_sequence");
        super.new(name);
    endfunction
    
    virtual task body();
        timer_transaction req;
        
        `uvm_info("SEQUENCE", "Starting gate control sequence", UVM_MEDIUM)
        
        // Both gates enabled
        repeat(10) begin
            req = timer_transaction::type_id::create("both_gates_on");
            start_item(req);
            assert(req.randomize() with {a == 2'b11; g0 == 1'b1; g1 == 1'b1;});
            req.trans_type = timer_transaction::GATE_CONTROL;
            finish_item(req);
        end
        
        // Counter0 gate disabled, Counter1 enabled
        repeat(10) begin
            req = timer_transaction::type_id::create("gate0_off");
            start_item(req);
            assert(req.randomize() with {a == 2'b11; g0 == 1'b0; g1 == 1'b1;});
            req.trans_type = timer_transaction::GATE_CONTROL;
            finish_item(req);
        end
        
        // Counter1 gate disabled, Counter0 enabled
        repeat(10) begin
            req = timer_transaction::type_id::create("gate1_off");
            start_item(req);
            assert(req.randomize() with {a == 2'b11; g0 == 1'b1; g1 == 1'b0;});
            req.trans_type = timer_transaction::GATE_CONTROL;
            finish_item(req);
        end
        
        // Both gates disabled
        repeat(10) begin
            req = timer_transaction::type_id::create("both_gates_off");
            start_item(req);
            assert(req.randomize() with {a == 2'b11; g0 == 1'b0; g1 == 1'b0;});
            req.trans_type = timer_transaction::GATE_CONTROL;
            finish_item(req);
        end
        
        `uvm_info("SEQUENCE", "Gate control sequence completed", UVM_MEDIUM)
    endtask
endclass



// Random stimulus sequence
class timer_random_sequence extends timer_base_sequence;
    `uvm_object_utils(timer_random_sequence)
    
    function new(string name = "timer_random_sequence");
        super.new(name);
    endfunction
    
    virtual task body();
        timer_transaction req;
        
        `uvm_info("SEQUENCE", "Starting random sequence", UVM_MEDIUM)
        
      repeat(10) begin
            req = timer_transaction::type_id::create("random_req");
            start_item(req);
            assert(req.randomize());
            finish_item(req);
        end
        
        `uvm_info("SEQUENCE", "Random sequence completed", UVM_MEDIUM)
    endtask
endclass

// Mode testing sequence
class timer_mode_test_sequence extends timer_base_sequence;
    `uvm_object_utils(timer_mode_test_sequence)
    
    function new(string name = "timer_mode_test_sequence");
        super.new(name);
    endfunction
    
    virtual task body();
        timer_transaction req;
        
        `uvm_info("SEQUENCE", "Starting mode test sequence", UVM_MEDIUM)
        
        // Test all modes for Counter0
        for (int mode = 0; mode < 5; mode++) begin
            // Configure Counter0 with appropriate count for mode
            logic [7:0] test_count;
            case (mode)
                2, 3, 4: test_count = (mode == 2) ? 8'd20 : 8'd21; // Even for mode 2, odd for 3,4
                default: test_count = 8'd15; // Any count for modes 0,1
            endcase
            
            // Write count to Counter0 (lower nibble )
            req = timer_transaction::type_id::create("mode_test_lower");
            start_item(req);
            assert(req.randomize() with {a == 2'b00; d == test_count[3:0]; g0 == 1'b1; g1 == 1'b1;});
            finish_item(req);
            

            
            // Let counter run for multiple cycles to observe behavior
          repeat( 3) begin
                req = timer_transaction::type_id::create("mode_test_observe");
                start_item(req);
                assert(req.randomize() with {a == 2'b11; g0 == 1'b1; g1 == 1'b1;});
                finish_item(req);
            end
        end
        
        `uvm_info("SEQUENCE", "Mode test sequence completed", UVM_MEDIUM)
    endtask
endclass

// Boundary value testing sequence
class timer_boundary_test_sequence extends timer_base_sequence;
    `uvm_object_utils(timer_boundary_test_sequence)
    
    function new(string name = "timer_boundary_test_sequence");
        super.new(name);
    endfunction
    
    virtual task body();
        timer_transaction req;
        logic [7:0] boundary_values_c0[] = '{2, 3, 149, 150}; // Counter0 boundaries
        logic [7:0] boundary_values_c1[] = '{50, 51, 199, 200}; // Counter1 boundaries
        
        `uvm_info("SEQUENCE", "Starting boundary test sequence", UVM_MEDIUM)
        
        // Test Counter0 boundary values
        foreach (boundary_values_c0[i]) begin
            logic [7:0] test_val = boundary_values_c0[i];
            
            // Write lower nibble
            req = timer_transaction::type_id::create("boundary_c0_lower");
            start_item(req);
            assert(req.randomize() with {a == 2'b00; d == test_val[3:0]; g0 == 1'b1; g1 == 1'b1;});
            finish_item(req);
            
            // Write upper nibble
            req = timer_transaction::type_id::create("boundary_c0_upper");
            start_item(req);
            assert(req.randomize() with {a == 2'b00; d == test_val[7:4]; g0 == 1'b1; g1 == 1'b1;});
            finish_item(req);
            
            // Test with different modes
            for (int mode = 0; mode < 3; mode++) begin
                req = timer_transaction::type_id::create("boundary_c0_mode");
                start_item(req);
                assert(req.randomize() with {a == 2'b10; d == {1'b0, mode[2:0]}; g0 == 1'b1; g1 == 1'b1;});
                finish_item(req);
                
                // Observe behavior
                repeat(10) begin
                    req = timer_transaction::type_id::create("boundary_c0_observe");
                    start_item(req);
                    assert(req.randomize() with {a == 2'b11; g0 == 1'b1; g1 == 1'b1;});
                    finish_item(req);
                end
            end
        end
        
        // Test Counter1 boundary values
        foreach (boundary_values_c1[i]) begin
            logic [7:0] test_val = boundary_values_c1[i];
            
            // Write lower nibble
            req = timer_transaction::type_id::create("boundary_c1_lower");
            start_item(req);
            assert(req.randomize() with {a == 2'b01; d == test_val[3:0]; g0 == 1'b1; g1 == 1'b1;});
            finish_item(req);
            
            // Write upper nibble
            req = timer_transaction::type_id::create("boundary_c1_upper");
            start_item(req);
            assert(req.randomize() with {a == 2'b01; d == test_val[7:4]; g0 == 1'b1; g1 == 1'b1;});
            finish_item(req);
            

        end
        
        `uvm_info("SEQUENCE", "Boundary test sequence completed", UVM_MEDIUM)
    endtask
endclass

// Edge case testing sequence
class timer_edge_case_sequence extends timer_base_sequence;
    `uvm_object_utils(timer_edge_case_sequence)
    
    function new(string name = "timer_edge_case_sequence");
        super.new(name);
    endfunction
    
    virtual task body();
        timer_transaction req;
        
        `uvm_info("SEQUENCE", "Starting edge case sequence", UVM_MEDIUM)
        
        // Test invalid modes (modes 5-7)
        for (int invalid_mode = 5; invalid_mode < 8; invalid_mode++) begin
            req = timer_transaction::type_id::create("invalid_mode");
            start_item(req);
            assert(req.randomize() with {a == 2'b10; d == {1'b0, invalid_mode[2:0]}; g0 == 1'b1; g1 == 1'b1;});
            finish_item(req);
            
            // Observe behavior with invalid mode
          repeat(10) begin
                req = timer_transaction::type_id::create("invalid_mode_observe");
                start_item(req);
                assert(req.randomize() with {a == 2'b11; g0 == 1'b1; g1 == 1'b1;});
                finish_item(req);
            end
        end
        
        // Test out-of-range count values
        // Try to write 1 to Counter0 (should clamp to 2)
        req = timer_transaction::type_id::create("underflow_c0_lower");
        start_item(req);
        assert(req.randomize() with {a == 2'b00; d == 4'h1; g0 == 1'b1; g1 == 1'b1;});
        finish_item(req);
        
        req = timer_transaction::type_id::create("underflow_c0_upper");
        start_item(req);
        assert(req.randomize() with {a == 2'b00; d == 4'h0; g0 == 1'b1; g1 == 1'b1;});
        finish_item(req);
        

        req = timer_transaction::type_id::create("overflow_c0_upper");
        start_item(req);
        assert(req.randomize() with {a == 2'b00; d == 4'hF; g0 == 1'b1; g1 == 1'b1;});
        finish_item(req);
        
        // Test mode/count mismatches (even count with odd-only modes)
        // Set even count
        req = timer_transaction::type_id::create("mismatch_count_lower");
        start_item(req);
        assert(req.randomize() with {a == 2'b00; d == 4'h4; g0 == 1'b1; g1 == 1'b1;});
        finish_item(req);

        
        // Try odd-only mode (should be invalid)
        req = timer_transaction::type_id::create("mismatch_mode");
        start_item(req);
        assert(req.randomize() with {a == 2'b10; d == 4'b0011; g0 == 1'b1; g1 == 1'b1;}); // mode 3
        finish_item(req);
        
        // Observe invalid combination
      repeat(10) begin
            req = timer_transaction::type_id::create("mismatch_observe");
            start_item(req);
            assert(req.randomize() with {a == 2'b11; g0 == 1'b1; g1 == 1'b1;});
            finish_item(req);
        end
        
        `uvm_info("SEQUENCE", "Edge case sequence completed", UVM_MEDIUM)
    endtask
endclass