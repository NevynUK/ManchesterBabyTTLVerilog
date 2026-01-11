//
//  74LS373 - Octal D-type transparent latch with 3-state outputs.
//
module ttl373_latch
#(PROPAGATION_DELAY = 36, RISE_TIME = 1, FALL_TIME = 1)
(
    input wire [7:0] D,     // 8-bit Data Input.
    input wire LE,          // Latch Enable (active high, transparent when high).
    input wire OE_n,        // Output Enable (active low, 3-state when high).
    output reg [7:0] Q      // 8-bit Data Output.
);
    //
    // Internal register to hold the latched data.
    //
    reg [7:0] internal_latch;

    //
    //  OC (OE_n)  C (LE)   D   Q
    //      L        H      H   H
    //      L        H      L   L
    //      L        L      X   Q0
    //      H        X      X   Z
    //
    always @(D or LE)
    begin
        if (LE == 1'b1)
        begin
            //
            //  Transparent mode: internal latch follows input D.
            //
            internal_latch <= D;
        end
        //
        //  When LE is low, internal_latch keeps its current value.
        //
    end
    //
    //  Tri-state output buffer control.
    //
    always @(internal_latch or OE_n)
    begin
        if (OE_n == 1'b0)
        begin
            //
            //  Output enabled: drive Q with the latched value.
            //
            #PROPAGATION_DELAY Q <= internal_latch;
        end else
        begin
            //
            //  Output disabled: high-impedance state ('z').
            //
            #(PROPAGATION_DELAY) Q <= 8'bz;
        end
    end

endmodule