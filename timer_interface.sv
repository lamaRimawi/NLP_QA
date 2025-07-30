`ifndef TIMER_INTERFACE_SV
`define TIMER_INTERFACE_SV
interface timer_interface(input logic clk);
    logic [3:0] d;      // 4-bit data input
    logic [1:0] a;      // 2-bit address input
    logic       g0;     // Gate input for counter0
    logic       g1;     // Gate input for counter1
    logic       out0;   // Divided clock output for counter0
    logic       out1;   // Divided clock output for counter1

    clocking driver_cb @(posedge clk);
        output d, a, g0, g1;
        input out0, out1;
    endclocking
    
    clocking monitor_cb @(posedge clk);
        input d, a, g0, g1, out0, out1;
    endclocking
    
    modport DRIVER (clocking driver_cb);
    modport MONITOR (clocking monitor_cb);
    
endinterface
`endif // TIMER_INTERFACE_SV      