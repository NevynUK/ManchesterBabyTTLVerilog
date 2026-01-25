//
//  Implement a simple ALU that can perform addition and subtraction.
//
//  The ALU is 32-bits wide and has the following features:
//  - Two 32-bit inputs: A and B
//  - One 1-bit control input: SUB (0 for addition, 1 for subtraction)
//  - One 1-bit latch enable input: LE (active high, latches result when high)
//  - One 32-bit output: RESULT
//  - One 1-bit control signal that indicates if the RESULT should be output or should be High-Z
//  - The ALU will continuously compute the result based on the current inputs and control signals.
//  - Results are latched into the output registers when LE is high.
//
//  The ALU is implemented using the following logic gates:
//  - 74LS283 for addition
//  - 74LS86 to convert the B input to its two's complement for subtraction using the SUB control signal.
//  - 74LS373 to latch and control the output state (RESULT or High-Z) based on the latch enable and output enable signals.
//
//  Note that we do not have a propagation delay here as the delays are built into the individual components.
//
module alu
(
    input wire [31:0] A,        // 32-bit input A.
    input wire [31:0] B,        // 32-bit input B.
    input wire SUB,             // Subtract control: 0 = add, 1 = subtract.
    input wire LE,              // Latch Enable (active high): latches the computed result when high.
    input wire OE_n,            // Output enable (active low): outputs RESULT when low, High-Z when high.
    output wire [31:0] RESULT   // 32-bit result output.
);
    //
    //  Internal signals.
    //
    wire [31:0] B_XORed;        // B input after XOR with SUB (inverted for subtraction).
    wire [31:0] adder_result;   // Result from the adder chain.
    wire [7:0] carry;           // Carry signals between 4-bit adders.

    //
    //  XOR B with SUB control using 74LS86 (eight quad XOR gates for 32 bits).
    //      - When SUB=0, B passes through unchanged (B XOR 0 = B).
    //      - When SUB=1, B is inverted (B XOR 1 = ~B) for two's complement.
    //
    ttl86_xor xor_B0 (.A1(B[0]),  .B1(SUB), .Y1(B_XORed[0]),
                      .A2(B[1]),  .B2(SUB), .Y2(B_XORed[1]),
                      .A3(B[2]),  .B3(SUB), .Y3(B_XORed[2]),
                      .A4(B[3]),  .B4(SUB), .Y4(B_XORed[3]));

    ttl86_xor xor_B1 (.A1(B[4]),  .B1(SUB), .Y1(B_XORed[4]),
                      .A2(B[5]),  .B2(SUB), .Y2(B_XORed[5]),
                      .A3(B[6]),  .B3(SUB), .Y3(B_XORed[6]),
                      .A4(B[7]),  .B4(SUB), .Y4(B_XORed[7]));

    ttl86_xor xor_B2 (.A1(B[8]),  .B1(SUB), .Y1(B_XORed[8]),
                      .A2(B[9]),  .B2(SUB), .Y2(B_XORed[9]),
                      .A3(B[10]), .B3(SUB), .Y3(B_XORed[10]),
                      .A4(B[11]), .B4(SUB), .Y4(B_XORed[11]));

    ttl86_xor xor_B3 (.A1(B[12]), .B1(SUB), .Y1(B_XORed[12]),
                      .A2(B[13]), .B2(SUB), .Y2(B_XORed[13]),
                      .A3(B[14]), .B3(SUB), .Y3(B_XORed[14]),
                      .A4(B[15]), .B4(SUB), .Y4(B_XORed[15]));

    ttl86_xor xor_B4 (.A1(B[16]), .B1(SUB), .Y1(B_XORed[16]),
                      .A2(B[17]), .B2(SUB), .Y2(B_XORed[17]),
                      .A3(B[18]), .B3(SUB), .Y3(B_XORed[18]),
                      .A4(B[19]), .B4(SUB), .Y4(B_XORed[19]));

    ttl86_xor xor_B5 (.A1(B[20]), .B1(SUB), .Y1(B_XORed[20]),
                      .A2(B[21]), .B2(SUB), .Y2(B_XORed[21]),
                      .A3(B[22]), .B3(SUB), .Y3(B_XORed[22]),
                      .A4(B[23]), .B4(SUB), .Y4(B_XORed[23]));

    ttl86_xor xor_B6 (.A1(B[24]), .B1(SUB), .Y1(B_XORed[24]),
                      .A2(B[25]), .B2(SUB), .Y2(B_XORed[25]),
                      .A3(B[26]), .B3(SUB), .Y3(B_XORed[26]),
                      .A4(B[27]), .B4(SUB), .Y4(B_XORed[27]));

    ttl86_xor xor_B7 (.A1(B[28]), .B1(SUB), .Y1(B_XORed[28]),
                      .A2(B[29]), .B2(SUB), .Y2(B_XORed[29]),
                      .A3(B[30]), .B3(SUB), .Y3(B_XORed[30]),
                      .A4(B[31]), .B4(SUB), .Y4(B_XORed[31]));

    //
    //  32-bit addition using eight 74LS283 4-bit adders with ripple carry.
    //      - For subtraction: A + (~B) + 1 = A - B (two's complement).
    //      - The SUB signal becomes the carry-in for the first adder to add the +1.
    //
    ttl283_adder adder0 (.A(A[3:0]),   .B(B_XORed[3:0]),   .C0(SUB),      .S(adder_result[3:0]),   .C4(carry[0]));
    ttl283_adder adder1 (.A(A[7:4]),   .B(B_XORed[7:4]),   .C0(carry[0]), .S(adder_result[7:4]),   .C4(carry[1]));
    ttl283_adder adder2 (.A(A[11:8]),  .B(B_XORed[11:8]),  .C0(carry[1]), .S(adder_result[11:8]),  .C4(carry[2]));
    ttl283_adder adder3 (.A(A[15:12]), .B(B_XORed[15:12]), .C0(carry[2]), .S(adder_result[15:12]), .C4(carry[3]));
    ttl283_adder adder4 (.A(A[19:16]), .B(B_XORed[19:16]), .C0(carry[3]), .S(adder_result[19:16]), .C4(carry[4]));
    ttl283_adder adder5 (.A(A[23:20]), .B(B_XORed[23:20]), .C0(carry[4]), .S(adder_result[23:20]), .C4(carry[5]));
    ttl283_adder adder6 (.A(A[27:24]), .B(B_XORed[27:24]), .C0(carry[5]), .S(adder_result[27:24]), .C4(carry[6]));
    ttl283_adder adder7 (.A(A[31:28]), .B(B_XORed[31:28]), .C0(carry[6]), .S(adder_result[31:28]), .C4(carry[7]));

    //
    //  Output control using 74LS373 (four 8-bit latches for 32-bit output).
    //      - D inputs are connected to the adder result.
    //      - LE (Latch Enable) input controls when the result is latched (transparent when high).
    //      - OE_n controls tri-state: low = output enabled, high = High-Z.
    //
    ttl373_latch output_buf0 (.D(adder_result[7:0]),   .LE(LE), .OE_n(OE_n), .Q(RESULT[7:0]));
    ttl373_latch output_buf1 (.D(adder_result[15:8]),  .LE(LE), .OE_n(OE_n), .Q(RESULT[15:8]));
    ttl373_latch output_buf2 (.D(adder_result[23:16]), .LE(LE), .OE_n(OE_n), .Q(RESULT[23:16]));
    ttl373_latch output_buf3 (.D(adder_result[31:24]), .LE(LE), .OE_n(OE_n), .Q(RESULT[31:24]));

endmodule
