//
//  Implementation of a program counter (PC) register for the Manchester Baby TTL Verilog project.
//
//  Features:
//  - 32-bit register
//  - Load enable input (active low) to latch data from the input A
//  - Output enable input (active low) to control when the output Q is driven or in a High-Z state.
//  - Clock signal to trigger the count increment on the rising edge.
//  - Counter will count up only, there is no requirement to count down.
//
//  Implementation:
//  - Use 74LS191 to implement the internal 32-bit counter functionality.
//  - Use 74LS245 to control the output state (Q or High-Z) based on the output enable signal.
//
module pc
(
    input wire [31:0] A,        // 32-bit data input for loading.
    input wire CLK,             // Clock input (active rising edge).
    input wire LOAD_n,          // Load input (active low): loads A when low.
    input wire OE_n,            // Output Enable (active low): outputs Q when low, High-Z when high.
    output wire [31:0] Q        // 32-bit counter output.
);
    //
    //  Internal signals.
    //
    wire [31:0] counter_out;    // Output from the counter chain.
    wire [7:0] ripple_carry;    // Ripple carry outputs between counters.

    //
    //  32-bit up counter using eight 74LS191 4-bit counters with ripple carry.
    //      - CTEN_n tied low to always enable counting.
    //      - DOWN_UP_n tied low for count up mode.
    //      - RCO_n (ripple carry out) of each counter connects to CTEN_n of the next counter.
    //
    ttl191_counter counter0(.D(A[3:0]), .CLK(CLK), .LOAD_n(LOAD_n), .CTEN_n(1'b0),
                            .DOWN_UP_n(1'b0), .Q(counter_out[3:0]), .RCO_n(ripple_carry[0]));
    ttl191_counter counter1(.D(A[7:4]), .CLK(CLK), .LOAD_n(LOAD_n), .CTEN_n(ripple_carry[0]),
                            .DOWN_UP_n(1'b0), .Q(counter_out[7:4]), .RCO_n(ripple_carry[1]));
    ttl191_counter counter2(.D(A[11:8]), .CLK(CLK), .LOAD_n(LOAD_n), .CTEN_n(ripple_carry[1]),
                            .DOWN_UP_n(1'b0), .Q(counter_out[11:8]), .RCO_n(ripple_carry[2]));
    ttl191_counter counter3(.D(A[15:12]), .CLK(CLK), .LOAD_n(LOAD_n), .CTEN_n(ripple_carry[2]),
                            .DOWN_UP_n(1'b0), .Q(counter_out[15:12]), .RCO_n(ripple_carry[3]));
    ttl191_counter counter4(.D(A[19:16]), .CLK(CLK), .LOAD_n(LOAD_n), .CTEN_n(ripple_carry[3]),
                            .DOWN_UP_n(1'b0), .Q(counter_out[19:16]), .RCO_n(ripple_carry[4]));
    ttl191_counter counter5(.D(A[23:20]), .CLK(CLK), .LOAD_n(LOAD_n), .CTEN_n(ripple_carry[4]),
                            .DOWN_UP_n(1'b0), .Q(counter_out[23:20]), .RCO_n(ripple_carry[5]));
    ttl191_counter counter6(.D(A[27:24]), .CLK(CLK), .LOAD_n(LOAD_n), .CTEN_n(ripple_carry[5]),
                            .DOWN_UP_n(1'b0), .Q(counter_out[27:24]), .RCO_n(ripple_carry[6]));
    ttl191_counter counter7(.D(A[31:28]), .CLK(CLK), .LOAD_n(LOAD_n), .CTEN_n(ripple_carry[6]),
                            .DOWN_UP_n(1'b0), .Q(counter_out[31:28]), .RCO_n(ripple_carry[7]));

    //
    //  Output control using 74LS245 (four 8-bit transceivers for 32-bit output).
    //      - DIR = 1 for A to B direction (counter_out to Q).
    //      - OE_n controls tri-state: low = output enabled, high = High-Z.
    //
    wire [31:0] ttl245_porta;    // Unused A port of the 74LS245.
    
    ttl245_transceiver output_buf0 (.A(ttl245_porta[7:0]),   .B(Q[7:0]),   .DIR(1'b1), .OE_n(OE_n));
    ttl245_transceiver output_buf1 (.A(ttl245_porta[15:8]),  .B(Q[15:8]),  .DIR(1'b1), .OE_n(OE_n));
    ttl245_transceiver output_buf2 (.A(ttl245_porta[23:16]), .B(Q[23:16]), .DIR(1'b1), .OE_n(OE_n));
    ttl245_transceiver output_buf3 (.A(ttl245_porta[31:24]), .B(Q[31:24]), .DIR(1'b1), .OE_n(OE_n));

    //
    //  Drive the A ports of the 74LS245 with the counter output.
    //
    assign ttl245_porta[7:0]   = counter_out[7:0];
    assign ttl245_porta[15:8]  = counter_out[15:8];
    assign ttl245_porta[23:16] = counter_out[23:16];
    assign ttl245_porta[31:24] = counter_out[31:24];

endmodule