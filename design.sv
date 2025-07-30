module timer(
    input  [3:0] d,       
    input  [1:0] a,       
    input        clk,       
    input        g0,       
    input        g1,     
    output reg   out0,     
    output reg   out1       
);

    // Internal registers (8-bit wide)
    reg [7:0] counter0_reg = 8'd0; 
    reg [7:0] counter1_reg = 8'd0;
    reg [7:0] control_reg = 8'd0;  
    reg [2:0] mode0_reg = 3'd0;    
    reg [2:0] mode1_reg = 3'd0;   
    
    // Internal variables to hold counter values and states
    reg [7:0] count0 = 8'd0;  
    reg [7:0] count1 = 8'd0;   
    reg [7:0] state0 = 8'd0;   
    reg [7:0] state1 = 8'd0;   
    
    // Variables for two-step write process
    reg [3:0] temp_low = 4'd0; 
    reg [1:0] last_addr = 2'd0; 
    reg write_phase = 1'b0;
    
    // Previous gate states for edge detection
    reg g0_prev = 1'b0;
    reg g1_prev = 1'b0;

    // Two-step write process (nibble by nibble)
    always @(posedge clk) begin
        if (!write_phase) begin  // First write: store low nibble
            temp_low <= d;
            last_addr <= a;
            write_phase <= 1'b1;
        end else begin           // Second write: store high nibble and update register
            if (a == last_addr) begin  // Only update if the same address is being written
                case (a)
                    2'b00: counter0_reg <= {d, temp_low};  // Address 0: Update counter0
                    2'b01: counter1_reg <= {d, temp_low};  // Address 1: Update counter1
                    2'b10: begin                          // Address 2: Update control register
                        control_reg <= {d, temp_low};
                        // Update mode based on control register bits (c)
                        if (temp_low[3]) // If c=1, update counter1's mode
                            mode1_reg <= temp_low[2:0];
                        else             // If c=0, update counter0's mode
                            mode0_reg <= temp_low[2:0];
                    end
                    2'b11: begin
                        // Address 3: Reserved/Unused - Do nothing
                    end
                endcase
            end
            write_phase <= 1'b0;  // Reset write phase for next low nibble
        end
    end

    // Counter 0 Logic (Valid range: 2 to 150)
    always @(posedge clk) begin
        g0_prev <= g0;
        
        if (g0 && counter0_reg >= 8'd2 && counter0_reg <= 8'd150) begin
            // Initialize counter on rising edge of gate or when count reaches 0
            if ((!g0_prev && g0) || (count0 == 8'd0)) begin
                count0 <= counter0_reg - 1'b1;
                state0 <= 8'd0;
            end else begin
                if (count0 > 8'd0) begin
                    count0 <= count0 - 1'b1;
                    // Handle state wraparound properly
                    if (state0 >= (counter0_reg - 1'b1)) begin
                        state0 <= 8'd0;
                    end else begin
                        state0 <= state0 + 1'b1;
                    end
                end
            end
        end else if (!g0) begin
            // Keep current counter and state when gate is low (freeze operation)
            count0 <= count0;  
            state0 <= state0;
        end else begin
            // Invalid range - reset counters
            count0 <= 8'd0;
            state0 <= 8'd0;
        end
    end
    
    // Counter 1 Logic (Valid range: 50 to 200)
    always @(posedge clk) begin
        g1_prev <= g1;
        
        if (g1 && counter1_reg >= 8'd50 && counter1_reg <= 8'd200) begin
            // Initialize counter on rising edge of gate or when count reaches 0
            if ((!g1_prev && g1) || (count1 == 8'd0)) begin
                count1 <= counter1_reg - 1'b1;
                state1 <= 8'd0;
            end else begin
                if (count1 > 8'd0) begin
                    count1 <= count1 - 1'b1;
                    // Handle state wraparound properly for counter1
                    if (state1 >= (counter1_reg - 1'b1)) begin
                        state1 <= 8'd0;
                    end else begin
                        state1 <= state1 + 1'b1;
                    end
                end
            end
        end else if (!g1) begin
            // Keep current counter and state when gate is low (freeze operation)
            count1 <= count1;  
            state1 <= state1;
        end else begin
            // Invalid range - reset counters
            count1 <= 8'd0;
            state1 <= 8'd0;
        end
    end
    
    // Output Logic for Counter 0 (Based on mode0_reg)
    always @(*) begin
        if (!g0 || counter0_reg < 8'd2 || counter0_reg > 8'd150) begin
            out0 = 1'b0;  // Output low when gate is off or invalid range
        end else begin
            case (mode0_reg)
                3'b000: begin // Mode 0: 1/n duty cycle (n-1 low, 1 high)
                    out0 = (state0 == (counter0_reg - 1'b1)) ? 1'b1 : 1'b0;
                end
                3'b001: begin // Mode 1: (n-1)/n duty cycle (1 low, n-1 high)
                    out0 = (state0 == 8'd0) ? 1'b0 : 1'b1;
                end
                3'b010: begin // Mode 2: 1/2 duty cycle (n/2 low, n/2 high) - even n only
                    if (counter0_reg[0] == 1'b0) begin  // Even number check
                        out0 = (state0 < (counter0_reg >> 1)) ? 1'b0 : 1'b1;
                    end else begin
                        out0 = 1'b0;  // Invalid for odd numbers
                    end
                end
                3'b011: begin // Mode 3: (n+1)/2 low, (n-1)/2 high - odd n only
                    if (counter0_reg[0] == 1'b1) begin  // Odd number check
                        out0 = (state0 < ((counter0_reg + 1'b1) >> 1)) ? 1'b0 : 1'b1;
                    end else begin
                        out0 = 1'b0;  // Invalid for even numbers
                    end
                end
                3'b100: begin // Mode 4: (n-1)/2 low, (n+1)/2 high - odd n only
                    if (counter0_reg[0] == 1'b1) begin  // Odd number check
                        out0 = (state0 < ((counter0_reg - 1'b1) >> 1)) ? 1'b0 : 1'b1;
                    end else begin
                        out0 = 1'b0;  // Invalid for even numbers
                    end
                end
                default: out0 = 1'b0;  // Invalid mode
            endcase
        end
    end
    
    // Output Logic for Counter 1 (Based on mode1_reg)
    always @(*) begin
        if (!g1 || counter1_reg < 8'd50 || counter1_reg > 8'd200) begin
            out1 = 1'b0;  // Output low when gate is off or invalid range
        end else begin
            case (mode1_reg)
                3'b000: begin // Mode 0: 1/n duty cycle (n-1 low, 1 high)
                    out1 = (state1 == (counter1_reg - 1'b1)) ? 1'b1 : 1'b0;
                end
                3'b001: begin // Mode 1: (n-1)/n duty cycle (1 low, n-1 high)
                    out1 = (state1 == 8'd0) ? 1'b0 : 1'b1;
                end
                3'b010: begin // Mode 2: 1/2 duty cycle (n/2 low, n/2 high) - even n only
                    if (counter1_reg[0] == 1'b0) begin  // Even number check
                        out1 = (state1 < (counter1_reg >> 1)) ? 1'b0 : 1'b1;
                    end else begin
                        out1 = 1'b0;  // Invalid for odd numbers
                    end
                end
                3'b011: begin // Mode 3: (n+1)/2 low, (n-1)/2 high - odd n only
                    if (counter1_reg[0] == 1'b1) begin  // Odd number check
                        out1 = (state1 < ((counter1_reg + 1'b1) >> 1)) ? 1'b0 : 1'b1;
                    end else begin
                        out1 = 1'b0;  // Invalid for even numbers
                    end
                end
                3'b100: begin // Mode 4: (n-1)/2 low, (n+1)/2 high - odd n only
                    if (counter1_reg[0] == 1'b1) begin  // Odd number check
                        out1 = (state1 < ((counter1_reg - 1'b1) >> 1)) ? 1'b0 : 1'b1;
                    end else begin
                        out1 = 1'b0;  // Invalid for even numbers
                    end
                end
                default: out1 = 1'b0;  // Invalid mode
            endcase
        end
    end

endmodule
