//
//  Test the implementation of the 74LS86 quad 2-input XOR gate.
//
`timescale 1 ns / 10 ps

module ttl86_tb();
    reg A1, B1, A2, B2, A3, B3, A4, B4;
    wire Y1, Y2, Y3, Y4;

    //
    // Instantiate the ttl86_xor module using the default propagation delay.
    //
    ttl86_xor uut (
        .A1(A1), .B1(B1), .Y1(Y1),
        .A2(A2), .B2(B2), .Y2(Y2),
        .A3(A3), .B3(B3), .Y3(Y3),
        .A4(A4), .B4(B4), .Y4(Y4)
    );

    localparam PROPAGATION_DELAY = 50;     // Delay to allow for propagation with some overhead.

    initial begin
        $dumpvars(0, ttl86_tb);
    end

    initial begin
        //
        //  Setup the initial conditions.
        //
        A1 = 1'b0; B1 = 1'b0;
        A2 = 1'b0; B2 = 1'b0;
        A3 = 1'b0; B3 = 1'b0;
        A4 = 1'b0; B4 = 1'b0;
        #PROPAGATION_DELAY;

        //
        // Test Gate 1: All input combinations.
        //
        A1 = 1'b0; B1 = 1'b0;
        #PROPAGATION_DELAY;
        if (Y1 !== 1'b0) begin
            $error("ERROR: Gate 1 - Test 0^0 failed. Expected Y1=0, got Y1=%b", Y1);
        end

        A1 = 1'b0; B1 = 1'b1;
        #PROPAGATION_DELAY;
        if (Y1 !== 1'b1) begin
            $error("ERROR: Gate 1 - Test 0^1 failed. Expected Y1=1, got Y1=%b", Y1);
        end

        A1 = 1'b1; B1 = 1'b0;
        #PROPAGATION_DELAY;
        if (Y1 !== 1'b1) begin
            $error("ERROR: Gate 1 - Test 1^0 failed. Expected Y1=1, got Y1=%b", Y1);
        end

        A1 = 1'b1; B1 = 1'b1;
        #PROPAGATION_DELAY;
        if (Y1 !== 1'b0) begin
            $error("ERROR: Gate 1 - Test 1^1 failed. Expected Y1=0, got Y1=%b", Y1);
        end

        //
        // Test Gate 2: All input combinations.
        //
        A2 = 1'b0; B2 = 1'b0;
        #PROPAGATION_DELAY;
        if (Y2 !== 1'b0) begin
            $error("ERROR: Gate 2 - Test 0^0 failed. Expected Y2=0, got Y2=%b", Y2);
        end

        A2 = 1'b0; B2 = 1'b1;
        #PROPAGATION_DELAY;
        if (Y2 !== 1'b1) begin
            $error("ERROR: Gate 2 - Test 0^1 failed. Expected Y2=1, got Y2=%b", Y2);
        end

        A2 = 1'b1; B2 = 1'b0;
        #PROPAGATION_DELAY;
        if (Y2 !== 1'b1) begin
            $error("ERROR: Gate 2 - Test 1^0 failed. Expected Y2=1, got Y2=%b", Y2);
        end

        A2 = 1'b1; B2 = 1'b1;
        #PROPAGATION_DELAY;
        if (Y2 !== 1'b0) begin
            $error("ERROR: Gate 2 - Test 1^1 failed. Expected Y2=0, got Y2=%b", Y2);
        end

        //
        // Test Gate 3: All input combinations.
        //
        A3 = 1'b0; B3 = 1'b0;
        #PROPAGATION_DELAY;
        if (Y3 !== 1'b0) begin
            $error("ERROR: Gate 3 - Test 0^0 failed. Expected Y3=0, got Y3=%b", Y3);
        end

        A3 = 1'b0; B3 = 1'b1;
        #PROPAGATION_DELAY;
        if (Y3 !== 1'b1) begin
            $error("ERROR: Gate 3 - Test 0^1 failed. Expected Y3=1, got Y3=%b", Y3);
        end

        A3 = 1'b1; B3 = 1'b0;
        #PROPAGATION_DELAY;
        if (Y3 !== 1'b1) begin
            $error("ERROR: Gate 3 - Test 1^0 failed. Expected Y3=1, got Y3=%b", Y3);
        end

        A3 = 1'b1; B3 = 1'b1;
        #PROPAGATION_DELAY;
        if (Y3 !== 1'b0) begin
            $error("ERROR: Gate 3 - Test 1^1 failed. Expected Y3=0, got Y3=%b", Y3);
        end

        //
        // Test Gate 4: All input combinations.
        //
        A4 = 1'b0; B4 = 1'b0;
        #PROPAGATION_DELAY;
        if (Y4 !== 1'b0) begin
            $error("ERROR: Gate 4 - Test 0^0 failed. Expected Y4=0, got Y4=%b", Y4);
        end

        A4 = 1'b0; B4 = 1'b1;
        #PROPAGATION_DELAY;
        if (Y4 !== 1'b1) begin
            $error("ERROR: Gate 4 - Test 0^1 failed. Expected Y4=1, got Y4=%b", Y4);
        end

        A4 = 1'b1; B4 = 1'b0;
        #PROPAGATION_DELAY;
        if (Y4 !== 1'b1) begin
            $error("ERROR: Gate 4 - Test 1^0 failed. Expected Y4=1, got Y4=%b", Y4);
        end

        A4 = 1'b1; B4 = 1'b1;
        #PROPAGATION_DELAY;
        if (Y4 !== 1'b0) begin
            $error("ERROR: Gate 4 - Test 1^1 failed. Expected Y4=0, got Y4=%b", Y4);
        end

        //
        // Test all gates simultaneously with different patterns.
        //
        A1 = 1'b1; B1 = 1'b0;
        A2 = 1'b0; B2 = 1'b1;
        A3 = 1'b1; B3 = 1'b1;
        A4 = 1'b0; B4 = 1'b0;
        #PROPAGATION_DELAY;
        if (Y1 !== 1'b1 || Y2 !== 1'b1 || Y3 !== 1'b0 || Y4 !== 1'b0) begin
            $error("ERROR: Simultaneous test 1 failed. Expected Y1=1, Y2=1, Y3=0, Y4=0, got Y1=%b, Y2=%b, Y3=%b, Y4=%b", Y1, Y2, Y3, Y4);
        end

        A1 = 1'b0; B1 = 1'b0;
        A2 = 1'b1; B2 = 1'b1;
        A3 = 1'b0; B3 = 1'b1;
        A4 = 1'b1; B4 = 1'b0;
        #PROPAGATION_DELAY;
        if (Y1 !== 1'b0 || Y2 !== 1'b0 || Y3 !== 1'b1 || Y4 !== 1'b1) begin
            $error("ERROR: Simultaneous test 2 failed. Expected Y1=0, Y2=0, Y3=1, Y4=1, got Y1=%b, Y2=%b, Y3=%b, Y4=%b", Y1, Y2, Y3, Y4);
        end

        A1 = 1'b1; B1 = 1'b1;
        A2 = 1'b1; B2 = 1'b1;
        A3 = 1'b1; B3 = 1'b1;
        A4 = 1'b1; B4 = 1'b1;
        #PROPAGATION_DELAY;
        if (Y1 !== 1'b0 || Y2 !== 1'b0 || Y3 !== 1'b0 || Y4 !== 1'b0) begin
            $error("ERROR: Simultaneous test 3 (all same) failed. Expected all outputs=0, got Y1=%b, Y2=%b, Y3=%b, Y4=%b", Y1, Y2, Y3, Y4);
        end

        #(PROPAGATION_DELAY * 2);
        $display("74LS86 - End of Simulation.");
        $finish;
    end

endmodule
