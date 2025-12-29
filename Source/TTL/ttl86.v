//
//  74LS86 - Quad 2-input XOR gate.
//
module ttl86_xor 
#(PROPAGATION_DELAY = 15, RISE_TIME = 1, FALL_TIME = 1)
(
    input wire A1,          // Gate 1 input A.
    input wire B1,          // Gate 1 input B.
    output wire Y1,         // Gate 1 output.
    
    input wire A2,          // Gate 2 input A.
    input wire B2,          // Gate 2 input B.
    output wire Y2,         // Gate 2 output.
    
    input wire A3,          // Gate 3 input A.
    input wire B3,          // Gate 3 input B.
    output wire Y3,         // Gate 3 output.
    
    input wire A4,          // Gate 4 input A.
    input wire B4,          // Gate 4 input B.
    output wire Y4          // Gate 4 output.
);
    //
    // XOR function: Y = A XOR B
    // Output is HIGH when inputs are different, LOW when inputs are same.
    //
    assign #PROPAGATION_DELAY Y1 = A1 ^ B1;
    assign #PROPAGATION_DELAY Y2 = A2 ^ B2;
    assign #PROPAGATION_DELAY Y3 = A3 ^ B3;
    assign #PROPAGATION_DELAY Y4 = A4 ^ B4;

endmodule
