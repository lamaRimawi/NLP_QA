`ifndef TIMER_GOLDEN_MODEL_SV
`define TIMER_GOLDEN_MODEL_SV
class timer_golden_model extends uvm_component;
    
    // Internal state modeling the DUT registers
    logic [7:0] counter0_reg = 8'd0;   // Counter0 count value (range: 2–150)
    logic [7:0] counter1_reg = 8'd0;   // Counter1 count value (range: 50–200)
    logic [7:0] control_reg = 8'd0;    // Control register
    logic [2:0] mode0_reg = 3'd0;      // Mode for counter0
    logic [2:0] mode1_reg = 3'd0;      // Mode for counter1
    
    // Two-step write process (matching DUT's nibble-by-nibble approach)
    logic [3:0] temp_low = 4'd0;       // Stores low nibble
    logic [1:0] last_addr = 2'd0;      // Tracks previous address
    logic write_phase = 1'b0;          // 0: low nibble, 1: high nibble
    
    // Counter states for output prediction
    logic [7:0] count0 = 8'd0;         // Current count for counter0
    logic [7:0] count1 = 8'd0;         // Current count for counter1
    logic [7:0] state0 = 8'd0;         // State for counter0 (position in cycle)
    logic [7:0] state1 = 8'd0;         // State for counter1 (position in cycle)
    
    // Previous gate states for edge detection
    logic g0_prev = 1'b0;
    logic g1_prev = 1'b0;
    
    `uvm_component_utils(timer_golden_model)
    
    function new(string name = "timer_golden_model", uvm_component parent);
        super.new(name, parent);
    endfunction
    
    // Reset model state
    function void reset_model();
        counter0_reg = 8'd0;
        counter1_reg = 8'd0;
        control_reg = 8'd0;
        mode0_reg = 3'd0;
        mode1_reg = 3'd0;
        temp_low = 4'd0;
        last_addr = 2'd0;
        write_phase = 1'b0;
        count0 = 8'd0;
        count1 = 8'd0;
        state0 = 8'd0;
        state1 = 8'd0;
        g0_prev = 1'b0;
        g1_prev = 1'b0;
    endfunction
    
    // Process register write (matching DUT's two-step nibble approach)
    function void process_register_write(logic [1:0] a, logic [3:0] d);
        if (!write_phase) begin  // First write: store low nibble
            temp_low = d;
            last_addr = a;
            write_phase = 1'b1;
        end else begin           // Second write: store high nibble + update register
            if (a == last_addr) begin  // Only update if same address
                case (a)
                    2'b00: begin // Counter0 register
                        counter0_reg = {d, temp_low};
                        `uvm_info("GOLDEN_MODEL", $sformatf("Counter0 reg updated to %d", counter0_reg), UVM_MEDIUM)
                    end
                    
                    2'b01: begin // Counter1 register
                        counter1_reg = {d, temp_low};
                        `uvm_info("GOLDEN_MODEL", $sformatf("Counter1 reg updated to %d", counter1_reg), UVM_MEDIUM)
                    end
                    
                    2'b10: begin // Control register
                        control_reg = {d, temp_low};
                        // Update mode registers based on control bit (c)
                        if (temp_low[3]) // c=1: update counter1's mode
                            mode1_reg = temp_low[2:0];
                        else             // c=0: update counter0's mode
                            mode0_reg = temp_low[2:0];
                        `uvm_info("GOLDEN_MODEL", $sformatf("Control reg updated: counter=%d, mode=%d", 
                                  temp_low[3], temp_low[2:0]), UVM_MEDIUM)
                    end
                    
                    2'b11: begin // Reserved/unused
                        `uvm_info("GOLDEN_MODEL", "Write to reserved address ignored", UVM_MEDIUM)
                    end
                endcase
            end
            write_phase = 1'b0;  // Reset for next low nibble
        end
    endfunction
    
    // Counter 0 Logic (Range: 2-150)
    function void update_counter0(logic g0);
        if (g0 && counter0_reg >= 8'd2 && counter0_reg <= 8'd150) begin
            // Initialize counter on gate rising edge or when count reaches 0
            if ((!g0_prev && g0) || (count0 == 8'd0)) begin
                count0 = counter0_reg - 1'b1;  // Load with (counter_reg - 1)
                state0 = 8'd0;                 // Reset state
            end else begin
                count0 = count0 - 1'b1;        // Decrement count
                state0 = state0 + 1'b1;        // Increment state
            end
        end else if (!g0) begin
            // Keep current values when gate is low (freeze)
            // count0 and state0 remain unchanged
        end else begin
            // Invalid range - reset counters
            count0 = 8'd0;
            state0 = 8'd0;
        end
    endfunction
    
    // Counter 1 Logic (Range: 50-200)
    function void update_counter1(logic g1);
        if (g1 && counter1_reg >= 8'd50 && counter1_reg <= 8'd200) begin
            // Initialize counter on gate rising edge or when count reaches 0
            if ((!g1_prev && g1) || (count1 == 8'd0)) begin
                count1 = counter1_reg - 1'b1;  // Load with (counter_reg - 1)
                state1 = 8'd0;                 // Reset state
            end else begin
                count1 = count1 - 1'b1;        // Decrement count
                state1 = state1 + 1'b1;        // Increment state
            end
        end else if (!g1) begin
            // Keep current values when gate is low (freeze)
            // count1 and state1 remain unchanged
        end else begin
            // Invalid range - reset counters
            count1 = 8'd0;
            state1 = 8'd0;
        end
    endfunction
    
    // Generate output for Counter 0
    function logic generate_output0(logic g0);
        if (!g0 || counter0_reg < 8'd2 || counter0_reg > 8'd150) begin
            return 1'b0;  // Output low when gate is off or invalid range
        end else begin
            case (mode0_reg)
                3'b000: begin // Mode 0: 1/n duty cycle (n-1 low, 1 high)
                    return (state0 == (counter0_reg - 1'b1)) ? 1'b1 : 1'b0;
                end
                3'b001: begin // Mode 1: (n-1)/n duty cycle (1 low, n-1 high)
                    return (state0 == 8'd0) ? 1'b0 : 1'b1;
                end
                3'b010: begin // Mode 2: 1/2 duty cycle (n/2 low, n/2 high) - even n only
                    if (counter0_reg[0] == 1'b0) begin  // Even number check
                        return (state0 < (counter0_reg >> 1)) ? 1'b0 : 1'b1;
                    end else begin
                        return 1'b0;  // Invalid for odd numbers
                    end
                end
                3'b011: begin // Mode 3: (n+1)/2 low, (n-1)/2 high - odd n only
                    if (counter0_reg[0] == 1'b1) begin  // Odd number check
                        return (state0 < ((counter0_reg + 1'b1) >> 1)) ? 1'b0 : 1'b1;
                    end else begin
                        return 1'b0;  // Invalid for even numbers
                    end
                end
                3'b100: begin // Mode 4: (n-1)/2 low, (n+1)/2 high - odd n only
                    if (counter0_reg[0] == 1'b1) begin  // Odd number check
                        return (state0 < ((counter0_reg - 1'b1) >> 1)) ? 1'b0 : 1'b1;
                    end else begin
                        return 1'b0;  // Invalid for even numbers
                    end
                end
                default: return 1'b0;  // Invalid mode
            endcase
        end
    endfunction
    
    // Generate output for Counter 1
    function logic generate_output1(logic g1);
        if (!g1 || counter1_reg < 8'd50 || counter1_reg > 8'd200) begin
            return 1'b0;  // Output low when gate is off or invalid range
        end else begin
            case (mode1_reg)
                3'b000: begin // Mode 0: 1/n duty cycle (n-1 low, 1 high)
                    return (state1 == (counter1_reg - 1'b1)) ? 1'b1 : 1'b0;
                end
                3'b001: begin // Mode 1: (n-1)/n duty cycle (1 low, n-1 high)
                    return (state1 == 8'd0) ? 1'b0 : 1'b1;
                end
                3'b010: begin // Mode 2: 1/2 duty cycle (n/2 low, n/2 high) - even n only
                    if (counter1_reg[0] == 1'b0) begin  // Even number check
                        return (state1 < (counter1_reg >> 1)) ? 1'b0 : 1'b1;
                    end else begin
                        return 1'b0;  // Invalid for odd numbers
                    end
                end
                3'b011: begin // Mode 3: (n+1)/2 low, (n-1)/2 high - odd n only
                    if (counter1_reg[0] == 1'b1) begin  // Odd number check
                        return (state1 < ((counter1_reg + 1'b1) >> 1)) ? 1'b0 : 1'b1;
                    end else begin
                        return 1'b0;  // Invalid for even numbers
                    end
                end
                3'b100: begin // Mode 4: (n-1)/2 low, (n+1)/2 high - odd n only
                    if (counter1_reg[0] == 1'b1) begin  // Odd number check
                        return (state1 < ((counter1_reg - 1'b1) >> 1)) ? 1'b0 : 1'b1;
                    end else begin
                        return 1'b0;  // Invalid for even numbers
                    end
                end
                default: return 1'b0;  // Invalid mode
            endcase
        end
    endfunction
    
    // Update model state and predict outputs
    function timer_transaction predict(timer_transaction req);
        timer_transaction expected;
        
        expected = timer_transaction::type_id::create("expected");
        expected.copy(req);
        
        // Process register writes (two-step nibble process)
        process_register_write(req.a, req.d);
        
        // Update counter states
        update_counter0(req.g0);
        update_counter1(req.g1);
        
        // Generate outputs
        expected.out0 = generate_output0(req.g0);
        expected.out1 = generate_output1(req.g1);
        
        // Update previous gate states
        g0_prev = req.g0;
        g1_prev = req.g1;
        
        return expected;
    endfunction
    
    // Debug function to print current state
    function void print_state();
        `uvm_info("GOLDEN_MODEL", $sformatf("State: c0_reg=%d, c1_reg=%d, mode0=%d, mode1=%d", 
                  counter0_reg, counter1_reg, mode0_reg, mode1_reg), UVM_MEDIUM)
        `uvm_info("GOLDEN_MODEL", $sformatf("Counters: count0=%d, state0=%d, count1=%d, state1=%d", 
                  count0, state0, count1, state1), UVM_MEDIUM)
    endfunction
    
endclass
`endif // TIMER_GOLDEN_MODEL_SV
