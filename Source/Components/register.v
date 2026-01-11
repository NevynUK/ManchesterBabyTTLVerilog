//
//  Implements a simple register using 74LS373 latches.
//
//  Features:
//  - 32-bit register
//  - Load enable input (active high) to latch data from the input A
//  - Output enable input (active low) to control when the output Q is driven or in a High-Z state.
//
//  Note that we do not have a propagation delay here as the delays are built into the individual components.
//
module register
(
    input wire [31:0] A,        // 32-bit data input.
    input wire LE,              // Latch Enable (active high): loads data on positive edge.
    input wire OE_n,            // Output Enable (active low): outputs Q when low, High-Z when high.
    output wire [31:0] Q        // 32-bit data output.
);
    //
    //  32-bit register using four 74LS373 8-bit latches.
    //
    ttl373_latch latch0 (.D(A[7:0]),   .LE(LE), .OE_n(OE_n), .Q(Q[7:0]));
    ttl373_latch latch1 (.D(A[15:8]),  .LE(LE), .OE_n(OE_n), .Q(Q[15:8]));
    ttl373_latch latch2 (.D(A[23:16]), .LE(LE), .OE_n(OE_n), .Q(Q[23:16]));
    ttl373_latch latch3 (.D(A[31:24]), .LE(LE), .OE_n(OE_n), .Q(Q[31:24]));

endmodule
