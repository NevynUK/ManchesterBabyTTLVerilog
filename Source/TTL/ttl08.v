//
//  74LS08 - Quad 2-input AND gate.
//
module ttl08_and
#(PROPAGATION_DELAY = 18, RISE_TIME = 1, FALL_TIME = 1)
(
    input wire A1,          //  Gate 1 input A.
    input wire B1,          //  Gate 1 input B.
    output wire Y1,         //  Gate 1 output.

    input wire A2,          //  Gate 2 input A.
    input wire B2,          //  Gate 2 input B.
    output wire Y2,         //  Gate 2 output.

    input wire A3,          //  Gate 3 input A.
    input wire B3,          //  Gate 3 input B.
    output wire Y3,         //  Gate 3 output.

    input wire A4,          //  Gate 4 input A.
    input wire B4,          //  Gate 4 input B.
    output wire Y4          //  Gate 4 output.
);
    //
    //  AND function: Y = A & B
    //  Output is HIGH only when both inputs are HIGH.
    //
    assign #PROPAGATION_DELAY Y1 = A1 & B1;
    assign #PROPAGATION_DELAY Y2 = A2 & B2;
    assign #PROPAGATION_DELAY Y3 = A3 & B3;
    assign #PROPAGATION_DELAY Y4 = A4 & B4;

endmodule
