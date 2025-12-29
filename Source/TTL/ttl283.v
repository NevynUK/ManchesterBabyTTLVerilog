//
//  74LS283 - 4-bit binary full adder with fast carry.
//
module ttl283_adder 
#(PROPAGATION_DELAY = 24, RISE_TIME = 1, FALL_TIME = 1)
(
    input wire [3:0] A,     // 4-bit input A.
    input wire [3:0] B,     // 4-bit input B.
    input wire C0,          // Carry input.
    output wire [3:0] S,    // 4-bit sum output.
    output wire C4          // Carry output.
);
    //
    //  Internal 5-bit sum to capture carry out.
    //
    wire [4:0] sum;

    //
    // Perform the 4-bit addition with carry in.
    // The sum is computed as A + B + C0, resulting in a 5-bit value.
    // S[3:0] = sum bits, C4 = carry out
    //
    assign #PROPAGATION_DELAY sum = A + B + C0;
    assign S = sum[3:0];
    assign C4 = sum[4];

endmodule
