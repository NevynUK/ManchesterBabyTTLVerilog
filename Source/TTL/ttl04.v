//
//  7404 - Hex inverter.
//
module ttl04_inverter
#(PROPAGATION_DELAY = 12, RISE_TIME = 1, FALL_TIME = 1)
(
    input wire A1,          // Gate 1 input.
    output wire Y1,         // Gate 1 output.

    input wire A2,          // Gate 2 input.
    output wire Y2,         // Gate 2 output.

    input wire A3,          // Gate 3 input.
    output wire Y3,         // Gate 3 output.

    input wire A4,          // Gate 4 input.
    output wire Y4,         // Gate 4 output.

    input wire A5,          // Gate 5 input.
    output wire Y5,         // Gate 5 output.

    input wire A6,          // Gate 6 input.
    output wire Y6          // Gate 6 output.
);
    //
    //  NOT function: Y = ~A
    //  Output is the inverse of the input.
    //
    assign #PROPAGATION_DELAY Y1 = ~A1;
    assign #PROPAGATION_DELAY Y2 = ~A2;
    assign #PROPAGATION_DELAY Y3 = ~A3;
    assign #PROPAGATION_DELAY Y4 = ~A4;
    assign #PROPAGATION_DELAY Y5 = ~A5;
    assign #PROPAGATION_DELAY Y6 = ~A6;

endmodule
