# Timer UVM Verification Environment

A complete SystemVerilog-based verification environment using Universal Verification Methodology (UVM) for digital timer IP verification, including both the design under test (DUT) and comprehensive testbench.

## About

This project implements a complete verification environment for a digital timer IP using industry-standard UVM methodology. The project demonstrates advanced verification techniques, comprehensive test coverage, and professional-grade testbench architecture for hardware verification.

## Project Overview

This UVM-based verification project includes:
- **Complete Timer IP** - Digital timer design implementation (DUT)
- **Professional UVM Testbench** - Industry-standard verification framework
- **Comprehensive Testing** - Multiple test scenarios and edge cases
- **Coverage-Driven Verification** - Functional and code coverage tracking
- **Golden Model** - Reference implementation for result comparison
- **SystemVerilog Implementation** - Modern hardware verification language

## File Structure

```
timer-uvm-verification-environment/
├── README.md                  # Project documentation
├── design.sv                  # Timer DUT implementation
├── sequences.sv               # UVM sequence library
├── testbench.sv              # Main testbench and DUT instantiation
├── tests.sv                  # Test case implementations
├── timer_agent.sv            # UVM agent for timer interface
├── timer_base_test.sv        # Base test class
├── timer_driver.sv           # UVM driver implementation
├── timer_env.sv              # UVM environment
├── timer_golden_model.sv     # Reference model for comparison
├── timer_interface.sv        # SystemVerilog interface
├── timer_monitor.sv          # UVM monitor implementation
├── timer_scoreboard.sv       # Result checking and analysis
├── timer_sequencer.sv        # UVM sequencer
└── timer_transaction.sv      # Transaction/sequence item definitions
```

## Complete Verification Solution

### Design Under Test Implementation
The `design.sv` file contains a fully functional digital timer with:

```systemverilog
module timer_dut #(
    parameter WIDTH = 32,
    parameter PRESCALER_WIDTH = 8
)(
    input  logic                    clk,
    input  logic                    rst_n,
    input  logic [WIDTH-1:0]        load_value,
    input  logic [PRESCALER_WIDTH-1:0] prescaler,
    input  logic                    load,
    input  logic                    enable,
    input  logic                    int_enable,
    output logic [WIDTH-1:0]        count,
    output logic                    interrupt,
    output logic                    zero_flag
);

// Timer implementation with:
// - Configurable prescaler for clock division
// - Load operation for setting initial count
// - Enable control for starting/stopping timer
// - Interrupt generation on timer expiration
// - Zero flag indication

endmodule
```

### Verification Environment Architecture

### Verification Environment Components

#### Design Under Test (DUT)
- **`design.sv`** - Complete timer IP implementation
  - Configurable timer functionality
  - Interrupt generation capabilities
  - Reset and enable controls
  - Prescaler support for different time bases

#### Core UVM Components
- **`timer_env.sv`** - Top-level UVM environment
- **`timer_agent.sv`** - UVM agent containing driver, monitor, sequencer
- **`timer_driver.sv`** - Drives stimulus to DUT interfaces
- **`timer_monitor.sv`** - Observes and collects interface activity
- **`timer_sequencer.sv`** - Manages sequence execution
- **`timer_scoreboard.sv`** - Result checking and coverage analysis

#### Test Infrastructure
- **`timer_base_test.sv`** - Base test class with common functionality
- **`tests.sv`** - Collection of specific test cases
- **`testbench.sv`** - Main testbench and DUT instantiation
- **`timer_interface.sv`** - SystemVerilog interface definitions

#### Verification Utilities
- **`timer_transaction.sv`** - Transaction objects for stimulus
- **`sequences.sv`** - UVM sequence library for test scenarios
- **`timer_golden_model.sv`** - Reference model for expected behavior

## Technologies Used

- **Hardware Description Language**: SystemVerilog
- **Verification Methodology**: UVM (Universal Verification Methodology)
- **Simulation Tools**: QuestaSim/ModelSim, VCS, or Xcelium
- **Coverage Tools**: Built-in SystemVerilog coverage
- **Build System**: Makefile or simulation scripts
- **Version Control**: Git

## Key Features

### Timer Design Features (`design.sv`)
- **Configurable Width** - Parameterizable timer width
- **Countdown Operation** - Configurable initial value countdown
- **Interrupt Generation** - Timer expiration interrupt
- **Prescaler Support** - Clock division for different time bases
- **Enable/Disable Control** - Runtime timer control
- **Synchronous Reset** - Proper reset behavior
- **Status Indicators** - Timer state and flags

### UVM Testbench Features
- **Functional Verification** - Complete timer functionality testing
- **Timing Verification** - Accurate timing behavior validation
- **Edge Case Testing** - Boundary conditions and corner cases
- **Reset Testing** - Proper reset behavior verification
- **Interrupt Testing** - Timer interrupt generation validation
- **Configuration Testing** - All timer modes and settings

### UVM Implementation
- **Layered Architecture** - Proper UVM component hierarchy
- **Reusable Components** - Modular and configurable testbench
- **Sequence Library** - Comprehensive stimulus generation
- **Coverage Driven** - Functional and code coverage goals
- **Constraint Random** - Advanced stimulus generation

### Advanced Verification Features
- **Golden Model** - Reference implementation for comparison
- **Scoreboard** - Automated result checking
- **Coverage Analysis** - Comprehensive coverage tracking
- **Parameterizable Tests** - Configurable test scenarios
- **Error Injection** - Fault testing capabilities

## Getting Started

### Prerequisites
- SystemVerilog simulator (QuestaSim, VCS, Xcelium)
- UVM library (usually included with simulator)
- Make utility
- Basic knowledge of UVM methodology

### Environment Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/lamaRimawi/timer-uvm-verification-environment.git
   cd timer-uvm-verification-environment
   ```

2. **Set up simulation environment:**
   ```bash
   # For QuestaSim/ModelSim
   export QUESTA_HOME=/path/to/questasim
   export UVM_HOME=$QUESTA_HOME/uvm-1.2
   
   # For VCS
   export VCS_HOME=/path/to/vcs
   export UVM_HOME=$VCS_HOME/etc/uvm
   ```

3. **Compile and run:**
   ```bash
   # Basic compilation
   make compile
   
   # Run specific test
   make run TEST=timer_basic_test
   
   # Run with GUI
   make run_gui TEST=timer_comprehensive_test
   ```

## Usage

### Running Tests

#### Basic Test Execution
```bash
# Run base test
make run TEST=timer_base_test

# Run specific functionality tests
make run TEST=timer_countdown_test
make run TEST=timer_interrupt_test
make run TEST=timer_reset_test
```

#### Advanced Test Options
```bash
# Run with coverage
make run TEST=timer_base_test COV=1

# Run with specific seed
make run TEST=timer_random_test SEED=12345

# Run multiple iterations
make run TEST=timer_stress_test ITERATIONS=100
```

#### GUI Debug Mode
```bash
# Open simulator GUI for debugging
make debug TEST=timer_base_test

# Run with waveform generation
make run TEST=timer_base_test WAVES=1
```

### Test Configuration

#### Makefile Example
```makefile
# Simulation setup
SIMULATOR = questasim
UVM_VERSION = uvm-1.2
TOP_MODULE = timer_tb

# Source files
DESIGN_FILES = design.sv
TB_FILES = timer_interface.sv timer_transaction.sv timer_driver.sv \
           timer_monitor.sv timer_agent.sv timer_env.sv \
           timer_base_test.sv tests.sv testbench.sv

# Compilation targets
compile:
	vlog -sv +incdir+$(UVM_HOME)/src $(UVM_HOME)/src/uvm_pkg.sv
	vlog -sv +incdir+. $(DESIGN_FILES) $(TB_FILES)

# Simulation targets
run:
	vsim -c $(TOP_MODULE) +UVM_TESTNAME=$(TEST) -do "run -all; quit"

run_gui:
	vsim $(TOP_MODULE) +UVM_TESTNAME=$(TEST)
```

## Test Scenarios

### Functional Tests
1. **Basic Timer Operation**
   - Timer initialization and configuration
   - Count-down functionality
   - Timer expiration detection

2. **Advanced Features**
   - Multiple timer modes
   - Interrupt generation and handling
   - Timer chaining capabilities

3. **Edge Cases**
   - Boundary value testing
   - Overflow/underflow conditions
   - Rapid configuration changes

### Coverage Goals
- **Functional Coverage**: 100% of timer features
- **Code Coverage**: >95% statement, branch, condition
- **Cross Coverage**: Feature interaction scenarios
- **Assertion Coverage**: All SVA assertions triggered

## UVM Component Details

### Timer Transaction (`timer_transaction.sv`)
```systemverilog
class timer_transaction extends uvm_sequence_item;
    rand bit [31:0] timer_value;
    rand bit [7:0]  prescaler;
    rand bit        enable;
    rand bit        interrupt_enable;
    
    constraint valid_timer_c {
        timer_value inside {[1:32'hFFFFFFFF]};
        prescaler inside {[1:255]};
    }
    
    `uvm_object_utils_begin(timer_transaction)
        `uvm_field_int(timer_value, UVM_ALL_ON)
        `uvm_field_int(prescaler, UVM_ALL_ON)
        `uvm_field_int(enable, UVM_ALL_ON)
        `uvm_field_int(interrupt_enable, UVM_ALL_ON)
    `uvm_object_utils_end
endclass
```

### Timer Driver (`timer_driver.sv`)
```systemverilog
class timer_driver extends uvm_driver #(timer_transaction);
    virtual timer_interface vif;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        timer_transaction req;
        
        forever begin
            seq_item_port.get_next_item(req);
            drive_transaction(req);
            seq_item_port.item_done();
        end
    endtask
    
    virtual task drive_transaction(timer_transaction req);
        @(posedge vif.clk);
        vif.timer_load <= req.timer_value;
        vif.prescaler <= req.prescaler;
        vif.enable <= req.enable;
        vif.int_enable <= req.interrupt_enable;
        @(posedge vif.clk);
    endtask
endclass
```

### Sequences Library (`sequences.sv`)
```systemverilog
// Basic timer sequence
class timer_basic_seq extends uvm_sequence #(timer_transaction);
    `uvm_object_utils(timer_basic_seq)
    
    virtual task body();
        timer_transaction req;
        
        req = timer_transaction::type_id::create("req");
        start_item(req);
        assert(req.randomize() with {
            timer_value inside {[100:1000]};
            enable == 1;
        });
        finish_item(req);
    endtask
endclass

// Stress test sequence
class timer_stress_seq extends uvm_sequence #(timer_transaction);
    `uvm_object_utils(timer_stress_seq)
    
    virtual task body();
        repeat(100) begin
            timer_transaction req = timer_transaction::type_id::create("req");
            start_item(req);
            assert(req.randomize());
            finish_item(req);
        end
    endtask
endclass
```

## Coverage Implementation

### Functional Coverage
```systemverilog
covergroup timer_cg @(posedge clk);
    timer_value_cp: coverpoint timer_load {
        bins low_values = {[0:100]};
        bins mid_values = {[101:1000]};
        bins high_values = {[1001:$]};
    }
    
    prescaler_cp: coverpoint prescaler {
        bins small = {[1:10]};
        bins medium = {[11:100]};
        bins large = {[101:255]};
    }
    
    cross_coverage: cross timer_value_cp, prescaler_cp;
endgroup
```

### Assertions
```systemverilog
// Timer countdown assertion
property timer_countdown_p;
    @(posedge clk) disable iff (!rst_n)
    (enable && timer_count > 0) |=> (timer_count == $past(timer_count) - 1);
endproperty
assert_timer_countdown: assert property(timer_countdown_p);

// Interrupt generation assertion
property interrupt_generation_p;
    @(posedge clk) disable iff (!rst_n)
    (timer_count == 0 && int_enable) |-> interrupt;
endproperty
assert_interrupt: assert property(interrupt_generation_p);
```

## Learning Outcomes

### Technical Skills Developed
- **UVM Methodology** - Industry-standard verification framework
- **SystemVerilog** - Advanced hardware verification language
- **Verification Planning** - Systematic test strategy development
- **Coverage Analysis** - Functional and code coverage techniques
- **Assertion-Based Verification** - Property specification and checking

### Industry Knowledge
- **Digital Design Verification** - Professional verification practices
- **IP Verification** - Reusable verification components
- **Testbench Architecture** - Layered verification environment design
- **Debugging Techniques** - Advanced simulation and debug methods
- **Quality Metrics** - Coverage and verification closure

## Challenges Overcome

1. **UVM Learning Curve** - Mastering complex verification methodology
2. **SystemVerilog Proficiency** - Advanced language features and constructs
3. **Coverage Closure** - Achieving comprehensive verification goals
4. **Debug Complexity** - Troubleshooting complex verification scenarios
5. **Performance Optimization** - Efficient simulation and runtime

## Future Enhancements

- [ ] **Formal Verification** - Add formal property verification
- [ ] **Power-Aware Testing** - Low-power verification scenarios
- [ ] **Protocol Compliance** - Standard protocol verification
- [ ] **Regression Automation** - Automated test suite execution
- [ ] **Advanced Coverage** - Temporal and cross-module coverage
- [ ] **Verification IP Integration** - Standard VIP components

## Industry Applications

### Professional Relevance
- **ASIC/FPGA Verification** - Industry-standard verification approach
- **IP Verification** - Reusable component verification
- **System-Level Testing** - Complex system verification
- **Certification Support** - Safety-critical system verification

## Contact

**Lama Rimawi**  
GitHub: [@lamaRimawi](https://github.com/lamaRimawi)  
Repository: [timer-uvm-verification-environment](https://github.com/lamaRimawi/timer-uvm-verification-environment)

This project demonstrates professional-level verification skills using industry-standard UVM methodology for complete digital timer verification with both design and testbench implementation.

---

*Project Type: Hardware Verification | Methodology: UVM | Language: SystemVerilog | Status: Complete*
