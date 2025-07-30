# Timer UVM Verification Environment

A comprehensive SystemVerilog-based verification environment using Universal Verification Methodology (UVM) for a programmable dual-counter timer controller with multiple operating modes and gate control functionality.

## About

This project implements a complete UVM-based verification environment for a sophisticated timer controller featuring dual independent counters with programmable modes, gate control, and configurable duty cycles. The project demonstrates advanced verification techniques for timing-critical hardware components.

## Project Overview

This Timer verification project includes:
- **Dual-Counter Timer Design** - Complete programmable timer with two independent 8-bit counters
- **UVM Verification Framework** - Industry-standard verification methodology
- **Golden Reference Model** - Bit-accurate behavioral model matching DUT exactly
- **Multiple Operating Modes** - 5 different duty cycle modes per counter
- **Comprehensive Testing** - Register configuration, mode testing, boundary conditions
- **Gate Control Verification** - Independent enable/disable control for each counter

## Timer Controller Features

### Dual Counter Architecture
- **Counter 0**: 8-bit programmable counter (valid range: 2-150)
- **Counter 1**: 8-bit programmable counter (valid range: 50-200)
- **Independent Control**: Separate gate inputs (g0, g1) and outputs (out0, out1)
- **Mode Configuration**: 5 operating modes per counter (0-4)

### Operating Modes
Each counter supports 5 distinct operating modes:

| Mode | Description | Duty Cycle | Valid For |
|------|-------------|------------|-----------|
| 0 | Pulse Mode | 1/n (n-1 low, 1 high) | Any count |
| 1 | Inverted Pulse | (n-1)/n (1 low, n-1 high) | Any count |
| 2 | Square Wave | 50% (n/2 low, n/2 high) | Even counts only |
| 3 | Asymmetric High | (n+1)/2 low, (n-1)/2 high | Odd counts only |
| 4 | Asymmetric Low | (n-1)/2 low, (n+1)/2 high | Odd counts only |

### Register Interface
- **4-bit Data Bus**: Nibble-based register access
- **2-bit Address**: 4 addressable locations
- **Two-Phase Write**: Lower nibble followed by upper nibble
- **Address Map**:
  - `00`: Counter 0 value register
  - `01`: Counter 1 value register  
  - `10`: Control register (mode configuration)
  - `11`: Reserved/unused

### Control Register Format
```
Bit 7-4: Upper nibble (second write)
Bit 3:   Counter select (c) - 0: Counter0, 1: Counter1
Bit 2-0: Mode select (000-100 for modes 0-4)
```

## File Structure

```
timer-uvm-verification-environment/
├── README.md                    # Project documentation
├── design.sv                    # Timer controller DUT (timer module)
├── timer_interface.sv           # SystemVerilog interface definition
├── timer_transaction.sv         # UVM transaction class
├── timer_sequencer.sv           # UVM sequencer
├── timer_driver.sv              # UVM driver implementation
├── timer_monitor.sv             # UVM monitor implementation
├── timer_golden_model.sv        # Reference model implementation
├── timer_scoreboard.sv          # Result checking and analysis
├── timer_agent.sv               # UVM agent
├── timer_env.sv                 # UVM environment
├── timer_base_test.sv           # Base test class
├── sequences.sv                 # Test sequence library
├── tests.sv                     # Specific test implementations
└── timer_tb_top.sv              # Top-level testbench
```

## Technologies Used

- **Hardware Description Language**: SystemVerilog
- **Verification Methodology**: UVM (Universal Verification Methodology)
- **Design Domain**: Programmable Timer Controllers
- **Simulation Tools**: QuestaSim/ModelSim, VCS, or Xcelium
- **Verification Techniques**: Golden model comparison, assertion-based verification
- **Version Control**: Git

## Timer Implementation Details

### Two-Phase Register Writing
```systemverilog
// First write: store lower nibble
if (!write_phase) begin
    temp_low <= d;
    last_addr <= a;
    write_phase <= 1'b1;
end 
// Second write: combine with upper nibble and update register
else begin
    if (a == last_addr) begin
        case (a)
            2'b00: counter0_reg <= {d, temp_low};  // Counter0 value
            2'b01: counter1_reg <= {d, temp_low};  // Counter1 value
            2'b10: begin  // Control register
                control_reg <= {d, temp_low};
                if (temp_low[3]) mode1_reg <= temp_low[2:0];  // Counter1 mode
                else             mode0_reg <= temp_low[2:0];  // Counter0 mode
            end
        endcase
    end
    write_phase <= 1'b0;
end
```

### Counter Logic with State Tracking
```systemverilog
// Counter with state-based output generation
if (g0 && counter0_reg >= 8'd2 && counter0_reg <= 8'd150) begin
    if ((!g0_prev && g0) || (count0 == 8'd0)) begin
        count0 <= counter0_reg - 1'b1;  // Load count value
        state0 <= 8'd0;                 // Reset state position
    end else begin
        count0 <= count0 - 1'b1;        // Decrement counter
        state0 <= state0 + 1'b1;        // Advance state
    end
end
```

### Mode-Specific Output Generation
```systemverilog
case (mode0_reg)
    3'b000: out0 = (state0 == (counter0_reg - 1'b1)) ? 1'b1 : 1'b0;  // Mode 0
    3'b001: out0 = (state0 == 8'd0) ? 1'b0 : 1'b1;                   // Mode 1
    3'b010: out0 = (state0 < (counter0_reg >> 1)) ? 1'b0 : 1'b1;     // Mode 2
    // ... additional modes
endcase
```

## UVM Verification Architecture

### Transaction Definition
```systemverilog
class timer_transaction extends uvm_sequence_item;
    rand logic [3:0] d;      // 4-bit data input
    rand logic [1:0] a;      // 2-bit address
    rand logic       g0, g1; // Gate controls
    logic            out0, out1; // Timer outputs
    
    // Transaction tracking
    typedef enum {WRITE_LOWER, WRITE_UPPER, CONTROL_WRITE, GATE_CONTROL} trans_type_e;
    trans_type_e trans_type;
    logic [7:0] full_value;
    logic [2:0] target_mode;
endclass
```

### Golden Reference Model
The verification includes a comprehensive golden model that exactly matches the DUT:
- **State Modeling**: Internal counter and mode registers
- **Two-Phase Writes**: Exact nibble-based register updates  
- **Counter Logic**: Precise state tracking and countdown behavior
- **Output Prediction**: Mode-specific duty cycle generation
- **Gate Control**: Proper freeze/enable behavior

## Test Sequences Implemented

### 1. Register Configuration Sequence
```systemverilog
// Configure Counter0 with value 10, mode 1
// Configure Counter1 with value 60, mode 2
class timer_register_config_sequence extends timer_base_sequence;
```

### 2. Gate Control Sequence  
```systemverilog
// Test all gate combinations: both on, g0 off, g1 off, both off
class timer_gate_control_sequence extends timer_base_sequence;
```

### 3. Mode Testing Sequence
```systemverilog
// Test all 5 modes with appropriate count values
class timer_mode_test_sequence extends timer_base_sequence;
```

### 4. Boundary Testing Sequence
```systemverilog
// Test boundary values: 2,3,149,150 for Counter0; 50,51,199,200 for Counter1
class timer_boundary_test_sequence extends timer_base_sequence;
```

### 5. Edge Case Testing Sequence
```systemverilog
// Test invalid modes, out-of-range counts, mode/count mismatches
class timer_edge_case_sequence extends timer_base_sequence;
```

### 6. Random Testing Sequence
```systemverilog
// Constrained random testing across all parameters
class timer_random_sequence extends timer_base_sequence;
```

## Getting Started

### Prerequisites
- SystemVerilog simulator (QuestaSim, VCS, Xcelium)
- UVM library (typically included with simulator)
- Understanding of timer/counter concepts
- Knowledge of UVM methodology

### Environment Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/lamaRimawi/timer-uvm-verification-environment.git
   cd timer-uvm-verification-environment
   ```

2. **Compile and run:**
   ```bash
   # Compile design and testbench
   vlog -sv +incdir+$UVM_HOME/src $UVM_HOME/src/uvm_pkg.sv
   vlog -sv +incdir+. *.sv
   
   # Run specific tests
   vsim -c timer_tb_top +UVM_TESTNAME=timer_basic_test -do "run -all; quit"
   ```

## Usage

### Running Verification Tests

#### Basic Test Execution
```bash
# Run basic functionality test  
vsim -c timer_tb_top +UVM_TESTNAME=timer_basic_test -do "run -all; quit"

# Run comprehensive test suite
vsim -c timer_tb_top +UVM_TESTNAME=timer_comprehensive_test -do "run -all; quit"

# Run random testing
vsim -c timer_tb_top +UVM_TESTNAME=timer_random_test -do "run -all; quit"
```

#### GUI Debug Mode
```bash
# Open simulator GUI for debugging
vsim timer_tb_top +UVM_TESTNAME=timer_basic_test

# Generate waveforms for analysis
vsim timer_tb_top +UVM_TESTNAME=timer_comprehensive_test -wlf timer_waves.wlf
```

## Test Scenarios

### Functional Verification
1. **Register Interface Testing**
   - Two-phase nibble writing mechanism
   - Address decoding verification  
   - Control register mode updates
   - Invalid address handling

2. **Counter Operation Testing**
   - Valid range enforcement (2-150, 50-200)
   - State tracking and countdown behavior
   - Gate control functionality
   - Counter reload on expiration

3. **Mode Verification**
   - All 5 operating modes per counter
   - Mode-specific duty cycle generation
   - Even/odd count validation for restricted modes
   - Invalid mode handling

### Edge Case Testing
1. **Boundary Conditions**
   - Minimum and maximum count values
   - Mode transitions at boundaries
   - Gate edge detection

2. **Error Conditions**
   - Out-of-range count values
   - Invalid mode configurations
   - Mode/count compatibility mismatches

## Key Learning Outcomes

### Technical Skills Developed
- **Timer/Counter Design** - Understanding of programmable timer architectures
- **UVM Expertise** - Advanced verification methodology mastery
- **SystemVerilog Proficiency** - Modern hardware verification language
- **Golden Model Development** - Bit-accurate reference implementation
- **State Machine Verification** - Complex state tracking validation

### Hardware Design Knowledge
- **Register Interface Design** - Multi-phase register access protocols
- **Counter Architecture** - Programmable counting and state machines
- **Gate Control Logic** - Enable/disable control mechanisms
- **Duty Cycle Generation** - Various waveform generation techniques
- **Timing Verification** - Critical timing relationship validation

## Industry Applications

### Professional Relevance
- **Timer IP Verification** - Programmable timer block validation
- **SoC Verification** - System-on-chip timer subsystem testing
- **Real-Time Systems** - Timing-critical system verification  
- **Embedded Controllers** - Microcontroller timer peripheral validation

### Career Applications
- **Verification Engineer** - Hardware verification specialist
- **Timer/Counter Designer** - Specialized timing circuit design
- **SoC Architect** - System-level timer integration
- **Real-Time Systems Engineer** - Timing-critical system development

## Challenges Overcome

1. **Complex State Tracking** - Verifying dual counter state management
2. **Multi-Phase Register Interface** - Validating nibble-based register writes
3. **Mode-Specific Behavior** - Testing 5 distinct operating modes per counter
4. **Golden Model Accuracy** - Creating exact DUT behavioral match
5. **Timing Relationship Verification** - Ensuring proper duty cycle generation

## Future Enhancements

- [ ] **Advanced Timer Features** - PWM generation, capture/compare modes
- [ ] **Interrupt Integration** - Timer overflow and match interrupts
- [ ] **Cascaded Operation** - Multi-timer chaining capabilities
- [ ] **Power Management** - Low-power timer operation modes
- [ ] **Formal Verification** - Property-based timer behavior verification
- [ ] **Performance Analysis** - Timing accuracy and jitter analysis

## Academic Significance

This project demonstrates mastery of:
- **Complex Timer Verification** - Multi-mode programmable timer validation
- **Professional UVM Practices** - Industry-standard verification techniques
- **Register Interface Verification** - Multi-phase access protocol testing
- **State Machine Validation** - Complex counter state verification
- **Golden Model Development** - Precise reference implementation

## Contact

**Lama Rimawi**  
GitHub: [@lamaRimawi](https://github.com/lamaRimawi)  
Repository: [timer-uvm-verification-environment](https://github.com/lamaRimawi/timer-uvm-verification-environment)

This project showcases advanced timer verification capabilities using professional UVM methodology for complex programmable timing controllers.

---

*Project Type: Timer/Counter Verification | Design: Programmable Dual Timer | Methodology: UVM | Language: SystemVerilog | Status: Complete*
