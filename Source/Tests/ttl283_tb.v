//
//  Test the implementation of the 74LS83 4-bit binary full adder.
//
`timescale 1 ns / 10 ps

module ttl283_tb();
    reg [3:0] A;            // 4-bit input A.
    reg [3:0] B;            // 4-bit input B.
    reg C0;                 // Carry input.
    wire [3:0] S;           // 4-bit sum output.
    wire C4;                // Carry output.
    
    reg [4:0] expected;     // Expected result (5-bit: carry + sum).

    //
    // Instantiate the ttl83_adder module using the default propagation delay.
    //
    ttl283_adder uut (
        .A(A),
        .B(B),
        .C0(C0),
        .S(S),
        .C4(C4)
    );

    localparam PROPAGATION_DELAY = 50;     // Delay to allow for propagation with some overhead.

    initial begin
        $dumpvars(0, ttl283_tb);
    end

    initial begin
        //
        //  Setup the initial conditions.
        //
        A = 4'b0000;
        B = 4'b0000;
        C0 = 1'b0;
        #PROPAGATION_DELAY;

        //
        // Test 1: Simple addition without carry (0 + 0 + 0 = 0).
        //
        A = 4'b0000;
        B = 4'b0000;
        C0 = 1'b0;
        expected = 5'b00000;
        #PROPAGATION_DELAY;
        if ({C4, S} !== expected)
        begin
            $error("ERROR: Test 1 failed. A=%b, B=%b, C0=%b, Expected=%b, Got=%b%b", A, B, C0, expected, C4, S);
        end

        //
        // Test 2: Addition with no carry out (5 + 3 + 0 = 8).
        //
        A = 4'b0101;
        B = 4'b0011;
        C0 = 1'b0;
        expected = 5'b01000;
        #PROPAGATION_DELAY;
        if ({C4, S} !== expected)
        begin
            $error("ERROR: Test 2 failed. A=%b, B=%b, C0=%b, Expected=%b, Got=%b%b", A, B, C0, expected, C4, S);
        end

        //
        // Test 3: Addition with carry in (7 + 6 + 1 = 14).
        //
        A = 4'b0111;
        B = 4'b0110;
        C0 = 1'b1;
        expected = 5'b01110;
        #PROPAGATION_DELAY;
        if ({C4, S} !== expected)
        begin
            $error("ERROR: Test 3 failed. A=%b, B=%b, C0=%b, Expected=%b, Got=%b%b", A, B, C0, expected, C4, S);
        end

        //
        // Test 4: Addition with carry out (8 + 8 + 0 = 16, result = 0 with C4=1).
        //
        A = 4'b1000;
        B = 4'b1000;
        C0 = 1'b0;
        expected = 5'b10000;
        #PROPAGATION_DELAY;
        if ({C4, S} !== expected)
        begin
            $error("ERROR: Test 4 failed. A=%b, B=%b, C0=%b, Expected=%b, Got=%b%b", A, B, C0, expected, C4, S);
        end

        //
        // Test 5: Maximum values (15 + 15 + 0 = 30, result = 14 with C4=1).
        //
        A = 4'b1111;
        B = 4'b1111;
        C0 = 1'b0;
        expected = 5'b11110;
        #PROPAGATION_DELAY;
        if ({C4, S} !== expected)
        begin
            $error("ERROR: Test 5 failed. A=%b, B=%b, C0=%b, Expected=%b, Got=%b%b", A, B, C0, expected, C4, S);
        end

        //
        // Test 6: Maximum values with carry in (15 + 15 + 1 = 31, result = 15 with C4=1).
        //
        A = 4'b1111;
        B = 4'b1111;
        C0 = 1'b1;
        expected = 5'b11111;
        #PROPAGATION_DELAY;
        if ({C4, S} !== expected)
        begin
            $error("ERROR: Test 6 failed. A=%b, B=%b, C0=%b, Expected=%b, Got=%b%b", A, B, C0, expected, C4, S);
        end

        //
        // Test 7: Random test case 1 (9 + 4 + 0 = 13).
        //
        A = 4'b1001;
        B = 4'b0100;
        C0 = 1'b0;
        expected = 5'b01101;
        #PROPAGATION_DELAY;
        if ({C4, S} !== expected)
        begin
            $error("ERROR: Test 7 failed. A=%b, B=%b, C0=%b, Expected=%b, Got=%b%b", A, B, C0, expected, C4, S);
        end

        //
        // Test 8: Random test case 2 (12 + 7 + 1 = 20, result = 4 with C4=1).
        //
        A = 4'b1100;
        B = 4'b0111;
        C0 = 1'b1;
        expected = 5'b10100;
        #PROPAGATION_DELAY;
        if ({C4, S} !== expected)
        begin
            $error("ERROR: Test 8 failed. A=%b, B=%b, C0=%b, Expected=%b, Got=%b%b", A, B, C0, expected, C4, S);
        end

        //
        // Test 9: Carry in only (0 + 0 + 1 = 1).
        //
        A = 4'b0000;
        B = 4'b0000;
        C0 = 1'b1;
        expected = 5'b00001;
        #PROPAGATION_DELAY;
        if ({C4, S} !== expected)
        begin
            $error("ERROR: Test 9 failed. A=%b, B=%b, C0=%b, Expected=%b, Got=%b%b", A, B, C0, expected, C4, S);
        end

        //
        // Test 10: All ones in A (15 + 0 + 0 = 15).
        //
        A = 4'b1111;
        B = 4'b0000;
        C0 = 1'b0;
        expected = 5'b01111;
        #PROPAGATION_DELAY;
        if ({C4, S} !== expected)
        begin
            $error("ERROR: Test 10 failed. A=%b, B=%b, C0=%b, Expected=%b, Got=%b%b", A, B, C0, expected, C4, S);
        end

        //
        // Test 11: All ones in B (0 + 15 + 0 = 15).
        //
        A = 4'b0000;
        B = 4'b1111;
        C0 = 1'b0;
        expected = 5'b01111;
        #PROPAGATION_DELAY;
        if ({C4, S} !== expected)
        begin
            $error("ERROR: Test 11 failed. A=%b, B=%b, C0=%b, Expected=%b, Got=%b%b", A, B, C0, expected, C4, S);
        end

        //
        // Test 12: Pattern test (10 + 5 + 1 = 16, result = 0 with C4=1).
        //
        A = 4'b1010;
        B = 4'b0101;
        C0 = 1'b1;
        expected = 5'b10000;
        #PROPAGATION_DELAY;
        if ({C4, S} !== expected)
        begin
            $error("ERROR: Test 12 failed. A=%b, B=%b, C0=%b, Expected=%b, Got=%b%b", A, B, C0, expected, C4, S);
        end

        #(PROPAGATION_DELAY * 2);
        $display("74LS283 - End of Simulation.");
        $finish;
    end

endmodule
