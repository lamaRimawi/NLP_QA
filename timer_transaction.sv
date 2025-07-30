`ifndef TIMER_TRANSACTION_SV
`define TIMER_TRANSACTION_SV
class timer_transaction extends uvm_sequence_item;
    
    // Input fields
    rand logic [3:0] d;
    rand logic [1:0] a;
    rand logic       g0;
    rand logic       g1;
    
    // Output fields
    logic out0;
    logic out1;
    
    // Transaction type for tracking
    typedef enum {WRITE_LOWER, WRITE_UPPER, CONTROL_WRITE, GATE_CONTROL} trans_type_e;
    trans_type_e trans_type;
    
    // Additional fields for register writes
    logic [7:0] full_value;  // For tracking complete 8-bit writes
    logic [2:0] target_mode; // Expected mode after control write
    logic       target_counter; // 0 for counter0, 1 for counter1
    
    // Constraints
    constraint address_c {
        a dist {2'b00 := 30, 2'b01 := 30, 2'b10 := 30, 2'b11 := 10}; // Less weight on undefined address
    }
    
    constraint data_c {
        d inside {[4'h0:4'hF]};
    }
    
    constraint gate_c {
        g0 dist {1'b0 := 20, 1'b1 := 80}; // More weight on enabled gates
        g1 dist {1'b0 := 20, 1'b1 := 80};
    }
    
    `uvm_object_utils_begin(timer_transaction)
        `uvm_field_int(d, UVM_ALL_ON)
        `uvm_field_int(a, UVM_ALL_ON)
        `uvm_field_int(g0, UVM_ALL_ON)
        `uvm_field_int(g1, UVM_ALL_ON)
        `uvm_field_int(out0, UVM_ALL_ON)
        `uvm_field_int(out1, UVM_ALL_ON)
        `uvm_field_enum(trans_type_e, trans_type, UVM_ALL_ON)
        `uvm_field_int(full_value, UVM_ALL_ON)
        `uvm_field_int(target_mode, UVM_ALL_ON)
        `uvm_field_int(target_counter, UVM_ALL_ON)
    `uvm_object_utils_end
    
    function new(string name = "timer_transaction");
        super.new(name);
    endfunction
    
endclass
`endif // TIMER_TRANSACTION_SV
